//
//  QzCryptor.m
//  QzToolKit
//
//  Created by JzProl.m.Qiezi on 2020/8/4.
//  Copyright © 2020 com.mqiezi. All rights reserved.
//

#import "QzCryptor.h"
#import "QzLogger.h"

#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonCrypto.h>


@interface QzCryptor()

@end

@implementation QzCryptor

#pragma mark - Digest

+ (NSData *)md5Data:(NSData*)data{
    if(!data){
        return nil;
    }
    unsigned char hash[CC_MD5_DIGEST_LENGTH];
    (void) CC_MD5([data bytes], (CC_LONG)[data length], hash);
    return ( [NSData dataWithBytes: hash length: CC_MD5_DIGEST_LENGTH] );
}

+ (NSString *)md5String:(NSData*)data {
    if(!data){
        return nil;
    }
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5([data bytes], (CC_LONG)[data length], result);
    NSMutableString *hash = [NSMutableString
                             stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [hash appendFormat:@"%02x", result[i]];
    }
    return hash;
}

+ (NSData *)sha1Data:(NSData*)data{
    if(!data){
        return nil;
    }
    unsigned char hash[CC_SHA1_DIGEST_LENGTH];
    (void) CC_SHA1( [data bytes], (CC_LONG)[data length], hash );
    return ( [NSData dataWithBytes: hash length: CC_SHA1_DIGEST_LENGTH] );
}

