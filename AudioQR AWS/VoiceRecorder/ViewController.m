//
//  ViewController.m
//  VoiceRecorder
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "RecordTable.h"
#import "lame.h"
#import "S3.h"
#import "AWSCore.h"
#import "Cognito.h"
#import "UrlShortener.h"
#import "UIImage+MDQRCode.h"
#import "Timer.h"
#import "JDStatusBarNotification.h"

@interface ViewController () <AVAudioPlayerDelegate> {
    Timer *timer;
}
    @property (strong, nonatomic) NSData *mp3Data;
    @property (strong, nonatomic) AVAudioPlayer *audioPlayer;
    @property (strong) NSMutableArray *records;
@end

@implementation ViewController {
    UITableView *tableView;
}

@synthesize searchResults;


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
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    
    AWSCognitoCredentialsProvider *credentialsProvider = [AWSCognitoCredentialsProvider
                                                          credentialsWithRegionType:AWSRegionUSEast1
                                                          identityPoolId:@""];
    
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
    
    UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleDrag:)];
    
    recognizer.cancelsTouchesInView = NO; //So the user can still interact with controls in the modal view
    [self.view addGestureRecognizer:recognizer];
    
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


    //set up a time counter
    timer = [[Timer alloc] init];
    [timer startTimer];
    
    //set up a timer
    //force to end when it is longer than 60s.
    [NSTimer scheduledTimerWithTimeInterval:60.0
                                     target:self
                                   selector:@selector(stopRecording)
                                   userInfo:nil
                                    repeats:NO];
    
    //force the button to released state
    //show recording progress bar.
    
    [_recorder record];
}

//start to record
- (IBAction)recordButtonTouchEnd:(UIButton *)btn
{
    [self stopRecording];
}


- (void) stopRecording {

    if (_recorder != nil && _recorder.isRecording) {
        
        // Do some work
        [timer stopTimer];
        float timelapse = [timer timeElapsedInMilliseconds];
        NSLog(@"Total time was: %lf milliseconds", timelapse);
        timer = nil;
        
        if (timelapse<1000) {
            //too short
            NSLog(@"Recording is too short.");
            //show a notification bar on the top
            [JDStatusBarNotification showWithStatus:@"Too short." dismissAfter:1.0
                                          styleName:JDStatusBarStyleWarning];
            
            [_recorder stop];
            _recorder = nil;
        }else{
            
            [_recorder stop];
            [self toMp3: [_recorder.url lastPathComponent]];
            _recorder = nil;
            
        }
    }

}

- (void)handleDrag:(UIPanGestureRecognizer *)sender
{
    //We care only about touching *up*, so let's not bother checking until the gesture ends
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        CGPoint location = [sender locationInView:self.view];
        
        //Let's test to see if the point is inside this button
        if (![self.recordBtn pointInside:[self.recordBtn convertPoint:location fromView:self.view] withEvent:nil])
        {
             if (_recorder != nil && _recorder.isRecording) {
                 [timer stopTimer];
                 float timelapse = [timer timeElapsedInMilliseconds];
                 NSLog(@"Total time was: %lf milliseconds", timelapse);
                 timer = nil;
                 
                 
                 NSLog(@"Recording cancelled.");
                 [JDStatusBarNotification showWithStatus:@"Recording cancelled." dismissAfter:1.0
                                                            styleName:JDStatusBarStyleWarning];
                 
                 [_recorder stop];
                 _recorder = nil;
                 
             }
        }

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
        uploadRequest.bucket = @"YOURBUCKET";
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
                           
                           NSString *S3file = [NSString stringWithFormat:@"http://s3.amazonaws.com/YOURBUCKET/%@", uniqueFileName];
                           
                           //save the history record
                           [self saveRecord:S3file];
                           _audioURL = S3file;
                           _audioDate = [NSDate new];
                           
                           [self createShareView];
                           
                       }
                       return nil;
                   }];
        

    }
    
}

