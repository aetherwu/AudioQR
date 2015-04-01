//
//  OSSMultipart.h
//  OSS_SDK
//
//  Created by 郭天 on 14/11/17.
//  Copyright (c) 2014年 郭 天. All rights reserved.
//
/*!
 @header OSSMultipart.h
 @abstract Created by 郭天 on 14/11/7.
 */
#import "OSSObject.h"
#import "OSSFile.h"

/*!
 @class
 @abstract 完成分块上传功能
 */
@interface OSSMultipart : OSSObject <NSXMLParserDelegate>

/*!
 @property
 @abstract 记录uploadID
 */
@property (nonatomic, strong)NSMutableString *uploadID;
/*!
 @property
 @abstract 用于存放所有的分块
 */
@property (nonatomic, strong)NSMutableArray *partList;
/*!
 @property
 @abstract 用于xml解析
 */
@property (nonatomic, strong)NSXMLParser *xml;
/*!
 @property
 @abstract 用于存放待上传的数据
 */
@property (nonatomic, strong)NSMutableData *totalData;
/*!
 @property
 @abstract 用于记录文件路径字符串的hash值
 */
@property (nonatomic, strong)NSString *pathHash;
/*!
 @property
 @abstract 用于记录文件的最新修改时间
 */
@property (nonatomic, strong)NSString *modificationDate;
/*!
 @property
 @abstract 用于记录上传进度
 */
@property (nonatomic, strong)NSMutableDictionary *savedPart;
/*!
 @property
 @abstract xml的解析开关
 */
@property (nonatomic)int shouldProcess;
/*!
 @method
 @abstract 初始化
 */
- (instancetype)initWith:(OSSFile *)file;
/*!
 @method
 @abstract 进行分块上传
 */
- (void)uploadWithPath:(NSString *)path withProgressBlock:(void (^)(float))progressBlock withCallback:(void (^)(BOOL, NSError *))errorCallback;

@end
