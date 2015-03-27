//
//  ViewController.m
//  VoiceRecorder
//

#import "ViewController.h"
#import "lame.h"

#import "UrlShortener.h"
#import "UIImage+MDQRCode.h"


#import "OSSClient.h"
#import "OSSTool.h"
#import "OSSData.h"
#import "OSSLog.h"


@interface ViewController ()

@end

@implementation ViewController {
    
    OSSData *ossfileData;
}

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
        
        lame_mp3_tags_fid(lame, mp3);
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
        
        NSString *prefixString = @"VoiceQR";
        
        NSString *guid = [[NSProcessInfo processInfo] globallyUniqueString] ;
        NSString *uniqueFileName = [NSString stringWithFormat:@"%@_%@.mp3", prefixString, guid];


        NSLog(@"File uploading...");
        
        
        OSSClient *ossclient = [OSSClient sharedInstanceManage];
        [ossclient setGlobalDefaultBucketHostId:@"oss-cn-shenzhen.aliyuncs.com"];
        NSString *accessKey = @"YOURKEY";
        NSString *secretKey = @"YOURKEY";
        NSString *yourBucket = @"YOURBUCKET";
        
        [ossclient setGenerateToken:^(NSString *method, NSString *md5, NSString *type, NSString *date, NSString *xoss, NSString *resource){
            NSString *signature = nil;
            NSString *content = [NSString stringWithFormat:@"%@\n%@\n%@\n%@\n%@%@", method, md5, type, date, xoss, resource];
            signature = [OSSTool calBase64Sha1WithData:content withKey:secretKey];
            signature = [NSString stringWithFormat:@"OSS %@:%@", accessKey, signature];
            NSLog(@"here signature:%@", signature);
            return signature;
        }];
        

        OSSBucket *bucket = [[OSSBucket alloc] initWithBucket:yourBucket];
        OSSData *uploadData = [[OSSData alloc] initWithBucket:bucket withKey:uniqueFileName];
        
        NSData *mp3Data = [NSData dataWithContentsOfURL:url];
        [uploadData setData:mp3Data withType:@"application/octet-stream"];
        [uploadData uploadWithUploadCallback:^(BOOL isSuccess, NSError *error) {
            if (isSuccess) {
                //NSLog(@"head is :%@", head);
                
                // The file uploaded successfully.
                NSLog(@"File uploaded: %@", uniqueFileName);
                
                //delete the local file
                NSError *error1;
                BOOL success = [[NSFileManager defaultManager] removeItemAtPath:mp3FilePath error:&error1];
                if (success)
                    NSLog(@"Local file deleted");
                else
                    NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
                
                
                NSString *ossfile = [NSString stringWithFormat:@"http://YOURBUCKET.oss-cn-shenzhen.aliyuncs.com/%@", uniqueFileName];

                    //create sharing window and QR image
                    CGFloat imageSize = ceilf(self.view.bounds.size.width * 0.6f);
                    UIView *qrView = [[UIView alloc] initWithFrame:CGRectMake(0,12,320,320)];
                    qrView.backgroundColor = [UIColor whiteColor];
                    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(floorf(self.view.bounds.size.width * 0.5f - imageSize * 0.5f), floorf(self.view.bounds.size.height * 0.5f - imageSize * 0.5f), imageSize, imageSize)];
                    UIImage * qrCodeImg = [UIImage mdQRCodeForString:ossfile size:imageView.bounds.size.width fillColor:[UIColor darkGrayColor]];
                    imageView.image = qrCodeImg;
                    UIImageWriteToSavedPhotosAlbum(qrCodeImg, nil, nil, nil);
                    
                    //add dismiss button
                    
                    //add share button
                    
                    
                    [qrView addSubview:imageView];
                    [self.view addSubview:qrView];

            
            }
            else
            {
                NSLog(@"errorInfo_testDataUploadWithProgress:%@", [error userInfo]);
            }
        } withProgressCallback:^(float progress) {
            NSLog(@"current get %f", progress);
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
