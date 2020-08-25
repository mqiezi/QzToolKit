//
//  QzFileManager.h
//  QzToolKit
//
//  Created by JzProl.m.Qiezi on 2020/8/3.
//  Copyright © 2020 com.mqiezi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 此类定义关于文件的常用操作
 *
 */
@interface QzFileManager : NSObject

/**
 创建路径
 
 @param path 路径
 @return 成功返回YES；否则返回NO
 */
+(BOOL)makeDirectory:(NSString*)path;

/**
 清理路径
 
 @param path 路径
 @return 成功返回YES；否则返回NO
 */
+(BOOL)clearDirectory:(NSString*)path;

/**
 删除路径
 
 @param path 路径
 @return 成功返回YES；否则返回NO
 */
+(BOOL)deleteDirectory:(NSString*)path;

#pragma mark -
/**
 缓存根目录
 
 @param root 根目录名称
 @return 缓存根目录
 */
+(NSString*)rootDirectory:(nullable NSString*)root;

#pragma mark - image

/**
 缓存图片目录
 无则创建，有则返回
 
 @return 缓存图片目录
 */
+(NSString*)imageCacheDirectory;


/**
 清空缓存图片目录
 
 @return 成功返回YES；否则返回NO
 */
+(BOOL)clearImageCacheDirectory;


/**
 删除缓存图片目录
 
 @return 成功返回YES；否则返回NO
 */
+(BOOL)deleteImageCacheDirectory;

#pragma mark - file
/**
 缓存文件目录
 无则创建，有则返回
 
 @return 缓存文件目录
 */
+(NSString*)fileCacheDirectory;

/**
 清空缓存文件目录
 
 @return 成功返回YES；否则返回NO
 */
+(BOOL)clearFileCacheDirectory;


/**
 删除缓存文件目录
 
 @return 成功返回YES；否则返回NO
 */
+(BOOL)deleteFileCacheDirectory;


@end

NS_ASSUME_NONNULL_END





