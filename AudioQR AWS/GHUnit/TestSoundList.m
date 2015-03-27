//
//  TestSoundList.m
//  VoiceRecorder
//

#import "TestSoundList.h"

@implementation TestSoundList

- (void)test_init_first_time
{
    SoundList *soundList = [[SoundList alloc] init];
    GHAssertEquals((int)[soundList.list count], 0, @"Checking initialization of SoundList in first time");
}

- (void)test_init_after_saving_data
{
    [self createTestData];
    SoundList *soundList = [[SoundList alloc] init];
    GHAssertEquals((int)[soundList.list count], 2, @"Checking initialization of SoundList after saving data");
    [self clearTestData];
}

- (void)test_append
{
    [self createTestData];
    SoundList *soundList = [[SoundList alloc] init];
    [soundList append:[[Sound alloc] init]];
    GHAssertEquals((int)[soundList.list count], 3, @"Checking append Sound object");
    [self clearTestData];
}

- (void)test_remove
{
    [self createTestData];
    SoundList *soundList = [[SoundList alloc] init];
    Sound *sound = [[Sound alloc] initWithAttributes:@{ @"createdAt": [NSDate date] }];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    [@"test" writeToFile:sound.filePath atomically:NO encoding:NSUTF8StringEncoding error:&error];
    [soundList append:sound];
    
    [soundList remove:[soundList.list count] - 1];
    GHAssertEquals((int)[soundList.list count], 2, @"Checking remove Sound object");
    GHAssertFalse([fileManager fileExistsAtPath:sound.filePath], @"Checking removing sound file");
    [self clearTestData];
}

- (void)createTestData
{
    // create test data
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *arr = [@[
                           [[Sound alloc] init],
                           [[Sound alloc] init]
                           ] mutableCopy];
    [defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:arr] forKey:@"VR_SOUND_LIST"];
    [defaults synchronize];
}

- (void)clearTestData
{
    // clear test data
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"VR_SOUND_LIST"];
    [defaults synchronize];
}

@end
