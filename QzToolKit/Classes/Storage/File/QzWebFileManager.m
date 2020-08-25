//
//  QzWebFileManager.h
//  QzToolKit
//
//  Created by JzProl.m.Qiezi on 2020/8/3.
//  Copyright © 2020 com.mqiezi. All rights reserved.
//

#import "QzWebFileManager.h"
#import "QzFileManager.h"
#import "QzMacros.h"
#import "QzCryptor.h"
#import "QzLogger.h"

#import <UIKit/UIKit.h>

@interface QzWebFileManager ()
@property (strong, nonatomic) NSString *diskCachePath;
@property (strong, nonatomic) NSFileManager *fileManager;
@property (QzDispatchQueueSetterSementics, nonatomic) dispatch_queue_t ioQueue;
@end

static const NSInteger kQzFileDefaultCacheMaxCacheAge = 60 * 60 * 24 * 7; // 1 week

@implementation QzWebFileManager

+(instancetype)sharedInstance{
    static QzWebFileManager* sharedInstance=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance=[[self alloc] init];
    });
    return sharedInstance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static QzWebFileManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [super allocWithZone:zone];
    });
    return _sharedInstance;
}

- (instancetype)init {
    if ((self = [super init])) {
        NSString *path = [self makeDiskCachePath:@"cache"];
            // Init the disk cache
        if (path != nil) {
            NSString *fullNamespace = [@"com.mqiezi." stringByAppendingString:@"cache"];
                // /Library/Caches/Qz/file/cache/com.mqiezi.cache
            _diskCachePath = [path stringByAppendingPathComponent:fullNamespace];
            [QzFileManager makeDirectory:_diskCachePath];
        } else {
            NSString *path = [self makeDiskCachePath:@"cache"];
            _diskCachePath = path;
        }
        _ioQueue = dispatch_queue_create("com.mqiezi.file.io", DISPATCH_QUEUE_SERIAL);
            // Init default values
        _maxCacheAge = kQzFileDefaultCacheMaxCacheAge;
        dispatch_sync(_ioQueue, ^{
            _fileManager = [NSFileManager new];
        });
        
#if TARGET_OS_IOS
            // Subscribe to app events
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(cleanDisk)
                                                     name:UIApplicationWillTerminateNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(backgroundCleanDisk)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
#endif
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    QzDispatchQueueRelease(_ioQueue);
}


-(NSString *)makeDiskCachePath:(NSString*)fullNamespace{
    NSString* cachePath=[[QzFileManager fileCacheDirectory] stringByAppendingPathComponent:fullNamespace];
    
    [QzFileManager makeDirectory:cachePath];
    return cachePath;
}

- (NSString *)cacheKeyForURL:(NSURL *)url {
    if (!url) {
        return @"";
    }
    return [url absoluteString];
}

- (NSString *)cachedFileNameForKey:(NSString *)key {
    if(!key || [key length]<1){
        return @"";
    }
    
    NSData* keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
    NSString *filename = [NSString stringWithFormat:@"%@%@",
                          [QzCryptor md5String:keyData], [[key pathExtension] isEqualToString:@""] ? @"" : [NSString stringWithFormat:@".%@", [key pathExtension]]];
    return filename;
}

- (NSString *)cachePathForKey:(NSString *)key inPath:(NSString *)path {
    NSString *filename = [self cachedFileNameForKey:key];
    return [path stringByAppendingPathComponent:filename];
}

- (NSString *)defaultCachePathForKey:(NSString *)key {
    return [self cachePathForKey:key inPath:self.diskCachePath];
}

- (BOOL)diskFileExistsWithKey:(NSString *)key {
    BOOL exists = NO;
    
        // this is an exception to access the filemanager on another queue than ioQueue, but we are using the shared instance
        // from apple docs on NSFileManager: The methods of the shared NSFileManager object can be called from multiple threads safely.
    exists = [[NSFileManager defaultManager] fileExistsAtPath:[self defaultCachePathForKey:key]];
    
        // fallback because of https://github.com/rs/SDWebImage/pull/976 that added the extension to the disk file name
        // checking the key with and without the extension
    if (!exists) {
        exists = [[NSFileManager defaultManager] fileExistsAtPath:[[self defaultCachePathForKey:key] stringByDeletingPathExtension]];
    }
    
    return exists;
}

- (void)diskFileExistsWithKey:(NSString *)key completion:(QzWebFileCheckCacheCompletionBlock)completionBlock {
    @QzWeakObj(self);
    dispatch_async(_ioQueue, ^{
        @QzStrongObj(self);
        BOOL exists = [selfStrong.fileManager fileExistsAtPath:[selfStrong defaultCachePathForKey:key]];
        
            // fallback because of https://github.com/rs/SDWebImage/pull/976 that added the extension to the disk file name
            // checking the key with and without the extension
        if (!exists) {
            exists = [selfStrong.fileManager fileExistsAtPath:[[selfStrong defaultCachePathForKey:key] stringByDeletingPathExtension]];
        }
        
        if (completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(exists);
            });
        }
    });
}

