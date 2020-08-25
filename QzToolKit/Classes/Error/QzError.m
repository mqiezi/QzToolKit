//
//  QzError.m
//  QzToolKit
//
//  Created by JzProl.m.Qiezi on 2020/8/21.
//  Copyright © 2020 com.mqiezi. All rights reserved.
//

#import "QzError.h"

QzErrorDescription const QzErrorDescriptionFail = @"fail";
QzErrorDescription const QzErrorDescriptionSuccess =  @"success";


#define QzErrorDicAddItem(code,desc) @(code):desc,

static NSMutableDictionary *_gQzErrorDic = nil;

@implementation QzError

+ (void) createErrorDic{
    static dispatch_once_t onceTokenMetaData;
    dispatch_once(&onceTokenMetaData, ^{
        if(_gQzErrorDic == nil){
            NSDictionary* errorDic = @{
                QzErrorDicAddItem(QzErrorCodeFail,QzErrorDescriptionFail)
                QzErrorDicAddItem(QzErrorCodeSuccess,QzErrorDescriptionSuccess)
            };
            _gQzErrorDic = [[NSMutableDictionary alloc] initWithDictionary:errorDic];
        }
    });
}


+ (QzError *) errorByCode:(int) code{
    [QzError createErrorDic];

    QzError *error = [[QzError alloc] init];
    error.errorCode = code;
    error.errorDescription = [_gQzErrorDic objectForKey:[NSNumber numberWithInt:code]];
    return error;
}

+ (QzError *) errorByCode:(int) code description:(NSString *)desc{
    QzError *error = [[QzError alloc]init];
    error.errorCode = code;
    error.errorDescription = desc;
    return error;
}

@end
