//
//  OSSObject.h
//  OSSDemo
//
//  Created by 郭天 on 14/11/4.
//  Copyright (c) 2014年 郭 天. All rights reserved.
//

/*!
 @header OSSObject.h
 @abstract Created by 郭天 on 14/11/3.
 */
#import <Foundation/Foundation.h>
#import "OSSRange.h"
#import "OSSBucket.h"

/*!
 @class
 @abstract 设定bucket和key
 */
@interface OSSObject : NSObject
/*!
 @property
 @abstract 存放content type
 */
@property (nonatomic, strong)NSMutableString *contentType;
/*!
 @property
 @abstract 设定下载范围
 */
@property (nonatomic, strong)OSSRange *range;
/*!
 @property
 @abstract 存放meta信息
 */
@property (nonatomic, strong)NSMutableDictionary *metaDictionary;
/*!
 @property
 @abstract 设置bucket
 */
@property (nonatomic, strong)OSSBucket *bucket;
/*!
 @property
 @abstract 设置object的key
 */
@property (nonatomic, strong)NSString *key;

/*!
 @method
 @abstract 初始化bucket和key
 */
- (instancetype)initWithBucket:(OSSBucket *)bucket withKey:(NSString *)key;
/*!
 @method
 @abstract 构建使用发往OSS服务器的请求
 */
- (NSMutableURLRequest *)constructRequestWithMethod:(NSString *)method
                                            withMd5:(NSString *)md
                                        withContype:(NSString *)contentType
                                        withXossDic:(NSDictionary *)xossHeaderDic
                                         withBucket:(NSString *)bucket
                                            withKey:(NSString *)key
                                          withRange:(OSSRange *)range;
@end
