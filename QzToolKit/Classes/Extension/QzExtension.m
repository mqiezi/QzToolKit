//
//  QzExtension.m
//  QzToolKit
//
//  Created by JzProl.m.Qiezi on 2020/8/4.
//  Copyright © 2020 com.mqiezi. All rights reserved.
//

#import "QzExtension.h"
#import "QzLogger.h"

#import <zlib.h>

@interface QzExtension()

@end

@implementation QzExtension

#pragma mark - json
+(NSString*)jsonObjectToJsonString:(NSObject*)object{
    if(!object){
        return nil;
    }
    
    NSString *jsonString = nil;
    @try {
        if(![NSJSONSerialization isValidJSONObject:object]){
            return @"{}";
        }
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                           options:0 // Pass 0 if you don't care about the readability of the generated string
                                                             error:&error];
        if (error) {
            return @"{}";
        }

        if (!jsonData) {
            return @"{}";
        } else {
            jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
        
    } @catch (NSException *exception) {
        return @"{}";
    }
    
    return jsonString;
}

+(NSObject*)jsonStringToJsonObject:(NSString*)string{
    NSObject *obj;
    if (!string) {
        return nil;
    }
    NSData * data=[string dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
    if (!data) {
        return nil;
    }
    @try {
        NSError *error;
        obj = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if (error) {
            return nil;
        }
        return obj;
    }
    @catch (NSException *exception) {
        return nil;
    }
}

+(NSObject*)jsonDataToJsonObject:(NSData*)data{
    if (!data) {
        return nil;
    }
    NSObject *jsonObject=nil;
    @try {
        NSError *error;
        jsonObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if (error) {
            return nil;
        }
        return jsonObject;
    }
    @catch (NSException *exception) {
        return nil;
    }
}

+(NSString*)jsonDataToJsonString:(NSData*)data{
    if(!data){
        return nil;
    }
    
    NSString *jsonString = nil;
    @try {
        jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    } @catch (NSException *exception) {
        jsonString = @"{}";
    }
    return jsonString;
}

#pragma mark - URLEncode

+ (NSString *)urlEncode:(NSString *)string{
    if(!string){
        return nil;
    }
    NSString *charactersToEscape = @"?!@#$^&%~*+,:;='\"`<>()[]{}/\\| ";
    NSCharacterSet *allowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:charactersToEscape] invertedSet];
    NSString *encodeString = [string stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
    
    return encodeString;
}

+ (NSString *)urlDecode:(NSString *)string{
    if(!string){
        return nil;
    }
    return [string stringByRemovingPercentEncoding];
}

#pragma mark - base64

+ (NSString *)base64Encode:(NSString *)string{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSData *base64Data = [data base64EncodedDataWithOptions:0];
    return [[NSString alloc] initWithData:base64Data encoding:NSUTF8StringEncoding];
}

