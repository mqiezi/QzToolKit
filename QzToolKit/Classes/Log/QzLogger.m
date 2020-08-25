//
//  QzLogger.m
//  QzToolKit
//
//  Created by JzProl.m.Qiezi on 2020/8/3.
//  Copyright © 2020 com.mqiezi. All rights reserved.
//

#import "QzLogger.h"
#import <pthread.h>
#import <UIKit/UIKit.h>
#import "QzMacros.h"

/*!
 *  去除获取文件的路径和文件名后缀
 *
 *  @param filePath 文件路径
 *
 *  @return 文件名（无后缀）
 */
OBJC_EXTERN NSString* __QzLogTrimFilePath__(const char* filePath){
    NSString* fileName = [NSString stringWithFormat:@"%s", filePath];
    return  [[fileName lastPathComponent] stringByDeletingPathExtension];
}

OBJC_EXTERN NSString* __QzLogCurrentThread__(void){
    __uint64_t threadId=0;
    if (pthread_threadid_np(0, &threadId)) {
        threadId = pthread_mach_thread_np(pthread_self());
    }
    return [NSString stringWithFormat:@"%lld",threadId];
}

@interface QzLogger()

@property (strong) NSString* logFileName;                    // 日志文件名,包含路径;
@property (assign) int logLevel;                             // 日志打印级别
@property (assign) unsigned long long maxLogSize;            // 最大日志大小
@property (strong) dispatch_queue_t logQueue;                // 打印日志的线程队列
@property (strong) NSMutableArray* logCache;                 // 日志缓存，默认1k条
@property (strong) NSDateFormatter *fFormatter;              // 文件日志格式化
@property (strong) NSDateFormatter *tFormatter;              // 显示日志格式化
@property (strong) NSLock *cacheLock;                        // 缓存锁

@end


@implementation QzLogger

#pragma mark -初始化函数

/**
 * 初始化函数
 * @param fileName 日志文件名,包含路径
 */
- (instancetype)initLogWithName:(NSString *)fileName {
    return [self initLogWithName:fileName logLevel:LOG_LEVEL_ERROR];
}

/**
 * 初始化函数
 * @param fileName 日志文件名,包含路径
 * @param logLevel 日志打印级别
 */
- (instancetype)initLogWithName:(NSString *)fileName logLevel:(int)logLevel {
    return [self initLogWithName:fileName logLevel:logLevel maxLogSize:1048576]; // 默认1M大小
}

/**
 * 初始化函数
 * @param fileName 日志文件名,包含路径
 * @param logLevel 日志打印级别
 * @param maxLogSize 最大日志大小
 */
