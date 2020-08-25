//
//  QzUserDefaults.m
//  QzToolKit
//
//  Created by JzProl.m.Qiezi on 2020/8/3.
//  Copyright © 2020 com.mqiezi. All rights reserved.
//

#import "QzUserDefaults.h"


QzUserDefaultsKey const QzUserDefaultsKeyUA = @"com.mqiezi.ua";
QzUserDefaultsKey const QzUserDefaultsKeyUAUpdateTime = @"com.mqiezi.ua.update.time";
QzUserDefaultsKey const QzUserDefaultsKeyOpenUDID = @"com.mqiezi.openudid";
QzUserDefaultsKey const QzUserDefaultsKeyOpenUDIDUpdateTime = @"com.mqiezi.openudid.update.time";

@implementation QzUserDefaults

+ (void)setObject:(nullable id)object forKey:(NSString* _Nonnull)key{
    if(!key || key.length<1 ){
        return ;
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if(!object){
        [userDefaults removeObjectForKey:key];
        return;
    }
    
    [userDefaults setObject:object forKey:key];
}

+ (nullable id)objectForKey:(NSString* _Nonnull)key{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:key];
}

+ (void)removeObjectForKey:(NSString *)key{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults removeObjectForKey:key];
}

@end
