//
//  QzReachability.h
//  QzToolKit
//
//  Created by JzProl.m.Qiezi on 2020/8/4.
//  Copyright © 2020 com.mqiezi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, QzNetworkStatus) {
    QzNetworkStatusNotReachable = 0,
    QzNetworkStatusReachableViaWiFi,
    QzNetworkStatusReachableViaWWAN
};


extern NSString *kQzReachabilityChangedNotification;

@class QzReachability;

typedef void (^QzNetworkReachable)(QzReachability * reachability);
typedef void (^QzNetworkUnreachable)(QzReachability * reachability);
typedef void (^QzNetworkReachability)(QzReachability * reachability, SCNetworkConnectionFlags flags);

@interface QzReachability : NSObject

@property (nonatomic, copy) QzNetworkReachable    reachableBlock;
@property (nonatomic, copy) QzNetworkUnreachable  unreachableBlock;
@property (nonatomic, copy) QzNetworkReachability reachabilityBlock;

@property (nonatomic, assign) BOOL reachableOnWWAN;

/*!
 * Use to check the reachability of a given host name.
 */
+(instancetype)reachabilityWithHostName:(NSString *)hostName;

/*!
 * Checks whether the default route is available. Should be used by applications that do not connect to a particular host.
 */
+(instancetype)reachabilityForInternetConnection;

/*!
 * Use to check the reachability of a given IP address.
 */
+(instancetype)reachabilityWithAddress:(void *)hostAddress;

/*!
 * Checks whether a local WiFi connection is available.
 */
+(instancetype)reachabilityForLocalWiFi;

+(instancetype)reachabilityWithURL:(NSURL*)url;

-(instancetype)initWithReachabilityRef:(SCNetworkReachabilityRef)ref;

/*!
 * Start listening for reachability notifications on the current run loop.
 */
-(BOOL)startNotifier;
-(void)stopNotifier;

-(BOOL)isReachable;
-(BOOL)isReachableViaWWAN;
-(BOOL)isReachableViaWiFi;

+ (BOOL)isIpAddress:(NSString*)host;

    // WWAN may be available, but not active until a connection has been established.
    // WiFi may require a connection for VPN on Demand.
-(BOOL)isConnectionRequired; // Identical DDG variant.
-(BOOL)connectionRequired; // Apple's routine.
                           // Dynamic, on demand connection?
-(BOOL)isConnectionOnDemand;
    // Is user intervention required?
-(BOOL)isInterventionRequired;

-(QzNetworkStatus)currentReachabilityStatus;
-(SCNetworkReachabilityFlags)reachabilityFlags;
-(NSString*)currentReachabilityString;
-(NSString*)currentReachabilityFlags;
@end

NS_ASSUME_NONNULL_END
