//
//  ViewController.h
//  VoiceRecorder
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSString *audioURL;
@property (nonatomic, strong) NSDate *audioDate;

@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) AVAudioSession *session;

@property (nonatomic, weak) IBOutlet UIButton *recordBtn;
@property (nonatomic, retain) NSArray *searchResults;


- (IBAction)recordButtonTouchStart:(UIButton *)btn;
- (IBAction)recordButtonTouchEnd:(UIButton *)btn;
- (IBAction)showHistory:(UIButton *)btn;

@end
