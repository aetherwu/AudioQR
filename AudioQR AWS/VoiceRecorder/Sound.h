//
//  Sound.h
//  VoiceRecorder
//

#import <Foundation/Foundation.h>

@interface Sound : NSObject

@property NSDate *createdAt;
@property NSString *filePath;

+ (NSString *)filePathFromCurrentTime;
- (id)initWithAttributes:(NSDictionary *)attr;

@end
