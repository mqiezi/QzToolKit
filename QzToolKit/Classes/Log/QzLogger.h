//
//  QzLogger.h
//  QzToolKit
//
//  Created by JzProl.m.Qiezi on 2020/8/3.
//  Copyright © 2020 com.mqiezi. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * 日志级别
 * DEBUG    100
 * INFO     200
 * WARNING  300
 * ERROR    400
 * FATAL    500
 */
#define LOG_LEVEL_DEBUG     100
#define LOG_LEVEL_INFO      200
#define LOG_LEVEL_WARN      300
#define LOG_LEVEL_ERROR     400
#define LOG_LEVEL_FATAL     500

@interface QzLogger : NSObject

/**
 * 日志是否在调试窗口显示
 */
@property (assign) BOOL isShow;

/**
 * 日志是否写入到文件
 */
@property (assign) BOOL isWrite;

#pragma mark - init

/**
 * 初始化函数
 * @param fileName 日志文件名,包含路径
 *
 */
- (instancetype)initLogWithName:(NSString *)fileName ;

/**
 * 初始化函数
 * @param fileName 日志文件名,包含路径
 * @param logLevel 日志打印级别
 */
- (instancetype)initLogWithName:(NSString *)fileName logLevel:(int)logLevel ;

/**
 * 初始化函数
 * @param fileName 日志文件名,包含路径
 * @param logLevel 日志打印级别
 * @param maxLogSize 最大日志大小
 */
- (instancetype)initLogWithName:(NSString *)fileName logLevel:(int)logLevel maxLogSize:(unsigned long long)maxLogSize ;

#pragma mark - print

/**
 * 打印debug级别的日志
 * @param format 日志格式化串
 * @param ... 格式化数据
 */
- (void)debug:(NSString *)format, ... ;

/**
 * 打印info级别的日志
 * @param format 日志格式化串
 * @param ... 格式化数据
 */
- (void)info:(NSString *)format, ... ;

/**
 * 打印warning级别的日志
 * @param format 日志格式化串
 * @param ... 格式化数据
 */
- (void)warn:(NSString *)format, ... ;

/**
 * 打印error级别的日志
 * @param format 日志格式化串
 * @param ... 格式化数据
 */
- (void)error:(NSString *)format, ... ;

/**
 * 打印fatal级别的日志
 * @param format 日志格式化串
 * @param ... 格式化数据
 */
- (void)fatal:(NSString *)format, ... ;

#pragma mark - tools

/**
 * 返回指定日志级别的级别描述
 */
+ (NSString *)getLogLevelName:(int)logLevel ;

/**
 * 返回指定日志级别
 * @param levelName 日志级别名
 * @return 返回日志级别名对应的日志级别
 */
+ (int)getLogLevel:(NSString *)levelName defLevel:(int)defLevel ;


@end


/**
 * 日志管理器
 */
@interface QzLogManager : NSObject

/**
 * 日志打印对象
 */
@property (strong) QzLogger* logger;

/**
 * 单例
 */
+ (instancetype) sharedInstance ;

/**
 * 初始化日志
 */
- (void) initLogger ;

/**
 * 初始化日志
 * @param logFileName 日志文件名,包含路径
 * @param logLevel 日志打印级别
 * @param maxLogSize 最大日志大小
 */
- (void) initLogger:(NSString *)logFileName byLogLevel:(int)logLevel andMaxLogSize:(unsigned long long)maxLogSize ;

@end

#pragma mark - Macros

#define QzLOGGER [[QzLogManager sharedInstance] logger]

#define Qz_LOG_NEED_SHOW_FILE_LINE
    //#define Qz_LOG_NEED_SHOW_FUNC

OBJC_EXTERN NSString* __QzLogTrimFilePath__(const char* filePath);
OBJC_EXTERN NSString* __QzLogCurrentThread__(void);

