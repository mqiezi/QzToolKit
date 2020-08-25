//
//  QzUserDefaults.h
//  QzToolKit
//
//  Created by JzProl.m.Qiezi on 2020/8/3.
//  Copyright © 2020 com.mqiezi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


typedef NSString * QzUserDefaultsKey NS_STRING_ENUM;

extern QzUserDefaultsKey const QzUserDefaultsKeyUA;
extern QzUserDefaultsKey const QzUserDefaultsKeyUAUpdateTime;
extern QzUserDefaultsKey const QzUserDefaultsKeyOpenUDID;
extern QzUserDefaultsKey const QzUserDefaultsKeyOpenUDIDUpdateTime;

@interface QzUserDefaults : NSObject

+ (void)setObject:(nullable id)object forKey:(NSString*)key;
+ (nullable id)objectForKey:(NSString*)key;
+ (void)removeObjectForKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
