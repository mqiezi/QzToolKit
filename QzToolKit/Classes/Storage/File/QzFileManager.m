//
//  QzFileManager.m
//  QzToolKit
//
//  Created by JzProl.m.Qiezi on 2020/8/3.
//  Copyright © 2020 com.mqiezi. All rights reserved.
//

#import "QzFileManager.h"


#define QZ_CACHE_ROOT_DIR   @"Qz"
#define QZ_CACHE_IMAGE_DIR  @"image"
#define QZ_CACHE_FILE_DIR   @"file"

@implementation QzFileManager

+(BOOL)makeDirectory:(NSString*)path{
    if(!path){
        return NO;
    }
    NSFileManager * fileManager=[NSFileManager defaultManager];
    BOOL isDir=NO;
    BOOL existed = [fileManager fileExistsAtPath:path isDirectory:&isDir];
    if(!(isDir == YES && existed == YES)){
        BOOL isSuccess=[fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        if (!isSuccess) {
            return NO;
        }
    }
    return YES;
}

+(BOOL)clearDirectory:(NSString*)path{
    
    NSFileManager * fileManager=[NSFileManager defaultManager];
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:path error:NULL];
    NSEnumerator *e = [contents objectEnumerator];
    NSString *filename;
    while ((filename = [e nextObject])) {
        [fileManager removeItemAtPath:[path stringByAppendingPathComponent:filename] error:NULL];
    }
    return YES;
}


+(BOOL)deleteDirectory:(NSString*)path{
    NSFileManager * fileManager=[NSFileManager defaultManager];
    return [fileManager removeItemAtPath:path error:nil];
}


+(NSString*)rootDirectory:(NSString*)root{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDir = [paths firstObject];
    //Library/Caches/Qz/
    NSString *rootDir = [cachesDir stringByAppendingPathComponent: (root && ([root length]>0))? root:QZ_CACHE_ROOT_DIR];
    if(![QzFileManager makeDirectory:rootDir]){
        return nil;
    }
    return rootDir;
}

#pragma mark - image

+(NSString*)imageCacheDirectory{
    NSString *rootDir = [QzFileManager rootDirectory:nil];
        // Library/Caches/Qz/image
    NSString *imageDir = [rootDir stringByAppendingPathComponent:QZ_CACHE_IMAGE_DIR];
    
    if(![QzFileManager makeDirectory:imageDir]){
        return nil;
    }
    
    return imageDir;
}


+(BOOL)clearImageCacheDirectory{
    NSString* imageDir=[QzFileManager imageCacheDirectory];
        // Library/Caches/Qz/image
    return [QzFileManager clearDirectory:imageDir];
}

+(BOOL)deleteImageCacheDirectory{
    NSString* imageDir=[QzFileManager imageCacheDirectory];
        // Library/Caches/Qz/image
    return [QzFileManager deleteDirectory:imageDir];
}

#pragma mark - file

+(NSString*)fileCacheDirectory{
    NSString *rootDir = [QzFileManager rootDirectory:nil];
        // Library/Caches/Qz/file
    NSString *videoDir = [rootDir stringByAppendingPathComponent:QZ_CACHE_FILE_DIR];
    if(![QzFileManager makeDirectory:videoDir]){
        return nil;
    }
    
    return videoDir;
}

+(BOOL)clearFileCacheDirectory{
    NSString* fileDir=[QzFileManager fileCacheDirectory];
        // Library/Caches/Qz/file
    return [QzFileManager clearDirectory:fileDir];
}

+(BOOL)deleteFileCacheDirectory{
    NSString* fileDir=[QzFileManager fileCacheDirectory];
        // Library/Caches/Qz/file
    return [QzFileManager deleteDirectory:fileDir];
}

@end

