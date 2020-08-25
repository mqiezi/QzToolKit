//
//  QzWebFileManager.h
//  QzToolKit
//
//  Created by JzProl.m.Qiezi on 2020/8/3.
//  Copyright © 2020 com.mqiezi. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

typedef void(^QzWebFileCheckCacheCompletionBlock)(BOOL isInCache);
typedef void(^QzWebFileCalculateSizeBlock)(NSUInteger fileCount, NSUInteger totalSize);
typedef void(^QzWebFileNoParamsBlock)(void);
typedef void (^QzWebFileDownloadCompleteBlock)(NSError * _Nullable error);

@interface QzWebFileManager : NSObject

@property (assign, nonatomic) NSInteger maxCacheAge;
@property (assign, nonatomic) NSUInteger maxCacheSize;

+ (instancetype)sharedInstance;

- (BOOL)diskFileExistsWithKey:(NSString *)key;
- (void)diskFileExistsWithKey:(NSString *)key completion:(QzWebFileCheckCacheCompletionBlock)completionBlock ;
- (BOOL)diskFileExistsForURL:(NSURL *)url;
- (void)diskFileExistsForURL:(NSURL *)url
                  completion:(QzWebFileCheckCacheCompletionBlock)completionBlock;

- (NSString *)cacheKeyForURL:(NSURL *)url;
- (NSString *)defaultCachePathForKey:(NSString *)key;

- (void)downloadFileWithUrl:(NSURL *)url
                 completion:(QzWebFileDownloadCompleteBlock)completionBlock;

- (NSString *)filePathFromDiskCacheForURL:(NSURL *)url;
- (NSString *)filePathFromDiskCacheForKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
