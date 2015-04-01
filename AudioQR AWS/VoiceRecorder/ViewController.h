//
//  ViewController.h
//  VoiceRecorder
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController : UIViewController

@property (nonatomic, strong) NSString *audioURL;

@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) AVAudioSession *session;
@property (nonatomic, weak) IBOutlet UIButton *recordBtn;

- (IBAction)recordButtonTouchStart:(UIButton *)btn;
- (IBAction)recordButtonTouchEnd:(UIButton *)btn;

@end