- (BOOL)diskFileExistsForURL:(NSURL *)url {
    NSString *key = [self cacheKeyForURL:url];
    BOOL exists = NO;
    
        // this is an exception to access the filemanager on another queue than ioQueue, but we are using the shared instance
        // from apple docs on NSFileManager: The methods of the shared NSFileManager object can be called from multiple threads safely.
    exists = [[NSFileManager defaultManager] fileExistsAtPath:[self defaultCachePathForKey:key]];
    
        // fallback because of https://github.com/rs/SDWebImage/pull/976 that added the extension to the disk file name
        // checking the key with and without the extension
    if (!exists) {
        exists = [[NSFileManager defaultManager] fileExistsAtPath:[[self defaultCachePathForKey:key] stringByDeletingPathExtension]];
    }
    
    return exists;
    return [self diskFileExistsWithKey:key];
}

- (void)diskFileExistsForURL:(NSURL *)url
                  completion:(QzWebFileCheckCacheCompletionBlock)completionBlock {
    NSString *key = [self cacheKeyForURL:url];
    
    [self diskFileExistsWithKey:key completion:^(BOOL isInDiskCache) {
            // the completion block of checkDiskCacheForImageWithKey:completion: is always called on the main queue, no need to further dispatch
        if (completionBlock) {
            completionBlock(isInDiskCache);
        }
    }];
    
    @QzWeakObj(self);
    dispatch_async(_ioQueue, ^{
        @QzStrongObj(self);
        BOOL exists = [selfStrong.fileManager fileExistsAtPath:[selfStrong defaultCachePathForKey:key]];
        
            // fallback because of https://github.com/rs/SDWebImage/pull/976 that added the extension to the disk file name
            // checking the key with and without the extension
        if (!exists) {
            exists = [selfStrong.fileManager fileExistsAtPath:[[selfStrong defaultCachePathForKey:key] stringByDeletingPathExtension]];
        }
        
        if (completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(exists);
            });
        }
    });
}

- (void)downloadFileWithUrl:(NSURL *)url
                 completion:(QzWebFileDownloadCompleteBlock)completionBlock{
    NSString *key = [self cacheKeyForURL:url];
    @QzWeakObj(self);
    dispatch_async(self.ioQueue, ^{
        @QzStrongObj(self);
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        NSURLSessionDownloadTask *downloadTask = [[NSURLSession sharedSession] downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            if(error){
                if(completionBlock){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completionBlock(error);
                    });
                }
                return;
            }
            
            if (![selfStrong.fileManager fileExistsAtPath:selfStrong.diskCachePath]) {
                [selfStrong.fileManager createDirectoryAtPath:selfStrong.diskCachePath withIntermediateDirectories:YES attributes:nil error:NULL];
            }
            
            NSString* filePath =[location path];
                // get cache Path for file key
            NSString *cachePathForKey = [self defaultCachePathForKey:key];
            NSError* fileError;
            if([selfStrong.fileManager fileExistsAtPath:cachePathForKey]){
                [selfStrong.fileManager removeItemAtPath:cachePathForKey error:nil];
            }
            
            if (![selfStrong.fileManager moveItemAtPath:filePath toPath:cachePathForKey error:&fileError]){
                QzLogI(@"from:%@ to:%@",filePath,cachePathForKey);
                QzLogI(@"Unable to move file: %@", [fileError localizedDescription]);
                if(completionBlock){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completionBlock(fileError);
                    });
                }
                return;
            }
            
            if(completionBlock){
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionBlock(nil);
                });
            }
        }];
        [downloadTask resume];
    });
}

