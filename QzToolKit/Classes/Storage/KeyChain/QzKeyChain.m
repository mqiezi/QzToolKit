//
//  QzKeyChain.m
//  QzToolKit
//
//  Created by JzProl.m.Qiezi on 2020/4/1.
//  Copyright © 2020 com.mqiezi. All rights reserved.
//

#import "QzKeyChain.h"
#import "QzLogger.h"

#define Qz_SERVICE @"com.mqiezi.qz"

@implementation QzKeyChain

+ (NSMutableDictionary *)_keychainQuery:(NSString *)count {
    if(!count ||count.length<1){
        return nil;
    }
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
            (id)kSecClassGenericPassword,(id)kSecClass,
            Qz_SERVICE, (id)kSecAttrService,
            count, (id)kSecAttrAccount,
            (id)kSecAttrAccessibleAfterFirstUnlock,(id)kSecAttrAccessible,
            nil];
}

+ (nullable id)objectForKey:(NSString *)key{
    id ret = nil;
    NSMutableDictionary *keychainQuery = [self _keychainQuery:key];
        //Configure the search setting
        //Since in our simple case we are expecting only a single attribute to be returned (the password) we can set the attribute kSecReturnData to kCFBooleanTrue
    [keychainQuery setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
    [keychainQuery setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
    CFDataRef keyData = NULL;
    if (SecItemCopyMatching((CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData) == errSecSuccess) {
        @try {
            if (@available(iOS 11.0, *)) {
                ret = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSObject class] fromData:(__bridge NSData *)keyData error:nil];
            } else {
                    // Fallback on earlier versions
                ret = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge NSData *)keyData];
            }
        } @catch (NSException *e) {
            QzLogI(@"Unarchive of %@ failed: %@", key, e);
        } @finally {
        }
    }
    if (keyData){
        CFRelease(keyData);
    }
    return ret;
}

+ (void)setObject:(nullable id)value forKey:(NSString *)key{
        //Get search dictionary
    NSMutableDictionary *keychainQuery = [self _keychainQuery:key];
        //Delete old item before add new item
    SecItemDelete((CFDictionaryRef)keychainQuery);
        //Add new object to search dictionary(Attention:the data format)
    if (@available(iOS 11.0, *)) {
        [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:value requiringSecureCoding:NO error:nil] forKey:(id)kSecValueData];
    } else {
            // Fallback on earlier versions
        [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:value] forKey:(id)kSecValueData];
    }
        //Add item to keychain with the search dictionary
    SecItemAdd((CFDictionaryRef)keychainQuery, NULL);
}

+ (void)removeObjectForKey:(NSString *)key{
    NSMutableDictionary *keychainQuery = [self _keychainQuery:key];
    SecItemDelete((CFDictionaryRef)keychainQuery);
}

@end
