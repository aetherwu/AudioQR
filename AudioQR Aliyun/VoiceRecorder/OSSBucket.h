//
//  OSSBucket.h
//  OSS_SDK
//
//  Created by 郭天 on 14/12/12.
//  Copyright (c) 2014年 郭 天. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSSArgs.h"

@interface OSSBucket : NSObject
/*!
 @property
 @abstract 设置和访问bucket name
 */
@property (nonatomic, strong)NSString *bucketName;
/*!
 @property
 @abstract 设置host id
 */
@property (nonatomic, strong)NSString *ossHostId;
/*!
 @property
 @abstract 设置cdn域名
 */
@property (nonatomic, strong)NSString *cdnAccelerateHostId;
/*!
 @property
 @abstract 设置Access Control List
 */
@property (nonatomic)AccessControlList acl;
/*!
 @property
 @abstract 设置加签方法
 */
@property (nonatomic, strong)NSString * (^generateToken)(NSString *, NSString *, NSString *, NSString *, NSString *, NSString *);

/*!
 @method
 @abstract 初始化方法
 */
- (instancetype)initWithBucket:(NSString *)bucketName;


@end