+ (NSString *)sha1String:(NSData*)data {
    if(!data){
        return nil;
    }
    unsigned char result[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1([data bytes], (CC_LONG)[data length], result);
    NSMutableString *hash = [NSMutableString
                             stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        [hash appendFormat:@"%02x", result[i]];
    }
    return hash;
}

#pragma mark - HMAC

+(NSData *)hmacData:(NSData*)data usingAlg:(CCHmacAlgorithm)alg withKey:(id)key {
    if(!data){
        return nil;
    }
    NSParameterAssert([key isKindOfClass: [NSData class]] || [key isKindOfClass: [NSString class]]);
    size_t size;
    switch (alg) {
        case kCCHmacAlgMD5: size = CC_MD5_DIGEST_LENGTH; break;
        case kCCHmacAlgSHA1: size = CC_SHA1_DIGEST_LENGTH; break;
        case kCCHmacAlgSHA224: size = CC_SHA224_DIGEST_LENGTH; break;
        case kCCHmacAlgSHA256: size = CC_SHA256_DIGEST_LENGTH; break;
        case kCCHmacAlgSHA384: size = CC_SHA384_DIGEST_LENGTH; break;
        case kCCHmacAlgSHA512: size = CC_SHA512_DIGEST_LENGTH; break;
        default: return nil;
    }
    NSMutableData * keyData;
    if ( [key isKindOfClass: [NSData class]] )
        keyData = (NSMutableData *) [key mutableCopy];
    else
        keyData = [[key dataUsingEncoding: NSUTF8StringEncoding] mutableCopy];
    
    unsigned char result[size];
    CCHmac(alg, [keyData bytes], keyData.length, [data bytes], [data length], result);
    return [NSData dataWithBytes:result length:size];
}

+ (NSString *)hmacString:(NSData*)data usingAlg:(CCHmacAlgorithm)alg withKey:(id)key {
    if(!data){
        return nil;
    }
    NSParameterAssert([key isKindOfClass: [NSData class]] || [key isKindOfClass: [NSString class]]);
    size_t size;
    switch (alg) {
        case kCCHmacAlgMD5: size = CC_MD5_DIGEST_LENGTH; break;
        case kCCHmacAlgSHA1: size = CC_SHA1_DIGEST_LENGTH; break;
        case kCCHmacAlgSHA224: size = CC_SHA224_DIGEST_LENGTH; break;
        case kCCHmacAlgSHA256: size = CC_SHA256_DIGEST_LENGTH; break;
        case kCCHmacAlgSHA384: size = CC_SHA384_DIGEST_LENGTH; break;
        case kCCHmacAlgSHA512: size = CC_SHA512_DIGEST_LENGTH; break;
        default: return nil;
    }
    unsigned char result[size];
    NSMutableData * keyData;
    if ( [key isKindOfClass: [NSData class]] )
        keyData = (NSMutableData *) [key mutableCopy];
    else
        keyData = [[key dataUsingEncoding: NSUTF8StringEncoding] mutableCopy];
    
    CCHmac(alg, keyData.bytes, strlen(keyData.bytes), [data bytes], [data length], result);
    NSMutableString *hash = [NSMutableString stringWithCapacity:size * 2];
    for (int i = 0; i < size; i++) {
        [hash appendFormat:@"%02x", result[i]];
    }
    return hash;
}

+ (NSData *)hmacMD5Data:(NSData*)data withKey:(id)key{
    return [self hmacData:data usingAlg:kCCHmacAlgMD5 withKey:key];
}

+ (NSData *)hmacSHA1Data:(NSData*)data withKey:(id)key{
    return [self hmacData:data usingAlg:kCCHmacAlgSHA1 withKey:key];
}

+ (NSString *)hmacMD5String:(NSData*)data withKey:(id)key{
    return [self hmacString:data usingAlg:kCCHmacAlgMD5 withKey:key];
}

+ (NSString *)hmacSHA1String:(NSData*)data withKey:(id)key{
    return [self hmacString:data usingAlg:kCCHmacAlgSHA1 withKey:key];
}
#pragma mark - Padding

OBJC_EXTERN void QzPaddingSettingKeyLengths( CCAlgorithm algorithm, NSMutableData * keyData, NSMutableData * ivData){
    NSUInteger keyLength = [keyData length];
    switch ( algorithm ){
        case kCCAlgorithmAES128:
        {
            // 16
        if ( keyLength <= kCCKeySizeAES128 ){
            [keyData setLength: kCCKeySizeAES128];
        }
            // 24
        else if ( keyLength <= kCCKeySizeAES192 ){
            [keyData setLength: kCCKeySizeAES192];
        }
            // 32
        else{
            [keyData setLength: kCCKeySizeAES256];
        }
        break;
        }
            
        case kCCAlgorithmDES:
        {
            // 8
        [keyData setLength: kCCKeySizeDES];
        break;
        }
            
        case kCCAlgorithm3DES:
        {
            //24
        [keyData setLength: kCCKeySize3DES];
        break;
        }
            
        case kCCAlgorithmCAST:
        {
            //[5,16]
            //            if ( keyLength < kCCKeySizeMinCAST )
            //            {
            //                [keyData setLength: kCCKeySizeMinCAST];
            //            }
            //            else if ( keyLength > kCCKeySizeMaxCAST )
            //            {
            // 16
        [keyData setLength: kCCKeySizeMaxCAST];
            //            }
        
        break;
        }
            
        case kCCAlgorithmRC4:
        {
            // [1,512]
        if ( keyLength >= kCCKeySizeMaxRC4 )
            [keyData setLength: kCCKeySizeMaxRC4 ];
        break;
        }
        case kCCAlgorithmRC2:
        {
            // [1,128]
        if ( keyLength >= kCCKeySizeMaxRC2 )
            [keyData setLength: kCCKeySizeMaxRC2 ];
        break;
        }
        default:
            break;
    }
    
    [ivData setLength: [keyData length]];
}



OBJC_EXTERN NSData * QzPaddingAddBitPadding(CCOperation operation, CCAlgorithm algorithm ,QzCryptorPadding padding, NSData *data){
    
    if (padding == QzCryptorPKCS7Padding) {
        return  data;
    }
    if (operation == kCCEncrypt && (algorithm != QzCryptoAlgorithmRC4)  ) {
        NSMutableData *sourceData = data.mutableCopy;
        int blockSize = 8;
        switch (algorithm) {
            case kCCAlgorithmAES:
                blockSize = kCCBlockSizeAES128;
                break;
            case kCCAlgorithmDES:
            case kCCAlgorithm3DES:
            case kCCAlgorithmCAST:
            case kCCAlgorithmBlowfish:
            default:
                blockSize = 8;
                break;
        }
        
        switch (padding) {
            case QzCryptorZeroPadding:
            {
            int pad = 0x00;
            int diff =   blockSize - (sourceData.length % blockSize);
            for (int i = 0; i < diff; i++) {
                [sourceData appendBytes:&pad length:1];
            }
            }
                break;
            case QzCryptorANSIX923:
            {
            int pad = 0x00;
            int diff =   blockSize - (sourceData.length % blockSize);
            for (int i = 0; i < diff - 1; i++) {
                [sourceData appendBytes:&pad length:1];
            }
            [sourceData appendBytes:&diff length:1];
            }
                break;
            case QzCryptorISO10126:
            {
            int diff = blockSize - (sourceData.length % blockSize);
            for (int i = 0; i < diff - 1; i++) {
                int pad  = arc4random() % 254 + 1;
                [sourceData appendBytes:&pad length:1];
            }
            [sourceData appendBytes:&diff length:1];
            }
                break;
                    //            case QzCryptorPKCS7Padding:
                    //            {
                    //                int diff =  blockSize - ([sourceData length] % blockSize);
                    //                for (int i = 0; i <diff; i++) {
                    //                    [sourceData appendBytes:&diff length:1];
                    //                }
                    //
                    //            }
            default:
                break;
        }
        return sourceData;
    }
    return data;
    
}


OBJC_EXTERN NSData * QzPaddingRemoveBitPadding(CCOperation operation, CCAlgorithm algorithm ,QzCryptorPadding padding, NSData *sourceData){
    if (padding == QzCryptorPKCS7Padding) {
        return sourceData;
    }
    if (operation == kCCDecrypt && (algorithm != QzCryptoAlgorithmRC4) ) {
        
        int correctLength = 0;
        int blockSize = 8;
        switch (algorithm) {
            case kCCAlgorithmAES:
                blockSize = kCCBlockSizeAES128;
                break;
            case kCCAlgorithmDES:
            case kCCAlgorithm3DES:
            case kCCAlgorithmCAST:
            case kCCAlgorithmBlowfish:
            default:
                blockSize = 8;
                break;
        }
        Byte *testByte = (Byte *)[sourceData bytes];
        char end = testByte[sourceData.length - 1];
            // 去除可能填充字符
            //        if ((padding == CcCryptorZeroPadding && end == 0) || (padding == ccPKCS7Padding && (end > 0 && end < blockSize + 1))) {
        if (padding == QzCryptorZeroPadding && end == 0) {
            for (int i = (short)sourceData.length - 1; i > 0 ; i--) {
                if (testByte[i] != end) {
                    correctLength = i + 1;
                    break;
                }
            }
        }
        else if ((padding == QzCryptorANSIX923 || padding == QzCryptorISO10126) && (end > 0 && end < blockSize + 1)){
            if (padding == QzCryptorISO10126 || ( testByte[sourceData.length - 2] == 0 &&  testByte[sourceData.length - end] == 0)) {
                correctLength = (short)sourceData.length - end;
            }
        }
        
        NSData *data = [NSData dataWithBytes:testByte length:correctLength];
        return data;
        
    }
    return sourceData;
    
}

#pragma mark - Cryptor


+ (NSData *)encrypt:(NSData*)data usingAlgorithm:(QzCryptoAlgorithm)algorithm
                key:(id)key
initializationVector:(id)iv
               mode:(QzCryptorMode)mode
            padding:(QzCryptorPadding)padding

{
    
    
    CCCryptorStatus status = kCCSuccess;
    
    
    NSData *result = [QzCryptor cryptology:data usingOperation:kCCEncrypt
                                     algorithm:algorithm
                                       padding:padding
                                          mode:mode
                                           key:key
                          initializationVector:iv
                                         error:&status];
    
    
    if ( result != nil )
        return ( result );
    
    
    return ( nil );
}

+ (NSData *)decrypt:(NSData*)data usingAlgorithm:(QzCryptoAlgorithm)algorithm
                key:(id)key
initializationVector:(id)iv
               mode:(QzCryptorMode)mode
            padding:(QzCryptorPadding)padding

{
    
    CCCryptorStatus status = kCCSuccess;
    
    NSData *result = [QzCryptor cryptology:data usingOperation:kCCDecrypt algorithm:algorithm padding:padding mode:mode key:key initializationVector:iv error:&status];
    
    if ( result != nil )
        return ( result );
    
    return ( nil );
}

+ (NSData *)cryptology:(NSData*)data usingOperation:(CCOperation)operation
             algorithm: (CCAlgorithm) algorithm
               padding:(QzCryptorPadding)padding
                  mode:(QzCryptorMode)mode
                   key: (id) key
  initializationVector: (id) iv
                 error: (CCCryptorStatus *) error
{
        // algorithm is not stream chiper
    
    if (algorithm != kCCAlgorithmRC4) {
        NSAssert((mode == QzCryptorCBCMode && iv != nil && iv != NULL) || mode == QzCryptorECBMode, @"With CBC Mode , InitializationVector  must have value");
        NSAssert((mode == QzCryptorCBCMode && [iv length] >= 8) || mode == QzCryptorECBMode, @"With CBC Mode, InitializationVector  must be greater than 8 bits");
        if (mode == QzCryptorCBCMode && [iv length] < 8) {
            QzLogE(@"error -- With CBC Mode, InitializationVector  must be greater than 8 bits");
            return nil;
        }
    }
    
    CCCryptorRef cryptor = NULL;
    CCCryptorStatus status = kCCSuccess;
    
    NSParameterAssert([key isKindOfClass: [NSData class]] || [key isKindOfClass: [NSString class]]);
    NSParameterAssert(iv == nil || [iv isKindOfClass: [NSData class]] || [iv isKindOfClass: [NSString class]]);
    
    NSMutableData * keyData, * ivData;
    if ( [key isKindOfClass: [NSData class]] )
        keyData = (NSMutableData *) [key mutableCopy];
    else
        keyData = [[key dataUsingEncoding: NSUTF8StringEncoding] mutableCopy];
    
    if ( [iv isKindOfClass: [NSString class]] )
        ivData = [[iv dataUsingEncoding: NSUTF8StringEncoding] mutableCopy];
    else
        ivData = (NSMutableData *) [iv mutableCopy];    // data or nil
    
#if !__has_feature(objc_arc)
    [keyData autorelease];
    [ivData autorelease];
#endif
    CCPadding paddingMode = ((padding == ccPKCS7Padding) ? ccPKCS7Padding:ccNoPadding) ;
    
        // ensure correct lengths for key and iv data, based on algorithms
    QzPaddingSettingKeyLengths( algorithm, keyData, ivData );
    
    NSData *sourceData =  QzPaddingAddBitPadding(operation, algorithm, padding, data);
    
        //    status = CCCryptorCreateWithMode(operation, mode, algorithm, ccNoPadding, ivData.bytes, keyData.bytes, keyData.length, NULL, 0, 0, kCCModeOptionCTR_LE, &cryptor);
    status = CCCryptorCreateWithMode(operation, mode, algorithm, paddingMode, [ivData bytes],  [keyData bytes], [keyData length], NULL, 0, 0, kCCModeOptionCTR_BE, &cryptor);
        //    status = CCCryptorCreate( operation, algorithm, paddingMode|mode ,
        //                             [keyData bytes], [keyData length], [ivData bytes],
        //                             &cryptor );
    
    
    if ( status != kCCSuccess ){
        if ( error != NULL )
            *error = status;
        return ( nil );
    }
    
        //确定处理给定输入所需的输出缓冲区大小尺寸。
    size_t bufsize = CCCryptorGetOutputLength( cryptor, (size_t)[sourceData length], true );
    void * buf = malloc( bufsize );
    size_t bufused = 0;
    size_t bytesTotal = 0;
    
        //处理（加密，解密）一些数据。如果有结果的话,写入提供的缓冲区.
    status = CCCryptorUpdate( cryptor, [sourceData bytes], (size_t)[sourceData length],
                             buf, bufsize, &bufused );
    
    if ( status != kCCSuccess ){
        free( buf );
        return ( nil );
    }
    
    bytesTotal += bufused;
    
        // From Brent Royal-Gordon (Twitter: architechies):
        //  Need to update buf ptr past used bytes when calling CCCryptorFinal()
    
        //  It is not necessary to call CCCryptorFinal() when performing
        //symmetric encryption or decryption if padding is disabled, or
        //   when using a stream cipher.
    if (mode == QzCryptorPKCS7Padding) {
        status = CCCryptorFinal( cryptor, buf + bufused, bufsize - bufused, &bufused );
        if ( status != kCCSuccess ){
            free( buf );
            return ( nil );
        }
        bytesTotal += bufused;
    }
    
    NSData *result = [NSData dataWithBytesNoCopy: buf length: bytesTotal];
    
    result = QzPaddingRemoveBitPadding(operation, algorithm, padding, result);
    
    if ( (result == nil) && (error != NULL) )
        *error = status;
    
    CCCryptorRelease( cryptor );
    
    return ( result );
}

#pragma mark AES

+ (NSData *)encrypt:(NSData *)data usingAES128WithKey:(NSData *)key{
    return  [QzCryptor encrypt:data usingAlgorithm:QzCryptoAlgorithmAES key:key initializationVector:nil mode:QzCryptorECBMode padding:QzCryptorPKCS7Padding];
}

+ (NSData *)decrypt:(NSData *)data usingAES128WithKey:(NSData *)key{
    return  [QzCryptor decrypt:data usingAlgorithm:QzCryptoAlgorithmAES key:key initializationVector:nil mode:QzCryptorECBMode padding:QzCryptorPKCS7Padding];
}

#pragma mark RSA

+ (NSData *)stripPublicKeyHeader:(NSData *)d_key{
        // Skip ASN.1 public key header
    if (d_key == nil) return(nil);
    
    unsigned long len = [d_key length];
    if (!len) return(nil);
    
    unsigned char *c_key = (unsigned char *)[d_key bytes];
    unsigned int  idx = 0;
    
    if (c_key[idx++] != 0x30) return(nil);
    
    if (c_key[idx] > 0x80) idx += c_key[idx] - 0x80 + 1;
    else idx++;
    
        // PKCS #1 rsaEncryption szOID_RSA_RSA
    static unsigned char seqiod[] =
    { 0x30,   0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01,
        0x01, 0x05, 0x00 };
    if (memcmp(&c_key[idx], seqiod, 15)) return(nil);
    
    idx += 15;
    
    if (c_key[idx++] != 0x03) return(nil);
    
    if (c_key[idx] > 0x80) idx += c_key[idx] - 0x80 + 1;
    else idx++;
    
    if (c_key[idx++] != '\0') return(nil);
    
        // Now make a new NSData from this buffer
    return([NSData dataWithBytes:&c_key[idx] length:len - idx]);
}

+ (NSData *)stripPrivateKeyHeader:(NSData *)d_key{
        // Skip ASN.1 private key header
    if (d_key == nil) return(nil);
    
    unsigned long len = [d_key length];
    if (!len) return(nil);
    
    unsigned char *c_key = (unsigned char *)[d_key bytes];
    unsigned int  idx     = 22; //magic byte at offset 22
    
    if (0x04 != c_key[idx++]) return nil;
    
        //calculate length of the key
    unsigned int c_len = c_key[idx++];
    int det = c_len & 0x80;
    if (!det) {
        c_len = c_len & 0x7f;
    } else {
        int byteCount = c_len & 0x7f;
        if (byteCount + idx > len) {
                //rsa length field longer than buffer
            return nil;
        }
        unsigned int accum = 0;
        unsigned char *ptr = &c_key[idx];
        idx += byteCount;
        while (byteCount) {
            accum = (accum << 8) + *ptr;
            ptr++;
            byteCount--;
        }
        c_len = accum;
    }
    
        // Now make a new NSData from this buffer
    return [d_key subdataWithRange:NSMakeRange(idx, c_len)];
}

    //加载PKCS8格式的公钥
+ (SecKeyRef)publicKeyFromPKCS8String:(NSString *)key{
    SecKeyRef pubkeyRef;
    CFErrorRef errRef = NULL;
    NSString *pemStr = key;
    
    NSRange spos = [pemStr rangeOfString:@"-----BEGIN PUBLIC KEY-----"];
    NSRange epos = [pemStr rangeOfString:@"-----END PUBLIC KEY-----"];
    if(spos.location != NSNotFound && epos.location != NSNotFound){
        NSUInteger s = spos.location + spos.length;
        NSUInteger e = epos.location;
        NSRange range = NSMakeRange(s, e-s);
        pemStr = [pemStr substringWithRange:range];
    }
    
    pemStr = [pemStr stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    pemStr = [pemStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    pemStr = [pemStr stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    pemStr = [pemStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSData *dataPubKey = [[NSData alloc] initWithBase64EncodedString:pemStr options:NSDataBase64DecodingIgnoreUnknownCharacters];
    
    dataPubKey = [QzCryptor stripPublicKeyHeader:dataPubKey];
    if(!dataPubKey){
        return nil;
    }
    
    NSMutableDictionary *dicPubkey = [[NSMutableDictionary alloc]initWithCapacity:4];
    [dicPubkey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [dicPubkey setObject:(__bridge id) kSecAttrKeyClassPublic forKey:(__bridge id)kSecAttrKeyClass];
    [dicPubkey setObject:@(1024) forKey:(__bridge id)kSecAttrKeySizeInBits];
    
    if (@available(iOS 10.0, *)) {
        pubkeyRef = SecKeyCreateWithData((__bridge CFDataRef)dataPubKey, (__bridge CFDictionaryRef)dicPubkey, &errRef);
    } else {
            // Fallback on earlier versions
            // A tag to read/write keychain storage
        NSString *tag = @"QZ_RSA_PubKey";
        NSData *d_tag = [NSData dataWithBytes:[tag UTF8String] length:[tag length]];
        [dicPubkey setObject:d_tag forKey:(__bridge id)kSecAttrApplicationTag];
        [dicPubkey setObject:(__bridge id) kSecClassKey forKey:(__bridge id)kSecClass];
        SecItemDelete((__bridge CFDictionaryRef)dicPubkey);
        
            // Add persistent version of the key to system keychain
        [dicPubkey setObject:dataPubKey forKey:(__bridge id)kSecValueData];
        [dicPubkey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)
         kSecReturnPersistentRef];
        
        CFTypeRef persistKey = nil;
        OSStatus status = SecItemAdd((__bridge CFDictionaryRef)dicPubkey, &persistKey);
        if (persistKey != nil){
            CFRelease(persistKey);
        }
        if ((status != noErr) && (status != errSecDuplicateItem)) {
            return nil;
        }
        
        [dicPubkey removeObjectForKey:(__bridge id)kSecValueData];
        [dicPubkey removeObjectForKey:(__bridge id)kSecReturnPersistentRef];
        [dicPubkey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
        
            // Now fetch the SecKeyRef version of the key
        status = SecItemCopyMatching((__bridge CFDictionaryRef)dicPubkey, (CFTypeRef *)&pubkeyRef);
        if(status != noErr){
            return nil;
        }

    }
    if(errRef!=NULL){
        NSError *error = (__bridge NSError *)errRef;
        QzLogE(@"Error code:%ld desc:%@", (long)error.code, [error.userInfo description]);
        return nil;
    }
    return pubkeyRef;
}


    //加载PKCS1格式的私钥
+ (SecKeyRef)privateKeyFromPKCS1String:(NSString *)key{
    SecKeyRef prikeyRef;
    CFErrorRef errRef = NULL;
    NSString *pemStr = key;
    
    NSRange spos = [pemStr rangeOfString:@"-----BEGIN PRIVATE KEY-----"];
    NSRange epos = [pemStr rangeOfString:@"-----END PRIVATE KEY-----"];
    if(spos.location != NSNotFound && epos.location != NSNotFound){
        NSUInteger s = spos.location + spos.length;
        NSUInteger e = epos.location;
        NSRange range = NSMakeRange(s, e-s);
        pemStr = [pemStr substringWithRange:range];
    }
    pemStr = [pemStr stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    pemStr = [pemStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    pemStr = [pemStr stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    pemStr = [pemStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSData *dataPriKey = [[NSData alloc]initWithBase64EncodedString:pemStr options:NSDataBase64DecodingIgnoreUnknownCharacters];
    
    dataPriKey = [QzCryptor stripPrivateKeyHeader:dataPriKey];
    if(!dataPriKey){
        return nil;
    }
    
    NSMutableDictionary *dicPrikey = [[NSMutableDictionary alloc]initWithCapacity:3];
    [dicPrikey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [dicPrikey setObject:(__bridge id) kSecAttrKeyClassPrivate forKey:(__bridge id)kSecAttrKeyClass];
    [dicPrikey setObject:@(1024) forKey:(__bridge id)kSecAttrKeySizeInBits];
    
    if (@available(iOS 10.0, *)) {
        prikeyRef = SecKeyCreateWithData((__bridge CFDataRef)dataPriKey, (__bridge CFDictionaryRef)dicPrikey, &errRef);
    } else {
            // Fallback on earlier versions
            // A tag to read/write keychain storage
        NSString *tag = @"QZ_RSA_PriKey";
        NSData *d_tag = [NSData dataWithBytes:[tag UTF8String] length:[tag length]];
        [dicPrikey setObject:d_tag forKey:(__bridge id)kSecAttrApplicationTag];
        [dicPrikey setObject:(__bridge id) kSecClassKey forKey:(__bridge id)kSecClass];
        SecItemDelete((__bridge CFDictionaryRef)dicPrikey);
        
            // Add persistent version of the key to system keychain
        [dicPrikey setObject:dataPriKey forKey:(__bridge id)kSecValueData];
        [dicPrikey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)
         kSecReturnPersistentRef];
        
        CFTypeRef persistKey = nil;
        OSStatus status = SecItemAdd((__bridge CFDictionaryRef)dicPrikey, &persistKey);
        if (persistKey != nil){
            CFRelease(persistKey);
        }
        if ((status != noErr) && (status != errSecDuplicateItem)) {
            return nil;
        }
        
        [dicPrikey removeObjectForKey:(__bridge id)kSecValueData];
        [dicPrikey removeObjectForKey:(__bridge id)kSecReturnPersistentRef];
        [dicPrikey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
        
            // Now fetch the SecKeyRef version of the key
        status = SecItemCopyMatching((__bridge CFDictionaryRef)dicPrikey, (CFTypeRef *)&prikeyRef);
        if(status != noErr){
            return nil;
        }
        
    }
    if(errRef!=NULL){
        NSError *error = (__bridge NSError *)errRef;
        QzLogE(@"Error code:%ld desc:%@", (long)error.code, [error.userInfo description]);
        return nil;
    }
    return prikeyRef;
}

    /// 加密的大小受限于SecKeyEncrypt函数，SecKeyEncrypt要求明文和密钥的长度一致，
    /// 如果要加密更长的内容，需要把内容按密钥长度分成多份，然后多次调用SecKeyEncrypt来实现
+ (NSData*)encryptData:(NSData*)data usingRSAWithKey:(NSString *)key{
    
    SecKeyRef keyRef = [QzCryptor publicKeyFromPKCS8String:key];
    if(!keyRef){
        return nil;
    }
    
    const uint8_t *srcbuf = (const uint8_t *)[data bytes];
    size_t srclen = (size_t)data.length;
    
    size_t block_size = SecKeyGetBlockSize(keyRef) * sizeof(uint8_t);
    void *outbuf = malloc(block_size);
    size_t src_block_size = block_size - 11;
    
    NSMutableData *ret = [[NSMutableData alloc] init];
    for(int idx = 0; idx < srclen; idx += src_block_size){
        size_t data_len = srclen - idx;
        if (data_len > src_block_size) {
            data_len = src_block_size;
        }
        
        size_t outlen = block_size;
        OSStatus status = noErr;
        status = SecKeyEncrypt(keyRef,
                               kSecPaddingPKCS1,
                               srcbuf + idx,
                               data_len,
                               outbuf,
                               &outlen
                               );
        if (status != 0) {//0为成功
            ret = nil;
            break;
        }else{
            [ret appendBytes:outbuf length:outlen];
        }
    }
    
    free(outbuf);
    CFRelease(keyRef);
    return ret;
}

+ (NSString*)encryptString:(NSString *)string usingRSAWithKey:(NSString *)key{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSData *encryptedData = [QzCryptor encryptData: data usingRSAWithKey:key];
    NSString *base64EncryptedString = [encryptedData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    return base64EncryptedString;
}

+ (NSData*)decryptData:(NSData*)data usingRSAWithKey:(NSString *)key{
    SecKeyRef keyRef = [QzCryptor privateKeyFromPKCS1String:key];
    if(!keyRef){
        return nil;
    }
    size_t cipherLen = [data length];
    void *cipher = malloc(cipherLen);
    [data getBytes:cipher length:cipherLen];
    size_t plainLen = SecKeyGetBlockSize(keyRef) - 12;
    void *plain = malloc(plainLen);
    OSStatus status = SecKeyDecrypt(keyRef, kSecPaddingPKCS1, cipher, cipherLen, plain, &plainLen);
    if (status != noErr) {
        CFRelease(keyRef);
        return nil;
    }
    CFRelease(keyRef);
    NSData *decryptedData = [[NSData alloc] initWithBytes:(const void *)plain length:plainLen];
    return decryptedData;
}

+ (NSString*)decryptString:(NSString *)string usingRSAWithKey:(NSString *)key{
    NSData *data = [[NSData alloc] initWithBase64EncodedString:string options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSData *decryptData = [QzCryptor decryptData: data usingRSAWithKey:key];
    NSString *result = [[NSString alloc] initWithData:decryptData encoding:NSUTF8StringEncoding];
    return result;
}

@end
