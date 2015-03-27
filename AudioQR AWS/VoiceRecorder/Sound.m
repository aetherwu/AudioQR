//
//  Sound.m
//  VoiceRecorder
//

#import "Sound.h"

@implementation Sound

- (id)initWithAttributes:(NSDictionary *)attr
{
    self = [super init];
    self.createdAt = attr[@"createdAt"];
    self.filePath = [[self class] filePathFromCurrentTime];
    return self;
}

// implements the NSCoding protocol
- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        self.createdAt = [coder decodeObjectForKey:@"createdAt"];
        self.filePath = [coder decodeObjectForKey:@"filePath"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.createdAt forKey:@"createdAt"];
    [coder encodeObject:self.filePath forKey:@"filePath"];
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