#ifdef Qz_LOG_NEED_SHOW_FILE_LINE

    #ifdef Qz_LOG_NEED_SHOW_FUNC

        #define QzLogD(fmt, ...) [QzLOGGER debug:(@"[%@] [%@:%d] %s " fmt),__QzLogCurrentThread__(),__QzLogTrimFilePath__(__FILE__),__LINE__,__func__,##__VA_ARGS__]

        #define QzLogI(fmt, ...) [QzLOGGER info:(@"[%@] [%@:%d] %s " fmt),__QzLogCurrentThread__(),__QzLogTrimFilePath__(__FILE__),__LINE__,__func__,##__VA_ARGS__]

        #define QzLogW(fmt, ...) [QzLOGGER warn:(@"[%@] [%@:%d] %s " fmt),__QzLogCurrentThread__(),__QzLogTrimFilePath__(__FILE__),__LINE__,__func__,##__VA_ARGS__]

        #define QzLogE(fmt, ...) [QzLOGGER error:(@"[%@][%@:%d] %s " fmt),__QzLogCurrentThread__(),__QzLogTrimFilePath__(__FILE__),__LINE__,__func__,##__VA_ARGS__]

        #define QzLogF(fmt, ...) [QzLOGGER fatal:(@"[%@] [%@:%d] %s " fmt),__QzLogCurrentThread__(),__QzLogTrimFilePath__(__FILE__),__LINE__,__func__,##__VA_ARGS__]

    #else

        #define QzLogD(fmt, ...) [QzLOGGER debug:(@"[%@] [%@:%d] " fmt),__QzLogCurrentThread__(),__QzLogTrimFilePath__(__FILE__),__LINE__,##__VA_ARGS__]

        #define QzLogI(fmt, ...) [QzLOGGER info:(@"[%@] [%@:%d] " fmt),__QzLogCurrentThread__(),__QzLogTrimFilePath__(__FILE__),__LINE__,##__VA_ARGS__]

        #define QzLogW(fmt, ...) [QzLOGGER warn:(@"[%@] [%@:%d] " fmt),__QzLogCurrentThread__(),__QzLogTrimFilePath__(__FILE__),__LINE__,##__VA_ARGS__]

        #define QzLogE(fmt, ...) [QzLOGGER error:(@"[%@] [%@:%d] " fmt),__QzLogCurrentThread__(),__QzLogTrimFilePath__(__FILE__),__LINE__,##__VA_ARGS__]

        #define QzLogF(fmt, ...) [QzLOGGER fatal:(@"[%@] [%@:%d] " fmt),__QzLogCurrentThread__(),__QzLogTrimFilePath__(__FILE__),__LINE__,##__VA_ARGS__]

    #endif /*Qz_LOG_NEED_SHOW_FUNC*/

#else

    #ifdef Qz_LOG_NEED_SHOW_FUNC

        #define QzLogD(fmt, ...) [QzLOGGER debug:(@"[%@] %s " fmt),__QzLogCurrentThread__(), __func__,##__VA_ARGS__]

        #define QzLogI(fmt, ...) [QzLOGGER info:(@"[%@] %s " fmt),__QzLogCurrentThread__(), __func__,##__VA_ARGS__]

        #define QzLogW(fmt, ...) [QzLOGGER warn:(@"[%@] %s " fmt),__QzLogCurrentThread__(), __func__,##__VA_ARGS__]

        #define QzLogE(fmt, ...) [QzLOGGER error:(@"[%@] %s " fmt),__QzLogCurrentThread__(), __func__,##__VA_ARGS__]

        #define QzLogF(fmt, ...) [QzLOGGER fatal:(@"[%@] %s " fmt),__QzLogCurrentThread__(), __func__,##__VA_ARGS__]

    #else

        #define QzLogD(fmt, ...) [QzLOGGER debug:fmt, ##__VA_ARGS__]

        #define QzLogI(fmt, ...) [QzLOGGER info:fmt, ##__VA_ARGS__]

        #define QzLogW(fmt, ...) [QzLOGGER warn:fmt, ##__VA_ARGS__]

        #define QzLogE(fmt, ...) [QzLOGGER error:fmt, ##__VA_ARGS__]

        #define QzLogF(fmt, ...) [QzLOGGER fatal:fmt, ##__VA_ARGS__]

    #endif /*Qz_LOG_NEED_SHOW_FUNC*/

#endif /*Qz_LOG_NEED_SHOW_FILE_LINE*/
