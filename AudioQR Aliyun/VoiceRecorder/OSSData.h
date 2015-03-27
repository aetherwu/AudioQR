//
//  OSSData.h
//  OSSDemo
//
//  Created by 郭天 on 14/11/3.
//  Copyright (c) 2014年 郭 天. All rights reserved.
//
/*!
 @header OSSData.h
 @abstract 直接对NSData数据进行操作
 */
#import <Foundation/Foundation.h>
#import "OSSObject.h"
#import "OSSBucket.h"

/*!
 @class
 @abstract 提供上传、下载、复制和删除接口
 */
@interface OSSData :OSSObject
/*!
 @method
 @abstract 使用bucket和key初始化一个OSSData实例，bucket为数据所在的bucket，key为object key
 */
- (instancetype)initWithBucket:(OSSBucket *)bucket withKey:(NSString *)key;
/*!
 @method
 @abstract 取消当前异步上传或下载操作
 */
- (void)cancel;
/*!
 @method
 @abstract 生成一个public资源的url
 */
- (NSString *)getResourceURL;
/*!
 @method
 @abstract 生成一个private资源的url，当前用户的accessKey，availablePeriodInSeconds是url可用时间
 */
- (NSString *)getResourceURL:(NSString *)accessKey andExpire:(int)availablePeriodInSeconds;
/*!
 @method
 @abstract 在进行上传之前需要调用该函数设置待上传的数据，以及数据的content type属性
 */
- (void)setData:(NSData *)nsdata withType:(NSString *)type;
/*!
 @method
 @abstract 设置自定义meta
 */
- (void)setMetaKey:(NSString *)metaKey withMetaValue:(NSString *)metaValue;
/*!
 @method
 @abstract 在要调用getRange方法之前需要调用该方法设置需要下载的字节数据范围
 */
- (void)setRangeFrom:(long)begin to:(long)end;
/*!
 @method
 @abstract 阻塞下载数据，error用来存放错误信息
 */
- (NSData *)get:(NSError **)error;
/*!
 @method
 @abstract 非阻塞下载数据，并实现progress来访问进度
 */
- (void)getWithDataCallback:(void (^)(NSData *, NSError *))dataCallback withProgressCallback:(void (^)(float))progressCallback;
/*!
 @method
 @abstract 阻塞删除该object
 */
- (void)delete:(NSError **)error;

/*!
 @method
 @abstract 非阻塞删除该object
 */
- (void)deleteWithDeleteCallback:(void (^)(BOOL, NSError *))deleteCallback;

/*!
 @method
 @abstract 阻塞上传，并指定为contentType
 */
- (void)upload:(NSError **)error;

/*!
 @method
 @abstract 非阻塞上传，实现progressCallback来访问上传进度
 */
- (void)uploadWithUploadCallback:(void (^)(BOOL, NSError *))uploadCallback withProgressCallback:(void (^)(float))progressCallback;

/*!
 @method
 @abstract 阻塞从指定的object复制
 */
- (void)copyFromBucket:(NSString *)bucket key:(NSString *)key error:(NSError **)error;

/*!
 @method
 @abstract 非阻塞从指定的object复制
 */
- (void)copyFromWithBucket:(NSString *)bucket withKey:(NSString *)key withCopyCallback:(void (^)(BOOL, NSError *))copyCallback;

@end
