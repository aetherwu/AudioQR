//
//  SoundList.m
//  VoiceRecorder
//

#import "SoundList.h"

// VR is the prefix of this app
#define VR_KEY_FOR_SOUND_LIST @"VR_SOUND_LIST"

@implementation SoundList

- (id)init
{
    self = [super init];
    if (self) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSData *data = [defaults objectForKey:VR_KEY_FOR_SOUND_LIST];
        if (data) {
            _list = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        } else {
            _list = [@[] mutableCopy];
        }
    }
    return self;
}

- (void)append:(Sound *)sound
{
    [_list addObject:sound];
    [self synchronizeList];
}

- (void)remove:(NSInteger)index
{
    Sound *removing = _list[index];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    [fileManager removeItemAtPath:removing.filePath error:&error];
    [_list removeObjectAtIndex:index];
    [self synchronizeList];
}

- (void)synchronizeList
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:_list] forKey:VR_KEY_FOR_SOUND_LIST];
    [defaults synchronize];
}


@end
