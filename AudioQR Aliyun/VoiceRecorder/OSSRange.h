//
//  OSSRange.h
//  OSS_SDK
//
//  Created by 郭天 on 14/11/27.
//  Copyright (c) 2014年 郭 天. All rights reserved.
//

/*!
 @header OSSRange.h
 @abstract Created by 郭天 on 14/11/27
 */
#import <Foundation/Foundation.h>
/*!
 @class
 @abstract 构建指定开始和结束的范围
 */
@interface OSSRange : NSObject
/*!
 @property
 @abstract 设置范围开始位pro置
 */
@property long begin;
/*!
 @property
 @abstract 设置范围结束位置
 */
@property long end;
@end
