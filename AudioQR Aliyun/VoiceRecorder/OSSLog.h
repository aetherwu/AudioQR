//
//  OSSLog.h
//  OSS_SDK
//
//  Created by 郭天 on 14/11/25.
//  Copyright (c) 2014年 郭 天. All rights reserved.
//

/*!
 @header OSSLog.h
 @abstract Created by 郭天 on 14/11/25
 */
#import <Foundation/Foundation.h>

/*!
 @class
 @abstract 辅助打印log
 */
extern BOOL isEnableLog;

@interface OSSLog : NSObject

/*!
 @method
 @abstract 开启log
 */
+ (void)enableLog:(BOOL)isEnbale;
/*!
 @method
 @abstract 打印debug信息
 */
+ (void)LogD:(NSString *)message;
/*!
 @method
 @abstract 打印error信息
 */
+ (void)LogE:(NSString *)message;
@end