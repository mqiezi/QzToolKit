//
//  QzKeyChain.h
//  QzToolKit
//
//  Created by JzProl.m.Qiezi on 2020/4/1.
//  Copyright © 2020 com.mqiezi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QzKeyChain : NSObject

+ (nullable id)objectForKey:(NSString *)key;
+ (void)setObject:(nullable id)value forKey:(NSString *)key;
+ (void)removeObjectForKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