- (void) createShareView {
    
    //TODO get shorted url from database when offline.
    
    UrlShortener *shortener = [[UrlShortener alloc] init];
    [shortener shortenUrl:_audioURL withService:UrlShortenerServiceIsgd completion:^(NSString *shortUrl) {
        
        NSLog(@"Got shorted url: %@", shortUrl);
        
        //create sharing window and QR image
        CGFloat imageSize = ceilf(self.view.bounds.size.width * 0.7f);
        UIView *qrView = [[UIView alloc] initWithFrame:CGRectMake(0,12,320,620)];
        qrView.backgroundColor = [UIColor whiteColor];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(floorf(self.view.bounds.size.width * 0.5f - imageSize * 0.5f), floorf(self.view.bounds.size.height * 0.5f - imageSize * 0.5f) -50 , imageSize, imageSize*1.38f )];
        
        UIImage * qrCodeImg = [UIImage mdQRCodeForString:_audioURL size:imageView.bounds.size.width fillColor:[UIColor darkGrayColor]];
        
        //imageView.image = [self drawText:[NSString stringWithFormat:@"AudioQR: %@", shortUrl] inImage:qrCodeImg atPoint:CGPointMake(0, 0)];
        
        //add extra information to the image:
        //"Voice message, scan to hear"
        //add customized message to the image introducing the images
        //"more about this art piece."
        //add space-padding to the image.
        UIImage *bottomImage = [UIImage imageNamed:@"bg1.png"]; //background image
        UIImage *image       = qrCodeImg; //foreground image
        
        CGSize newSize = CGSizeMake( 244, 340 );
        UIGraphicsBeginImageContext( newSize );
        
        // Use existing opacity as is
        [bottomImage drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
        
        // Apply supplied opacity if applicable
        [image drawInRect:CGRectMake(10, 58, imageSize, imageSize )];
        
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        newImage = [self drawText:@"Audio QR:"
                                    inImage:newImage
                                    atPoint:CGPointMake(10, 10)];
        
        newImage = [self drawText:shortUrl
                          inImage:newImage
                          atPoint:CGPointMake(10, 24)];
        
        newImage = [self drawText:[NSString stringWithFormat:@"%@", _audioDate]
                          inImage:newImage
                          atPoint:CGPointMake(10, 340 - 40)];
        
        newImage = [self drawText:@"Extract QR to hear the message."
                          inImage:newImage
                          atPoint:CGPointMake(10, 340 - 24)];
        
        
        imageView.image = newImage;
        
        //Disable the auto saving to cameral roll since we have the sharing function.
        //UIImageWriteToSavedPhotosAlbum(qrCodeImg, nil, nil, nil);
        
        [qrView addSubview:imageView];
        
        [self.view addSubview:qrView];
        
        //add dismiss button
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button addTarget:self
                   action:@selector(dismissQR:)
         forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"Close" forState:UIControlStateNormal];
        button.frame = CGRectMake(245.0, 18.0, 80.0, 40.0);
        [qrView addSubview:button];
        
        //add share button
        UIButton *buttonShare = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [buttonShare addTarget:self
                        action:@selector(shareQR:)
              forControlEvents:UIControlEventTouchUpInside];
        [buttonShare setTitle:@"Share" forState:UIControlStateNormal];
        buttonShare.frame = CGRectMake(0.0, 18.0, 80.0, 40.0);
        [qrView addSubview:buttonShare];
        
        //add replay button
        UIButton *buttonReplay = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [buttonReplay addTarget:self
                         action:@selector(replay:)
               forControlEvents:UIControlEventTouchUpInside];
        [buttonReplay setTitle:@"RePlay" forState:UIControlStateNormal];
        buttonReplay.frame = CGRectMake(65.0, 18.0, 80.0, 40.0);
        [qrView addSubview:buttonReplay];
        
    } error:^(NSError *error) {
        // Handle the error.
        NSLog(@"Error: %@", [error localizedDescription]);
    }];
}


- (void) dismissQR:(UIButton *)sender {
    
    _audioPlayer = nil;
    [[sender superview] removeFromSuperview];
    
}


- (void) shareQR:(UIButton *)sender {
    
    UIImage *qrImage;
    
    for(UIImageView *aView in [[sender superview] subviews]){
        if([aView isKindOfClass:[UIImageView class]]){
            //YourClass found!!
            qrImage = aView.image;
            
            NSArray *objectsToShare = @[qrImage, _audioURL];
            
            UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
            
            NSArray *excludeActivities = @[UIActivityTypeCopyToPasteboard,
                                           UIActivityTypeAssignToContact,
                                           UIActivityTypeAddToReadingList,
                                           UIActivityTypePostToFlickr,
                                           UIActivityTypePostToVimeo,
                                           UIActivityTypePostToTencentWeibo
                                           ];
            
            activityVC.excludedActivityTypes = excludeActivities;
            
            [self presentViewController:activityVC animated:YES completion:nil];
            
            return;
        }
    }
    
}

/*-------------
 
 Audio replay
 
 ---------------*/

- (void) stopPlaying:(UIButton *)sender  {

    _audioPlayer = nil;
    
}


- (void) replay:(UIButton *)sender {
    //play the _audioURL
    [self playAudio:_audioURL];
    
    //switch play button
}

- (void)playAudio:(NSString *)result
{
    NSLog(@"play: %@", result);
    NSError *error1;
    NSError *error2;
    NSURL *url = [NSURL URLWithString:result];
    self.mp3Data = [[NSData alloc] initWithContentsOfURL:url options:0 error:&error1 ];
    
    _audioPlayer = nil;
    self.audioPlayer = [[AVAudioPlayer alloc]
                        initWithData:self.mp3Data
                        error:&error2];
    self.audioPlayer.delegate = self;
    [self.audioPlayer prepareToPlay];
    [self.audioPlayer play];

}

/*-------------
 
 Audio history and management
 
 ---------------*/

- (void) saveRecord: (NSString *)url {
    //save date and url to database
    
    //
    //parepare to save a tunecate to database
    AppDelegate* appDelegate = [AppDelegate sharedAppDelegate];
    NSManagedObjectContext* context = appDelegate.managedObjectContext;
    
    //add a new item
    NSManagedObject *newEntry = [NSEntityDescription insertNewObjectForEntityForName:@"Records" inManagedObjectContext:context];
    
    //TODO igore upper/lower case
    
    [newEntry setValue:url forKey:@"url"];
    [newEntry setValue:[NSDate date] forKey:@"date"];
    
    //
    //prepared to save database
    //
    
    // Save the object to persistent store
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }

}


