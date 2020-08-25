//
//  QzExtension.h
//  QzToolKit
//
//  Created by JzProl.m.Qiezi on 2020/8/4.
//  Copyright © 2020 com.mqiezi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QzExtension : NSObject

#pragma mark - json
+ (NSString*)jsonObjectToJsonString:(NSObject*)object;
+ (NSObject*)jsonStringToJsonObject:(NSString*)string;

+ (NSObject*)jsonDataToJsonObject:(NSData*)data;
+ (NSString*)jsonDataToJsonString:(NSData*)data;

#pragma mark - urlEncode & urlDecode
+ (NSString *)urlEncode:(NSString *)string;
+ (NSString *)urlDecode:(NSString *)string;

#pragma mark - base64
+ (NSString *)base64Encode:(NSString *)string;
+ (NSString *)base64Decode:(NSString *)string;

#pragma mark - zip
+ (NSData *)zipData:(NSData *)data;
+ (NSData *)unZipData:(NSData *)data;

#pragma mark - dateFormatter
/**
 * @"yyyy-MM-dd HH:mm:ss.SSS"
 */
+ (NSDateFormatter*)dayFormatter;
/**
 * @"HH:mm:ss.SSS"
 */
+ (NSDateFormatter*)timeFormatter;


@end

NS_ASSUME_NONNULL_END
