//
//  OSSTool.h
//  OSS_SDK
//
//  Created by 郭天 on 14/11/20.
//  Copyright (c) 2014年 郭 天. All rights reserved.
//
/*!
 @header OSSTool.h
 @abstract Created by 郭天 on 14/11/20.
 */

#import <Foundation/Foundation.h>
#import "OSSArgs.h"
#import "OSSBucket.h"
#import "OSSMultipart.h"

/*!
 @class
 @abstract 封装带上传文件的基本信息
 */
@interface OSSTool : NSObject
/*!
 @method
 @abstract 计算md5值
 */
+ (NSString *)calMd5SumWithData:(NSString *)data;

/*!
 @method
 @abstract 实现HMAC-SHA1签名再Base64转码
 */
+ (NSString *)calBase64Sha1WithData:(NSString *)data withKey:(NSString *)key;
/*!
 @method
 @abstract 计算GMT格式时间
 */
+ (NSString *)getGMTString;
/*!
 @method
 @abstract 执行http请求
 */
+ (NSData *)executeHttpRequest:(NSMutableURLRequest *)request :(NSHTTPURLResponse **)response :(NSError **)error;
/*!
 @method
 @abstract 执行http请求并将应答的head返回
 */
+ (NSDictionary *)executeHttpHeadRequest:(NSMutableURLRequest *)request :(NSHTTPURLResponse **)response :(NSError **)error;

/*!
 @method
 @abstract 将解析到的错误XML返回数据进行解析并写入到字典errorInfo
 */
+ (void)parseErrorResponseXML:(NSData *)responseData intoDic:(NSMutableDictionary **)errorInfo;
/*!
 @method
 @abstract 将error构建成NSException
 */
+ (NSException *)buildExceptionFromError:(NSError *)error;
/*!
 @method
 @abstract 将exception构建成NSError
 */
+ (NSError *)buildErrorFromException:(NSException *)exception;
/*!
 @method
 @abstract 从一个字符串构造一个NSException
 */
+ (NSException *)buildExceptionWithString:(NSString *)errorInfo;
/*!
 @method
 @abstract 从一个字符串构造一个NSError
 */
+ (NSError *)buildErrorWithString:(NSString *)errorInfo;
/*!
 @method
 @abstract 使用response和responseData构建错误信息
 */
+ (NSError *)buildErrorFromResponse:(NSHTTPURLResponse *)response withResponseData:(NSData *)responseData;
/*!
 @method
 @abstract 打印返回的数据和状态码
 */
+ (void)printResponseCodeData:(NSHTTPURLResponse *)response andData:(NSData *)data;
/*!
 @method
 @abstract 如果字符串是nil或长度为0则返回true
 */
+ (BOOL)isEmptyString:(NSString *)str;
/*!
 @method
 @abstract 将传入的字符串两端的空格删除
 */
+ (NSString *)trimString:(NSString *)string withCharactersInString:(NSString *)characters;
/*!
 @method
 @abstract 对数组进行字典排序
 */
+ (NSArray *)sortArray:(NSArray *)array;
/*!
 @method
 @abstract 计算large file的md5
 */
+ (NSString*)fileMD5:(NSString*)path;
/*!
 @method
 @abstract 计算large data的md5
 */
+ (NSString *)largeDataMD5:(NSData *)data;
/*!
 @method
 @abstract 计算NSString对象的md5
 */
+ (NSString *)dataMD5:(NSString *)stringData;
/*!
 @method
 @abstract 判断一个数据范围是否合法
 */
+ (BOOL)isLegalRangeFrom:(long)begin to:(long)end;
/*!
 @method
 @abstract 判断是否需要加签操作
 */
+ (BOOL)isNeedAddAuthWithRequest:(NSMutableURLRequest *)request andBucket:(OSSBucket *)bucket;
/*!
 @method
 @abstract 对url重新编码
 */
+ (NSString *)urlEncode:(NSString *)url;
/*!
 @method
 @abstract 删除持久化内容
 */
+ (void)clearMemory:(OSSMultipart *)multipart;
/*!
 @method
 @abstract 判断域名是否为cname
 */
+ (BOOL)isCname:(NSString *)string;

@end
