//
//  ViewController.m
//  VoiceRecorder
//

#import "ViewController.h"
#import "lame.h"
#import "S3.h"
#import "AWSCore.h"
#import "Cognito.h"
#import "UrlShortener.h"
#import "UIImage+MDQRCode.h"


@interface ViewController ()

@end

@implementation ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:@"ViewController" bundle:nil];
    if (self) {
        _session = [AVAudioSession sharedInstance];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    AWSCognitoCredentialsProvider *credentialsProvider = [AWSCognitoCredentialsProvider
                                                          credentialsWithRegionType:AWSRegionUSEast1
                                                          identityPoolId:@"YOURID"];
    
    AWSServiceConfiguration *configuration = [AWSServiceConfiguration configurationWithRegion:AWSRegionUSEast1
                                                                          credentialsProvider:credentialsProvider];
    
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)recordButtonTouchStart:(UIButton *)btn
{
    NSError *error = nil;
    if (_session.inputAvailable) {
        [_session setCategory:AVAudioSessionCategoryRecord error:&error];
    }
    if (error != nil) {
        LOG(@"Error when preparing audio session :%@", [error localizedDescription]);
        return;
    }
    
    [_session setActive:YES error:&error];
    if (error != nil) {
        LOG(@"Error when enabling audio session :%@", [error localizedDescription]);
        return;
    }
    
    // make file path & start recording
    NSURL *url = [NSURL fileURLWithPath:[[self class] filePathFromCurrentTime]];
    
    _recorder = [[AVAudioRecorder alloc] initWithURL:url settings:nil error:&error];
    if (error != nil) {
        LOG(@"Error when preparing audio session :%@", [error localizedDescription]);
        return;
    }

    [_recorder record];
}

//start to record
- (IBAction)recordButtonTouchEnd:(UIButton *)btn
{
    if (_recorder != nil && _recorder.isRecording) {
        
        [_recorder stop];
        
        [self toMp3: [_recorder.url lastPathComponent]];
        
        _recorder = nil;
    }
}

//show audio library
/*
- (IBAction)playButtonTouchEnd:(UIButton *)btn
{
    [self presentViewController:_playerView animated:YES completion:^(void) {
        [_playerView.tableView reloadData];
    }];
}
*/


- (void) toMp3: (NSString *) filename
{
    
    NSString *mp3FileName = @"Mp3File";
    mp3FileName = [mp3FileName stringByAppendingString:@".mp3"];
    NSString *mp3FilePath = [[NSHomeDirectory() stringByAppendingFormat:@"/Documents/"] stringByAppendingPathComponent:mp3FileName];
    NSString *cafFilePath = [[NSHomeDirectory() stringByAppendingFormat:@"/Documents/"] stringByAppendingPathComponent:filename];
    
    @try {
        int read, write;

        FILE *pcm = fopen([cafFilePath cStringUsingEncoding:1], "rb");  //source
        fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
        
        //seek to at least 2 seconds audio
        //break if can't proceed
        //pop up alert notification
        
        
        
        FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:1], "wb");  //output
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, 44100/2);
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        do {
            read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
    }
    @finally {
        [self performSelectorOnMainThread:@selector(convertMp3Finish:)
                               withObject:mp3FileName
                            waitUntilDone:YES];
    }
}

- (void) convertMp3Finish: (NSString *) mp3FileName
{
    
    NSString *mp3FilePath = [[NSHomeDirectory() stringByAppendingFormat:@"/Documents/"] stringByAppendingPathComponent:mp3FileName];
    NSURL *url = [NSURL fileURLWithPath:mp3FilePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath: [url path]]) {
        
        AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
        AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
        
        NSString *prefixString = @"VoiceQR";
        
        NSString *guid = [[NSProcessInfo processInfo] globallyUniqueString] ;
        NSString *uniqueFileName = [NSString stringWithFormat:@"%@_%@.mp3", prefixString, guid];

        
        //uplpad this mp3 and get url
        uploadRequest.bucket = @"mindlit";
        uploadRequest.key = uniqueFileName;
        uploadRequest.body = url;
        NSLog(@"File uploading...");
        
        [[transferManager upload:uploadRequest] continueWithExecutor:[BFExecutor mainThreadExecutor]
                   withBlock:^id(BFTask *task) {
                       if (task.error) {
                           if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
                               switch (task.error.code) {
                                   case AWSS3TransferManagerErrorCancelled:
                                   case AWSS3TransferManagerErrorPaused:
                                       break;
                                       
                                   default:
                                       NSLog(@"Error: %@", task.error);
                                       //re-try?
                                       break;
                               }
                           } else {
                               // Unknown error.
                               NSLog(@"Error: %@", task.error);
                           }
                       }
                       
                       if (task.result) {
                           //AWSS3TransferManagerUploadOutput *uploadOutput = task.result;

                           // The file uploaded successfully.
                           NSLog(@"File uploaded: %@", uniqueFileName);
                           
                           //delete the local file
                           NSError *error;
                           BOOL success = [[NSFileManager defaultManager] removeItemAtPath:mp3FilePath error:&error];
                           if (success)
                               NSLog(@"Local file deleted");
                            else
                               NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
                           
                           
                           NSString *S3file = [NSString stringWithFormat:@"http://s3.amazonaws.com/YOURBUKET/%@", uniqueFileName];
                           
                           UrlShortener *shortener = [[UrlShortener alloc] init];
                           [shortener shortenUrl:S3file withService:UrlShortenerServiceIsgd completion:^(NSString *shortUrl) {
                               
                               NSLog(@"Got shorted url: %@", shortUrl);

                               //create sharing window and QR image
                               CGFloat imageSize = ceilf(self.view.bounds.size.width * 0.6f);
                               UIView *qrView = [[UIView alloc] initWithFrame:CGRectMake(0,12,320,320)];
                               qrView.backgroundColor = [UIColor whiteColor];
                               UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(floorf(self.view.bounds.size.width * 0.5f - imageSize * 0.5f), floorf(self.view.bounds.size.height * 0.5f - imageSize * 0.5f), imageSize, imageSize)];
                               UIImage * qrCodeImg = [UIImage mdQRCodeForString:shortUrl size:imageView.bounds.size.width fillColor:[UIColor darkGrayColor]];
                               imageView.image = qrCodeImg;
                               UIImageWriteToSavedPhotosAlbum(qrCodeImg, nil, nil, nil);
                               
                               //add dismiss button
                               
                               //add share button
                               
                               
                               [qrView addSubview:imageView];
                               [self.view addSubview:qrView];
                               
                           } error:^(NSError *error) {
                               // Handle the error.
                               NSLog(@"Error: %@", [error localizedDescription]);
                           }];
                           
                           
                       }
                       return nil;
                   }];
        

    }
    
}

+ (NSString *)filePathFromCurrentTime
{
    NSString *dir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //[formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"JST"]];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *fileName = [formatter stringFromDate:[NSDate date]];
    return [dir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.caf", fileName]];
}
@end
