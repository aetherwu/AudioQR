//
//  TestSound.m
//  VoiceRecorder
//

#import "TestSound.h"

@implementation TestSound

- (void)test_initialization
{
    NSDate *now = [NSDate date];
    id mock = [OCMockObject mockForClass:[Sound class]];
    [[[[mock stub] classMethod] andReturn:@"2013-01-01 02:34:56.caf"] filePathFromCurrentTime];
    Sound *s = [[Sound alloc] initWithAttributes:@{
                @"createdAt": now,
                @"filePath": @"/test/this_is_test.caf"
                }];
    GHAssertEqualObjects(
                         s.createdAt,
                         now,
                         @"Checking initialize Sound#createdAt"
                         );
    GHAssertEqualStrings(
                         s.filePath,
                         @"2013-01-01 02:34:56.caf",
                         @"Checking initialize Sound#filePath"
                         );
    [mock verify];
}

- (void)test_filePathFromCurrentTime
{
    NSString *str = [Sound filePathFromCurrentTime];
    NSLog(@"%@", str);
    NSError *error = nil;
    NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:@"^[A-Za-z0-9\\.\\/\\- ]+\\/[0-9]{4}\\-[0-9]{2}\\-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}\\.caf$" options:0 error:&error];
    NSArray *result = [regexp matchesInString:str options:0 range:NSMakeRange(0, str.length)];
    GHAssertEquals((int)[result count], 1, @"Checking Sound.filePathFromCurrentTime string format");
}

@end
