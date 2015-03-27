//
//  OSSClient.h
//  OSSDemo
//
//  Created by 郭天 on 14/11/3.
//  Copyright (c) 2014年 郭 天. All rights reserved.
//

/*!
 @header OSSClient.h
 @abstract Created by 郭天 on 14/11/3.
 */
#import <Foundation/Foundation.h>
#import "OSSData.h"
#import "OSSFile.h"
#import "OSSMeta.h"

//#define OSS_LOGER 1

/*!
 @class
 @abstract 实现初始化函数、单例模式和对加签block的回调函数
 */
@interface OSSClient : NSObject
/*!
 @property
 @abstract 设置Access Control List
 */
@property (nonatomic)AccessControlList globalDefaultBucketAcl;
/*!
 @property
 @abstract 设置host id
 */
@property (nonatomic, strong)NSString *globalDefaultBucketHostId;
/*!
 @property
 @abstract 需要用户实现的加签block，参数依次为http request method、md5、content type、date、xoss和resource
 */
@property (nonatomic, strong)NSString * (^generateToken)(NSString *, NSString *, NSString *, NSString *, NSString *, NSString *);
/*!
 @property
 @abstract 用来存放各种各种异步操作线程
 */
@property (strong, nonatomic) NSOperationQueue* queue;
/*!
 @property
 @abstract 自定义user agent
 */
@property (strong, nonatomic)NSString *myAgent;
/*!
 @method
 @abstract 实现单例模式
 */
+ (OSSClient *)sharedInstanceManage;

@end
