//
//  OSSMeta.h
//  OSSDemo
//
//  Created by 郭天 on 14/11/4.
//  Copyright (c) 2014年 郭 天. All rights reserved.
//
/*!
 @header OSSMeta.h
 @abstract Created by 郭天 on 14/11/4.
 */
#import <Foundation/Foundation.h>
#import "OSSObject.h"
/*!
 @class
 @abstract 获取object的meta信息
 */
@interface OSSMeta : OSSObject
/*!
 @method
 @abstract 阻塞访问meta信息
 */
- (NSDictionary *)getMeta:(NSError **)error;
/*!
 @method
 @abstract 非阻塞访问meta信息
 */
- (void)getWithMetaCallback:(void (^)(NSDictionary *, NSError *))metaBlock;
@end
