//
//  QzUA.m
//  QzToolKit
//
//  Created by JzProl.m.Qiezi on 2020/8/3.
//  Copyright © 2020 com.mqiezi. All rights reserved.
//

#import "QzUA.h"
#import <WebKit/WebKit.h>
#import "QzUserDefaults.h"
#import "QzMacros.h"
#import "QzLogger.h"

NSString *const Qz_UA_HTML = @"<html></html>";
NSString *const Qz_UA_JS = @"navigator.userAgent";
NSString *const Qz_UA_Default = @"Mozilla/5.0 (iPhone; CPU iPhone OS %@ like Mac OS X)";

@interface QzUA()

@property(strong)WKWebView* wkWebView;

@end

@implementation QzUA


+ (instancetype) sharedInstance{
    static QzUA *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance =[[self alloc] init];
    });
    return _sharedInstance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static QzUA *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [super allocWithZone:zone];
    });
    return _sharedInstance;
}

-(instancetype)init{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)dealloc{
    self.wkWebView=nil;
}

-(void)updateValue{
    @QzWeakObj(self);
    QzDispatchMainAsyncSafe( ^{
        @QzStrongObj(self);
        if(!selfStrong){
            return;
        }
        
        if(!selfStrong.wkWebView){
            selfStrong.wkWebView = [[WKWebView alloc] initWithFrame:CGRectZero];
            selfStrong.wkWebView.navigationDelegate =nil;
        }
        
        [selfStrong.wkWebView loadHTMLString:Qz_UA_HTML baseURL:nil];
        [selfStrong.wkWebView evaluateJavaScript:Qz_UA_JS completionHandler:^(id result, NSError *error) {
            if(!error){
                [QzUserDefaults setObject:result forKey:QzUserDefaultsKeyUA];
                NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
                [QzUserDefaults setObject:[NSNumber numberWithDouble:now] forKey:QzUserDefaultsKeyUAUpdateTime];
                QzLogI(@"ua:%@ update, update time:%ld",result,now);
                QzDispatchMainAsyncSafe( ^{
                        // 使用完可以清除了
                    [selfStrong.wkWebView stopLoading];
                    selfStrong.wkWebView =nil;
                });
            }
        }];
    });
}

-(NSString*)UA{
    NSString* OSVersion = [[UIDevice currentDevice] systemVersion];
    NSString* formatOSV = [OSVersion stringByReplacingOccurrencesOfString:@"." withString:@"_"];
    NSString* ua = [NSString stringWithFormat:Qz_UA_Default,formatOSV];
    
    NSString* storedUA = (NSString*)[QzUserDefaults objectForKey:QzUserDefaultsKeyUA];
    if(!storedUA){
        [self updateValue];
        return ua;
    }
    
    // 不包含当前系统版本时即认为改变
    if(![storedUA containsString:formatOSV]){
        NSTimeInterval timeInterval = [(NSNumber*)[QzUserDefaults objectForKey:QzUserDefaultsKeyUAUpdateTime] doubleValue];
        QzLogI(@"ua:%@ , need update,last update time:%ld",storedUA,timeInterval);
        [self updateValue];
        return ua;//必定检测失败，返回默认构建的UA
    }
    
    return storedUA;
}

+ (NSString*)UA{
    return [[QzUA sharedInstance] UA];
}

@end






