//
//  RecordTable.m
//  VoiceRecorder
//
//  Created by Aether Wu on 4/24/15.
//  Copyright (c) 2015 bugcloud. All rights reserved.
//

#import "RecordTable.h"

@implementation RecordTable

@synthesize audioDate = _audioDate;

- (id)initWithStyle: (UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // configure control(s)
        self.audioDate = [[UILabel alloc] initWithFrame:CGRectMake(5, 10, 300, 30)];
        self.audioDate.textColor = [UIColor blackColor];
        self.audioDate.font = [UIFont fontWithName:@"Arial" size:12.0f];
        
        [self addSubview:self.audioDate];
    }
    return self;
}

@end