- (NSString *)filePathFromDiskCacheForURL:(NSURL *)url{
    NSString *key = [self cacheKeyForURL:url];
    return [self filePathFromDiskCacheForKey:key];
}

- (NSString *)filePathFromDiskCacheForKey:(NSString *)key{
    return [self cachePathForKey:key inPath:self.diskCachePath];
}

- (void)removeFileForKey:(NSString *)key {
    [self removeFileForKey:key withCompletion:nil];
}

- (void)removeFileForKey:(NSString *)key withCompletion:(QzWebFileNoParamsBlock)completion {
    [self removeFileForKey:key fromDisk:YES withCompletion:completion];
}

- (void)removeFileForKey:(NSString *)key fromDisk:(BOOL)fromDisk {
    [self removeFileForKey:key fromDisk:fromDisk withCompletion:nil];
}

- (void)removeFileForKey:(NSString *)key fromDisk:(BOOL)fromDisk withCompletion:(QzWebFileNoParamsBlock)completion {
    
    if (key == nil) {
        return;
    }
    
    if (fromDisk) {
        @QzWeakObj(self);
        dispatch_async(self.ioQueue, ^{
            @QzStrongObj(self);
            [selfStrong.fileManager removeItemAtPath:[self defaultCachePathForKey:key] error:nil];
            
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion();
                });
            }
        });
    } else if (completion){
        completion();
    }
    
}

- (void)clearDisk {
    [self clearDiskOnCompletion:nil];
}

- (void)clearDiskOnCompletion:(QzWebFileNoParamsBlock)completion
{
    @QzWeakObj(self);
    dispatch_async(self.ioQueue, ^{
        @QzStrongObj(self);
        [selfStrong.fileManager removeItemAtPath:self.diskCachePath error:nil];
        [selfStrong.fileManager createDirectoryAtPath:self.diskCachePath
                          withIntermediateDirectories:YES
                                           attributes:nil
                                                error:NULL];
        
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion();
            });
        }
    });
}

- (void)cleanDisk {
    [self cleanDiskWithCompletionBlock:nil];
}

- (void)cleanDiskWithCompletionBlock:(QzWebFileNoParamsBlock)completionBlock {
    @QzWeakObj(self);
    dispatch_async(self.ioQueue, ^{
        @QzStrongObj(self);
        NSURL *diskCacheURL = [NSURL fileURLWithPath:self.diskCachePath isDirectory:YES];
        NSArray *resourceKeys = @[NSURLIsDirectoryKey, NSURLContentModificationDateKey, NSURLTotalFileAllocatedSizeKey];
        
            // This enumerator prefetches useful properties for our cache files.
        NSDirectoryEnumerator *fileEnumerator = [selfStrong.fileManager enumeratorAtURL:diskCacheURL
                                                             includingPropertiesForKeys:resourceKeys
                                                                                options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                           errorHandler:NULL];
        
        NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceNow:-selfStrong.maxCacheAge];
        NSMutableDictionary *cacheFiles = [NSMutableDictionary dictionary];
        NSUInteger currentCacheSize = 0;
        
            // Enumerate all of the files in the cache directory.  This loop has two purposes:
            //
            //  1. Removing files that are older than the expiration date.
            //  2. Storing file attributes for the size-based cleanup pass.
        NSMutableArray *urlsToDelete = [[NSMutableArray alloc] init];
        for (NSURL *fileURL in fileEnumerator) {
            NSDictionary *resourceValues = [fileURL resourceValuesForKeys:resourceKeys error:NULL];
            
                // Skip directories.
            if ([resourceValues[NSURLIsDirectoryKey] boolValue]) {
                continue;
            }
            
                // Remove files that are older than the expiration date;
            NSDate *modificationDate = resourceValues[NSURLContentModificationDateKey];
            if ([[modificationDate laterDate:expirationDate] isEqualToDate:expirationDate]) {
                [urlsToDelete addObject:fileURL];
                continue;
            }
            
                // Store a reference to this file and account for its total size.
            NSNumber *totalAllocatedSize = resourceValues[NSURLTotalFileAllocatedSizeKey];
            currentCacheSize += [totalAllocatedSize unsignedIntegerValue];
            [cacheFiles setObject:resourceValues forKey:fileURL];
        }
        
        for (NSURL *fileURL in urlsToDelete) {
            [selfStrong.fileManager removeItemAtURL:fileURL error:nil];
        }
        
            // If our remaining disk cache exceeds a configured maximum size, perform a second
            // size-based cleanup pass.  We delete the oldest files first.
        if (selfStrong.maxCacheSize > 0 && currentCacheSize > selfStrong.maxCacheSize) {
                // Target half of our maximum cache size for this cleanup pass.
            const NSUInteger desiredCacheSize = selfStrong.maxCacheSize / 2;
            
                // Sort the remaining cache files by their last modification time (oldest first).
            NSArray *sortedFiles = [cacheFiles keysSortedByValueWithOptions:NSSortConcurrent
                                                            usingComparator:^NSComparisonResult(id obj1, id obj2) {
                return [obj1[NSURLContentModificationDateKey] compare:obj2[NSURLContentModificationDateKey]];
            }];
            
                // Delete files until we fall below our desired cache size.
            for (NSURL *fileURL in sortedFiles) {
                if ([selfStrong.fileManager removeItemAtURL:fileURL error:nil]) {
                    NSDictionary *resourceValues = cacheFiles[fileURL];
                    NSNumber *totalAllocatedSize = resourceValues[NSURLTotalFileAllocatedSizeKey];
                    currentCacheSize -= [totalAllocatedSize unsignedIntegerValue];
                    
                    if (currentCacheSize < desiredCacheSize) {
                        break;
                    }
                }
            }
        }
        if (completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock();
            });
        }
    });
}

