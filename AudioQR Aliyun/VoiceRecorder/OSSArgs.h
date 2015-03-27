//
//  OSSArgs.h
//  OSS_IOS_SDK
//
//  Created by 郭天 on 14/11/7.
//  Copyright (c) 2014年 郭 天. All rights reserved.
//

/*!
 @header OSSArgs.h
 @abstract Created by 郭天 on 14/11/7.
 */
#import <Foundation/Foundation.h>

typedef enum {
    PRIVATE,
    PUBLIC_READ,
    PUBLIC_READ_WRITE
} AccessControlList;
/*!
 @constant
 @abstract content type 索引字段
 */
extern NSString * const HTTP_HEADER_FIELD_CONTENT_TYPE;
/*!
 @constant
 @abstract content length 索引字段
 */
extern NSString * const HTTP_HEADER_FIELD_CONTENT_LENGTH;
/*!
 @constant
 @abstract 加签索引字段
 */
extern NSString * const HTTP_HEADER_FIELD_AUTH;
/*!
 @constant
 @abstract 日期索引字段
 */
extern NSString * const HTTP_HEADER_FIELD_DATE;
/*!
 @constant
 @abstract 指定范围的索引字段
 */
extern NSString * const HTTP_HEADER_FIELD_BYTERANGE;
/*!
 @constant
 @abstract http请求头中的request id索引字段
 */
extern NSString * const HTTP_HEADER_FIELD_REQUEST_ID;

/*!
 @constant
 @abstract http请求头中的copy id字段
 */
extern NSString * const HTTP_HEADER_FIELD_COPY_ID;

/*!
 @constant
 @abstract 使用http://
 */
extern NSString * const HTTP_SCHEME;

/*!
 @constant
 @abstract bad request 字段
 */
extern NSInteger const HTTP_BAD_REQUEST;

/*!
 @constant
 @abstract 错误码字段
 */
extern NSString * const ERROR_CODE;

/*!
 @constant
 @abstract 错误信息字段
 */
extern NSString * const ERROR_MESSAGE;

/*!
 @constant
 @abstract host id索引字段
 */
extern NSString * const HOST_ID;

/*!
 @constant
 @abstract request id索引字段
 */
extern NSString * const REQUEST_ID;
/*!
 @constant
 @abstract 定义@“PUT”
 */
extern NSString * const HTTP_HEADER_FIELD_METHOD_PUT;
/*!
 @constant
 @abstract 定义@“GET”
 */
extern NSString * const HTTP_HEADER_FIELD_METHOD_GET;
/*!
 @constant
 @abstract http请求头md5索引
 */
extern NSString * const HTTP_HEADER_FIELD_MDFIVE;
/*!
 @constant
 @abstract 计算文件块的大小
 */
extern long const CHUNK_SIZE;
/*!
 @constant
 @abstract user agent前缀
 */
extern NSString * const MBAAS_OSS_IOS_;
/*!
 @constant
 @abstract user agent 索引
 */
extern NSString * const HTTP_HEADER_FIELD_USER_AGENT;
/*!
 @constant
 @abstract 以kb为单位设定的数据块大小
 */
extern int const MULTIPART_UPLOAD_BLOCK_SIZE;
/*!
 @constant
 @abstract 网络请求尝试次数上限
 */
extern int const MAX_HTTP_REQUEST_ATTEMPTS;
/*!
 @constant
 @abstract http请求头中的referer字段索引
 */
extern NSString * const HTTP_HEADER_FIELD_REFERER;
/*!
 @constant
 @abstract OSS数据中心域名格式
 */
extern NSString * const ALIYUNCS;
/*!
 @class
 @abstract 定义一些常量
 */
@interface OSSArgs : NSObject

@end