+ (NSString *)base64Decode:(NSString *)string{
    NSData *data = [[NSData alloc] initWithBase64EncodedString:string options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

#pragma mark - zip
+ (NSData *)zipData:(NSData *)data{
    if (!data || [data length] == 0) {
        return nil;
    }
    
    z_stream zlibStreamStruct;
    zlibStreamStruct.zalloc = Z_NULL;
    zlibStreamStruct.zfree = Z_NULL;
    zlibStreamStruct.opaque = Z_NULL;
    zlibStreamStruct.total_out = 0;
    zlibStreamStruct.next_in = (Bytef *)[data bytes];
    zlibStreamStruct.avail_in = (unsigned int)[data length];
    
    int initError = deflateInit2(&zlibStreamStruct, Z_DEFAULT_COMPRESSION, Z_DEFLATED, (15+16), 8, Z_DEFAULT_STRATEGY);
    if (initError != Z_OK) {
        NSString *errorMsg = nil;
        switch (initError) {
            case Z_STREAM_ERROR:
                errorMsg = @"Invalid parameter passed in to function.";
                break;
            case Z_MEM_ERROR:
                errorMsg = @"Insufficient memory.";
                break;
            case Z_VERSION_ERROR:
                errorMsg = @"The version of zlib.h and the version of the library linked do not match.";
                break;
            default:
                errorMsg = @"Unknown error code.";
                break;
        }
        QzLogE(@"errorMsg:%@",errorMsg);
        return nil;
    }
    
    NSMutableData *compressedData = [NSMutableData dataWithLength:[data length] * 1.01 + 21];
    
    int deflateStatus;
    do {
        zlibStreamStruct.next_out = [compressedData mutableBytes] + zlibStreamStruct.total_out;
        zlibStreamStruct.avail_out = (unsigned int)([compressedData length] - zlibStreamStruct.total_out);
        deflateStatus = deflate(&zlibStreamStruct, Z_FINISH);
        
    } while (deflateStatus == Z_OK);
    
    if (deflateStatus != Z_STREAM_END){
        NSString *errorMsg = nil;
        switch (deflateStatus) {
            case Z_ERRNO:
                errorMsg = @"Error occured while reading file.";
                break;
            case Z_STREAM_ERROR:
                errorMsg = @"The stream state was inconsistent (e.g., next_in or next_out was NULL).";
                break;
            case Z_DATA_ERROR:
                errorMsg = @"The deflate data was invalid or incomplete.";
                break;
            case Z_MEM_ERROR:
                errorMsg = @"Memory could not be allocated for processing.";
                break;
            case Z_BUF_ERROR:
                errorMsg = @"Ran out of output buffer for writing compressed bytes.";
                break;
            case Z_VERSION_ERROR:
                errorMsg = @"The version of zlib.h and the version of the library linked do not match.";
                break;
            default:
                errorMsg = @"Unknown error code.";
                break;
        }
        
        QzLogE(@"errorMsg:%@",errorMsg);
        deflateEnd(&zlibStreamStruct);
        return nil;
    }
    
    deflateEnd(&zlibStreamStruct);
    [compressedData setLength:zlibStreamStruct.total_out];
    return compressedData;
}

+ (NSData *)unZipData:(NSData *)data{
    if (!data || [data length] == 0) {
        return nil;
    }
    
    unsigned full_length = (unsigned int)[data length];
    unsigned half_length = (unsigned int)[data length] / 2;
    
    NSMutableData *decompressed = [NSMutableData dataWithLength: full_length + half_length];
    BOOL done = NO;
    int status;
    
    z_stream strm;
    strm.next_in = (Bytef *)[data bytes];
    strm.avail_in = (unsigned int)[data length];
    strm.total_out = 0;
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    
    if (inflateInit2(&strm, (15+32)) != Z_OK) return nil;
    
    while (!done){
        if (strm.total_out >= [decompressed length]){
            [decompressed increaseLengthBy: half_length];
        }
            
        strm.next_out = [decompressed mutableBytes] + strm.total_out;
        strm.avail_out = (unsigned int)([decompressed length] - strm.total_out);
        
            // Inflate another chunk.
        status = inflate (&strm, Z_SYNC_FLUSH);
        if (status == Z_STREAM_END){
            done = YES;
        } else if (status != Z_OK){
            break;
        }
    }
    
    if (inflateEnd (&strm) != Z_OK) {
        return nil;
    }
    
    // Set real length.
    if (done){
        [decompressed setLength: strm.total_out];
        return [NSData dataWithData: decompressed];
    }
    return nil;
}

#pragma mark - DateFormatter
+ (NSDateFormatter*)dayFormatter{
    static NSDateFormatter *_sharedDayFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedDayFormatter = [[NSDateFormatter alloc] init];
        [_sharedDayFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    });
    return _sharedDayFormatter;
}

+ (NSDateFormatter*)timeFormatter{
    static NSDateFormatter *_sharedTimeFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedTimeFormatter = [[NSDateFormatter alloc] init];
        [_sharedTimeFormatter setDateFormat:@"HH:mm:ss.SSS"];
    });
    return _sharedTimeFormatter;
}

@end
