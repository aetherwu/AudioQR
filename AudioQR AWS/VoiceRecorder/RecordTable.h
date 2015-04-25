//
//  RecordTable.h
//  VoiceRecorder
//
//  Created by Aether Wu on 4/24/15.
//  Copyright (c) 2015 bugcloud. All rights reserved.
//

#import <UIKit/UIKit.h>

// extends UITableViewCell
@interface RecordTable : UITableViewCell

// now only showing one label, you can add more yourself
@property (nonatomic, strong) UILabel *audioDate;

@end