- (IBAction)showHistory:(UIButton *)btn {

    //load database
    // Fetch default previous search keywords from persistent data store
    AppDelegate* appDelegate = [AppDelegate sharedAppDelegate];
    NSManagedObjectContext* context = appDelegate.managedObjectContext;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Records"];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    
    NSMutableArray *historyList;
    NSMutableArray* tmpArray = [[NSMutableArray alloc] init];
    
    historyList = [[context executeFetchRequest:fetchRequest error:nil] mutableCopy];
    self.records = historyList;
    
    for (int i = 0; i<[historyList count]; i++){
        [tmpArray addObject: [[historyList objectAtIndex:i] valueForKey:@"date"]];
    }
    
    searchResults = tmpArray;
    
    //init the table view
    // create a table view and a scroll view
    // init table view
    
    UIView *tableContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 24,320,620)];
    tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    
    // must set delegate & dataSource, otherwise the the table will be empty and not responsive
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.backgroundColor = [UIColor whiteColor];
    
    // add to canvas
    [tableContainerView addSubview:tableView];
    [tableView reloadData];
    
    
    UIButton *dissmissTable = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [dissmissTable addTarget:self
                      action:@selector(dismissRecords:)
            forControlEvents:UIControlEventTouchUpInside];
    [dissmissTable setTitle:@"Close" forState:UIControlStateNormal];
    dissmissTable.frame = CGRectMake(245.0, 5, 80.0, 40.0);
    
    [tableContainerView addSubview:dissmissTable];
    
    [self.view addSubview:tableContainerView];
    
    
    //show the table view

}

- (void) dismissRecords:(UIButton *)sender {
    
    [[sender superview] removeFromSuperview];
    
}


- (void) reShare {}



- (void) deleteRecord {}




/*-------------

 
Utilities
 
---------------*/

- (UIImage *) drawText:(NSString*) text
             inImage:(UIImage*)  image
             atPoint:(CGPoint)   point
{
    
    UIFont *font = [UIFont boldSystemFontOfSize:12];
    
    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                     font, NSFontAttributeName,
                                     [NSNumber numberWithFloat:1.0], NSBaselineOffsetAttributeName, nil];
    
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0,0,image.size.width,image.size.height)];
    CGRect rect = CGRectMake(point.x, point.y, image.size.width, image.size.height);
    [[UIColor whiteColor] set];
    
    [text drawInRect:CGRectIntegral(rect) withAttributes:attrsDictionary];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
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

/*-------------
 
 
 table operation
 
 ---------------*/

#pragma mark - UITableViewDataSource
// number of section(s), now I assume there is only 1 section
- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView
{
    return 1;
}

// number of row in the section, I assume there is only 1 row
- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section
{
    return [searchResults count];
}

// the cell will be returned to the tableView
- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"HistoryCell";
    
    // Similar to UITableViewCell, but
    RecordTable *cell = (RecordTable *)[theTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[RecordTable alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    // Just want to test, so I hardcode the data
    [cell.textLabel setText: [NSString stringWithFormat:@"%@", [searchResults objectAtIndex:indexPath.row]] ];
    
    return cell;
}

#pragma mark - UITableViewDelegate


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Audio library:";
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}

// when user tap the row, what action you want to perform
- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //show reshare view
    //[searchResults objectAtIndex:indexPath.row]
    //find url by data
    _audioURL = [[self.records objectAtIndex:indexPath.row] valueForKey:@"url"];
    _audioDate = [[self.records objectAtIndex:indexPath.row] valueForKey:@"date"];
    [self createShareView];
    
}

//swipe and delete action
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    AppDelegate* appDelegate = [AppDelegate sharedAppDelegate];
    NSManagedObjectContext* context = appDelegate.managedObjectContext;
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // Delete object from database
        [context deleteObject:[self.records objectAtIndex:indexPath.row]];
        
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
            return;
        }
        
        // Remove entry from table view and update varible.
        [self.records removeObjectAtIndex:indexPath.row];
        searchResults = self.records;
        [self->tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        
        // Remove audio file from AWS server?
        // or expire it automatically.
        
    }
}



+(UIImage*) drawText:(NSString*) text
             inImage:(UIImage*)  image
             atPoint:(CGPoint)   point
{
    
    UIFont *font = [UIFont systemFontOfSize:14];
    
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0,0,image.size.width,image.size.height)];
    CGRect rect = CGRectMake(point.x, point.y, image.size.width, image.size.height);
    
    [[UIColor whiteColor] set];
    
    NSDictionary *dictionary = @{
                                 NSFontAttributeName: font,
                                 NSForegroundColorAttributeName:[UIColor lightGrayColor]
                                };
    
    [text drawInRect:CGRectIntegral(rect) withAttributes:dictionary];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