- (instancetype)initLogWithName:(NSString *)fileName logLevel:(int)logLevel maxLogSize:(unsigned long long)maxLogSize {
    if (self = [super init]) {
        _logFileName = fileName;
        _logLevel = logLevel;
        _maxLogSize = maxLogSize;
        _isShow = YES;
        _isWrite = YES;
        _logQueue = dispatch_queue_create("com.mqiezi.log.queue", DISPATCH_QUEUE_SERIAL);
        _logCache = [NSMutableArray arrayWithCapacity:1024];
        
        _fFormatter = [[NSDateFormatter alloc] init] ;
        [self.fFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        
        _tFormatter = [[NSDateFormatter alloc] init] ;
        [self.tFormatter setDateFormat:@"HH:mm:ss.SSS"];
        
        _cacheLock = [[NSLock alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(writeCache)
                                                     name:UIApplicationWillTerminateNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(writeCache)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc{
    self.logCache = nil;
    self.cacheLock = nil;
    self.fFormatter = nil;
    self.tFormatter = nil;

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    QzDispatchQueueRelease(_logQueue);
}

#pragma mark -日志打印函数

/**
 * 打印debug级别的日志
 * @param format 日志格式化串
 * @param ... 格式化数据
 */
- (void)debug:(NSString *)format, ... {
    if (!self.isWrite && !self.isShow) return;
    va_list args;
    va_start(args, format);
    NSString *logInfo = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    [self writeLog:LOG_LEVEL_DEBUG logInfo:logInfo];
}

/**
 * 打印info级别的日志
 * @param format 日志格式化串
 * @param ... 格式化数据
 */
- (void)info:(NSString *)format, ... {
    if (!self.isWrite && !self.isShow) return;
    va_list args;
    va_start(args, format);
    NSString *logInfo = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    [self writeLog:LOG_LEVEL_INFO logInfo:logInfo];
}

/**
 * 打印warning级别的日志
 * @param format 日志格式化串
 * @param ... 格式化数据
 */
- (void)warn:(NSString *)format, ... {
    if (!self.isWrite && !self.isShow) return;
    va_list args;
    va_start(args, format);
    NSString *logInfo = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    [self writeLog:LOG_LEVEL_WARN logInfo:logInfo];
}

/**
 * 打印error级别的日志
 * @param format 日志格式化串
 * @param ... 格式化数据
 */
- (void)error:(NSString *)format, ... {
    if (!self.isWrite && !self.isShow) return;
    va_list args;
    va_start(args, format);
    NSString *logInfo = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    [self writeLog:LOG_LEVEL_ERROR logInfo:logInfo];
}

/**
 * 打印fatal级别的日志
 * @param format 日志格式化串
 * @param ... 格式化数据
 */
- (void)fatal:(NSString *)format, ...{
    if (!self.isWrite && !self.isShow) return;
    va_list args;
    va_start(args, format);
    NSString *logInfo = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    [self writeLog:LOG_LEVEL_FATAL logInfo:logInfo];
}

/**
 * 写入日志
 * @param logLevel 日志级别
 * @param logInfo  日志内容
 */
- (void)writeLog:(int)logLevel logInfo:(NSString *)logInfo {
    
    // 如果日志级别不够,不要打印日志了
    if (self.logLevel > logLevel) return;
    // 如果日志不需要显示或存储，不要打印日志了
    if (!self.isWrite && !self.isShow) return;
    
    // 在日志打印队列中处理日志打印
    @QzWeakObj(self);
    dispatch_async(self.logQueue, ^{
        @QzStrongObj(self);
        if(!selfStrong){
            return;
        }
        // 格式化日志
        NSDate *now = [NSDate date];

        NSString* fformatInfo = [NSString stringWithFormat:@"[%@]<%@>%@\n", [selfStrong.fFormatter stringFromDate:now], [QzLogger getLogLevelName:logLevel], logInfo];
        
        NSString* tformatInfo = [NSString stringWithFormat:@"[%@]<%@>%@\n", [selfStrong.tFormatter stringFromDate:now], [QzLogger getLogLevelName:logLevel], logInfo];
        
        if (selfStrong.isWrite) {
            [selfStrong.cacheLock lock];
            if(selfStrong.logCache.count<1024){
                [selfStrong.logCache addObject:fformatInfo];
            }else{
                NSString* cachedLog =[selfStrong.logCache componentsJoinedByString:@""];
                [selfStrong writeFileWithContent:cachedLog];
                [selfStrong.logCache removeAllObjects];
            }
            [selfStrong.cacheLock unlock];
        }
        
        if (selfStrong.isShow) {
            printf("[Qz]%s",[tformatInfo UTF8String]);
//            NSLog(@"[Qz]%s",[tformatInfo UTF8String]);
        }

    });
}

#pragma mark - tools

-(void)writeCache{
    @QzWeakObj(self);
    dispatch_async(self.logQueue, ^{
        @QzStrongObj(self);
        if(!selfStrong){
            return;
        }
        [selfStrong.cacheLock lock];
        NSString* cachedLog =[selfStrong.logCache componentsJoinedByString:@""];
        [selfStrong writeFileWithContent:cachedLog];
        [selfStrong.logCache removeAllObjects];
        [selfStrong.cacheLock unlock];
    });
}

/**
 * 写入文件
 * @param content  日志内容
 */
- (void)writeFileWithContent:(NSString *)content {
    
    if(!content || content.length<1){
        return;
    }
    
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    
        // 如果文件不存在，创建文件
    if (![fileMgr fileExistsAtPath:self.logFileName]) {
        [fileMgr createFileAtPath:self.logFileName contents:nil attributes:nil];
    }
    
        // 获取文件大小
    NSDictionary *fileAttributes = [fileMgr attributesOfItemAtPath:self.logFileName error:nil];
    unsigned long long fileSize = [fileAttributes fileSize];
    
    if (fileSize >= self.maxLogSize) {
        NSString *newFileName = [NSString stringWithFormat:@"%@.backup", self.logFileName];
        if ([fileMgr fileExistsAtPath:newFileName]) {
            [fileMgr removeItemAtPath:newFileName error:nil];
        }
            // 文件更名
        [fileMgr moveItemAtPath:self.logFileName toPath:newFileName error:nil];
            // 重新创建新文件
        [fileMgr createFileAtPath:self.logFileName contents:nil attributes:nil];
    }
    
        // 写入文件
    NSFileHandle *fileHdr = [NSFileHandle fileHandleForWritingAtPath:self.logFileName];
    [fileHdr seekToEndOfFile];
    [fileHdr writeData:[content dataUsingEncoding:NSUTF8StringEncoding]];
    [fileHdr closeFile];
}

/**
 * 返回指定日志级别的级别描述
 */
+ (NSString *)getLogLevelName:(int)logLevel {
    switch(logLevel) {
        case LOG_LEVEL_DEBUG:
            return @"D";
        case LOG_LEVEL_FATAL:
            return @"F";
        case LOG_LEVEL_INFO:
            return @"I";
        case LOG_LEVEL_WARN:
            return @"W";
        case LOG_LEVEL_ERROR:
            return @"E";
        default:
            return @"N/A";
    }
}

/**
 * 返回指定日志级别
 * @param levelName 日志级别名
 * @return 返回日志级别名对应的日志级别
 */
+ (int) getLogLevel:(NSString *)levelName defLevel:(int)defLevel {
    if (levelName == nil) return defLevel;
    
    if ([@"D" isEqualToString:levelName]) return LOG_LEVEL_DEBUG;
    if ([@"I" isEqualToString:levelName]) return LOG_LEVEL_INFO;
    if ([@"W" isEqualToString:levelName]) return LOG_LEVEL_WARN;
    if ([@"E" isEqualToString:levelName]) return LOG_LEVEL_ERROR;
    if ([@"F" isEqualToString:levelName]) return LOG_LEVEL_FATAL;
    return defLevel;
}

@end


@implementation QzLogManager

+ (instancetype) sharedInstance{
    static QzLogManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance =[[self alloc] init];
    });
    return _sharedInstance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static QzLogManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [super allocWithZone:zone];
    });
    return _sharedInstance;
}

-(instancetype)init{
    if(self=[super init]){
        [self initLogger];
    }
    return self;
}

/**
 * 初始化日志
 */
- (void) initLogger {
    NSDictionary *dic = [[NSBundle mainBundle] infoDictionary];
    
        // 1. 获取日志文件名，如果没有配置，使用SDK名称
    NSString *logName = [dic objectForKey:@"AppLogFileName"];
    
    if (!logName) {
        logName = @"Qz";
    }
    
        // 2. 获取日志路径，把日志放在cache目录下面，并得到包含路径日志文件名
    NSArray *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [cachePaths objectAtIndex:0];
    NSString *logFileName = [NSString stringWithFormat:@"%@/%@.log", cachePath, logName];
    
        // 3. 日志打印级别
    NSString *sLogLevel = [dic objectForKey:@"AppLogLevel"];
    int logLevel = [QzLogger getLogLevel:sLogLevel defLevel:LOG_LEVEL_DEBUG];
    
        // 4. 最大日志大小
    unsigned long long maxLogSize = [[dic objectForKey:@"AppMaxLogLevel"] unsignedLongLongValue];
    if (0 == maxLogSize) {
        maxLogSize = 1048576;
    }
    
    [self initLogger:logFileName byLogLevel:logLevel andMaxLogSize:maxLogSize];
}

/**
 * 初始化日志
 */
- (void) initLogger:(NSString *)logFileName byLogLevel:(int)logLevel andMaxLogSize:(unsigned long long)maxLogSize {
    _logger = [[QzLogger alloc] initLogWithName:logFileName logLevel:logLevel maxLogSize:maxLogSize];
}

@end

