//
//  QzLocation.h
//  QzToolKit
//
//  Created by JzProl.m.Qiezi on 2020/8/3.
//  Copyright © 2020 com.mqiezi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


NS_ASSUME_NONNULL_BEGIN

@interface QzLocation : NSObject

+ (instancetype) sharedInstance;

+ (BOOL) havePermiss;

+ (CLLocation *) location;

+ (NSDictionary*) geo;

@end

NS_ASSUME_NONNULL_END
