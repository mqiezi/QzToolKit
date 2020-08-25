//
//  QzError.h
//  QzToolKit
//
//  Created by JzProl.m.Qiezi on 2020/8/21.
//  Copyright © 2020 com.mqiezi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSInteger, QzErrorCode) {
    QzErrorCodeFail = -1,
    QzErrorCodeSuccess = 0
};

typedef NSString * QzErrorDescription NS_STRING_ENUM;
extern QzErrorDescription const QzErrorDescriptionFail;
extern QzErrorDescription const QzErrorDescriptionSuccess;


@interface QzError : NSObject

@property (strong,nonatomic) NSString *errorDescription;
@property (assign,nonatomic) NSInteger errorCode;

+ (QzError *) errorByCode:(int) code;
+ (QzError *) errorByCode:(int) code description:(NSString *)desc;

@end

NS_ASSUME_NONNULL_END
