//
//  QzLocation.m
//  QzToolKit
//
//  Created by JzProl.m.Qiezi on 2020/8/3.
//  Copyright © 2020 com.mqiezi. All rights reserved.
//

#import "QzLocation.h"
#import "QzLogger.h"

@interface QzLocation()<CLLocationManagerDelegate>
@property (strong) CLLocationManager *locationManager;
@property (strong) CLLocation * currentLocaiton;
@property (assign) BOOL isPositioning;
@property (strong) NSObject* shareToken;
@end

@implementation QzLocation

+ (instancetype) sharedInstance{
    static QzLocation *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance =[[self alloc] init];
    });
    return _sharedInstance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static QzLocation *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [super allocWithZone:zone];
    });
    return _sharedInstance;
}

-(instancetype)init{
    self = [super init];
    if (self) {
        self.isPositioning = NO;
        self.shareToken = [[NSObject alloc] init];
        [self update];
    }
    return self;
}

+ (BOOL)havePermiss{
    
    if(![CLLocationManager locationServicesEnabled]){
        return NO;
    }
    if (@available(iOS 8.0, *)){
        CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
        return (authorizationStatus==kCLAuthorizationStatusAuthorizedWhenInUse || authorizationStatus ==kCLAuthorizationStatusAuthorizedAlways);
    }
    else{
        return YES;
    }
}

+ (CLLocation *) location{
    return [[QzLocation sharedInstance] location];
}

- (CLLocation *) location{
    @synchronized (self.shareToken) {
        if (self.currentLocaiton) {
            return self.currentLocaiton;
        }
        [self update];
        return nil;
    }
}

+ (NSDictionary*) geo{
    return [[QzLocation sharedInstance] geo];
}

- (NSDictionary*) geo{
    @synchronized (self.shareToken) {
        NSMutableDictionary* geoDic = [NSMutableDictionary dictionaryWithCapacity:2];
        if (!self.currentLocaiton) {
            [self update];
            return geoDic;
        }
        CLLocationCoordinate2D clm = self.currentLocaiton.coordinate;
        NSNumber *lon = [NSNumber numberWithDouble:round(clm.longitude*100000000)/100000000];
        NSNumber *lat = [NSNumber numberWithDouble:round(clm.latitude*100000000)/100000000];
        [geoDic setValue:lat forKey:@"lat"];
        [geoDic setValue:lon forKey:@"lon"];
        return geoDic;
    }
}

- (void)update{
    BOOL havePermiss = [QzLocation havePermiss];
    if(!havePermiss){
        QzLogI(@"location authorization failed.");
        return;
    }
    @synchronized(self.shareToken) {
        if(self.isPositioning){
            QzLogI(@"already positioning");
            return;
        }
        self.isPositioning = YES;
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            @synchronized (self.shareToken) {
                self.locationManager = [[CLLocationManager alloc]init];
                self.locationManager.delegate=self;
                self.locationManager.desiredAccuracy=kCLLocationAccuracyKilometer;
                [self.locationManager startUpdatingLocation];
            }
        }];
    }
}

#pragma mark - CLLocationManagerDelegate
    // 跟踪定位代理方法，每次位置发生变化即会执行（只要定位到相应位置）
    // 可以通过模拟器设置一个虚拟位置，否则在模拟器中无法调用此方法
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    @synchronized (self.shareToken) {
        if(!locations || [locations count]<1){
            return;
        }
        CLLocation *location=[locations lastObject];//取出最后位置(最新坐标)
        self.currentLocaiton = location;
        CLLocationCoordinate2D coordinate = location.coordinate;//位置坐标
        QzLogI(@"location longitude：%f,latitude：%f,altitude：%f,course：%f,speed：%f",coordinate.longitude,coordinate.latitude,location.altitude,location.course,location.speed);
        
        self.isPositioning = NO;
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                //如果不需要实时定位，使用完及时关闭定位服务
            @synchronized(self.shareToken){
                [self.locationManager stopUpdatingLocation];
            }
        }];
    }
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error{
    if(error){
        QzLogE(@"location error:%@",error);
    }
    @synchronized (self.shareToken) {
        self.isPositioning = NO;
    }
}

@end
