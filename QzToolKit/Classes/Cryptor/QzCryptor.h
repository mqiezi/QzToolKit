//
//  QzCryptor.h
//  QzToolKit
//
//  Created by JzProl.m.Qiezi on 2020/8/4.
//  Copyright © 2020 com.mqiezi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QzCryptor : NSObject


#pragma mark - Digest[摘要]

/**
 Returns an NSData for md5 hash.
 */
+ (NSData *)md5Data:(NSData*)data;

/**
 Returns an NSData for sha1 hash.
 */
+ (NSData *)sha1Data:(NSData*)data;

/**
 Returns a lowercase NSString for md5 hash.
 */
+ (NSString *)md5String:(NSData*)data;
/**
 Returns a lowercase NSString for sha1 hash.
 */
+ (NSString *)sha1String:(NSData*)data;

#pragma mark - HMAC[密钥相关的哈希运算消息认证码（Hash-based Message Authentication Code）的缩写]

/**
 Returns an NSData for hmac using algorithm md5 with key.
 @param key  The hmac key must be NSString Or NSData Object.
 */
+ (NSData *)hmacMD5Data:(NSData*)data withKey:(id)key;
/**
 Returns an NSData for hmac using algorithm sha1 with key.
 @param key  The hmac key must be NSString Or NSData Object.
 */
+ (NSData *)hmacSHA1Data:(NSData*)data withKey:(id)key;

/**
 Returns a lowercase NSString for hmac using algorithm md5 with key.
 @param key  The hmac key must be NSString Or NSData Object.
 */
+ (NSString *)hmacMD5String:(NSData*)data withKey:(id)key;
/**
 Returns a lowercase NSString for hmac using algorithm sha1 with key.
 @param key  The hmac key must be NSString Or NSData Object.
 */
+ (NSString *)hmacSHA1String:(NSData*)data withKey:(id)key;

#pragma mark - Padding[对称加密填充方式]

//[iOS 实现对称加密多种填充方式(ANSIX923、ISO10126、Zero)](https://www.jianshu.com/p/7b6f5aaa7680)
/*
 Block encryption Mode
 */
typedef enum : uint32_t {
    QzCryptorNoneMode,
    QzCryptorECBMode = 1, // Electronic Code Book
    QzCryptorCBCMode = 2  // Cipher Block Chaining
}QzCryptorMode;

/*
 Padding Mode
 the length of the sequence of the bytes == (blockSize - (sourceSize's length % blockSize))
 */
typedef enum : NSUInteger {
    QzCryptorNoPadding = 0,     // No Padding to source Data
    
    QzCryptorPKCS7Padding = 1,  // PKCS_7 | Each byte fills in the length of the sequence of the bytes .  ***This Padding Mode  use the system method.***
    QzCryptorZeroPadding = 2,   // 0x00 Padding |  Each byte fills 0x00
    QzCryptorANSIX923,          // The last byte fills the length of the byte sequence, and the               remaining bytes are filled with 0x00.
    QzCryptorISO10126           // The last byte fills the length of the byte sequence and  the remaining bytes fill the random data.
}QzCryptorPadding;


typedef enum : uint32_t {
    QzCryptoAlgorithmAES = 0,  // Advanced Encryption Standard, 128-bit block.  key 16 24 32 Length
    QzCryptoAlgorithmDES,      // Data Encryption Standard.  Key 8 Length
    QzCryptoAlgorithm3DES,     // Triple-DES, three key 24 Length, EDE configuration
    QzCryptoAlgorithmCAST128,  // CAST, 16Length
    QzCryptoAlgorithmRC4,      // RC4 stream cipher [1,512]Length
    QzCryptoAlgorithmRC2,      // [1,128]Length
    QzCryptoAlgorithmBLOWFISH  // Blowfish block cipher [8,56Length]
}QzCryptoAlgorithm;

#pragma mark - Cryptor


/**
 
 return An  encrypted NSData.
 
 @param algorithm QzCryptoAlgorithm
 @param key The Key Size must be consist With  selected algorithm.
 @param iv  The Iv Size must be consist With  selected algorithm.
 @param mode QzCryptorMode
 @param padding QzCryptorPadding
 
 */
+ (NSData *)encrypt:(NSData*)data usingAlgorithm:(QzCryptoAlgorithm)algorithm
                key:(id)key
initializationVector:(nullable id)iv
               mode:(QzCryptorMode)mode
            padding:(QzCryptorPadding)padding;

/**
 
 return An  decrypted NSData.
 
 @param algorithm QzCryptoAlgorithm
 @param key The Key Size must be consist With  selected algorithm.
 @param iv  The Iv Size must be consist With  selected algorithm.
 @param mode QzCryptorMode
 @param padding QzCryptorPadding
 
 */
+ (NSData *)decrypt:(NSData*)data usingAlgorithm:(QzCryptoAlgorithm)algorithm
                key:(id)key
initializationVector:(nullable id)iv
               mode:(QzCryptorMode)mode
            padding:(QzCryptorPadding)padding;


#pragma mark AES

+ (NSData *)encrypt:(NSData *)data usingAES128WithKey:(NSData *)key;
+ (NSData *)decrypt:(NSData *)data usingAES128WithKey:(NSData *)key;

#pragma mark RSA

+ (NSData*)encryptData:(NSData*)data usingRSAWithKey:(NSString *)key;
+ (NSString*)encryptString:(NSString *)string usingRSAWithKey:(NSString *)key;

+ (NSData*)decryptData:(NSData*)data usingRSAWithKey:(NSString *)key;
+ (NSString*)decryptString:(NSString *)string usingRSAWithKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