- (void)backgroundCleanDisk {
    Class UIApplicationClass = NSClassFromString(@"UIApplication");
    if(!UIApplicationClass || ![UIApplicationClass respondsToSelector:@selector(sharedApplication)]) {
        return;
    }
    UIApplication *application = [UIApplication performSelector:@selector(sharedApplication)];
    __block UIBackgroundTaskIdentifier bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
            // Clean up any unfinished task business by marking where you
            // stopped or ending the task outright.
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    
        // Start the long-running task and return immediately.
    [self cleanDiskWithCompletionBlock:^{
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
}

- (NSUInteger)getSize {
    __block NSUInteger size = 0;
    @QzWeakObj(self);
    dispatch_sync(self.ioQueue, ^{
        @QzStrongObj(self);
        NSDirectoryEnumerator *fileEnumerator = [_fileManager enumeratorAtPath:selfStrong.diskCachePath];
        for (NSString *fileName in fileEnumerator) {
            NSString *filePath = [selfStrong.diskCachePath stringByAppendingPathComponent:fileName];
            NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
            size += [attrs fileSize];
        }
    });
    return size;
}

- (NSUInteger)getDiskCount {
    __block NSUInteger count = 0;
    @QzWeakObj(self);
    dispatch_sync(self.ioQueue, ^{
        @QzStrongObj(self);
        NSDirectoryEnumerator *fileEnumerator = [selfStrong.fileManager enumeratorAtPath:selfStrong.diskCachePath];
        count = [[fileEnumerator allObjects] count];
    });
    return count;
}

- (void)calculateSizeWithCompletionBlock:(QzWebFileCalculateSizeBlock)completionBlock {
    NSURL *diskCacheURL = [NSURL fileURLWithPath:self.diskCachePath isDirectory:YES];
    
    @QzWeakObj(self);
    dispatch_async(self.ioQueue, ^{
        @QzStrongObj(self);
        NSUInteger fileCount = 0;
        NSUInteger totalSize = 0;
        
        NSDirectoryEnumerator *fileEnumerator = [selfStrong.fileManager enumeratorAtURL:diskCacheURL
                                                             includingPropertiesForKeys:@[NSFileSize]
                                                                                options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                           errorHandler:NULL];
        
        for (NSURL *fileURL in fileEnumerator) {
            NSNumber *fileSize;
            [fileURL getResourceValue:&fileSize forKey:NSURLFileSizeKey error:NULL];
            totalSize += [fileSize unsignedIntegerValue];
            fileCount += 1;
        }
        
        if (completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(fileCount, totalSize);
            });
        }
    });
}
@end
