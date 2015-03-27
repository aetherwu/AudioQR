//
//  SoundList.h
//  VoiceRecorder
//
//  A wrapper class to save and load Sound class objects
//  using NSUserDefaults
//

#import <Foundation/Foundation.h>
#import "Sound.h"

@interface SoundList : NSObject

@property NSMutableArray *list;

- (void)append:(Sound *)sound;
- (void)remove:(NSInteger)index;

@end
