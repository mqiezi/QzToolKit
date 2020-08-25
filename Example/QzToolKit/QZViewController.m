//
//  QZViewController.m
//  QzToolKit
//
//  Created by mqiezi on 08/24/2020.
//  Copyright (c) 2020 mqiezi. All rights reserved.
//

#import "QZViewController.h"
#import <QzToolKit/QzToolKit.h>
#import <CoreLocation/CoreLocation.h>

@interface QZViewController ()

@property (weak, nonatomic) IBOutlet UITextView *tv;

@property (strong) CLLocationManager* locationManager;
@property (strong) QzReachability* reachability;
@property (assign) QzNetworkStatus currenStatus;
@property (strong) NSObject* shareToken;

@end

@implementation QZViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [QzLOGGER setIsShow:YES];
    [QzLOGGER setIsWrite:YES];
    
    self.shareToken = [[NSObject alloc] init];
    
    _reachability = [QzReachability reachabilityWithHostName:@"www.baidu.com"];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kQzReachabilityChangedNotification object:nil];
    
    
    self.locationManager=[[CLLocationManager alloc]init];
    [self.locationManager requestWhenInUseAuthorization];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    [self.reachability stopNotifier];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - tests

- (IBAction)backTop:(id)sender {
    [_tv scrollRangeToVisible:NSMakeRange(0, 1)];
}

- (IBAction)backBottom:(id)sender {
    [_tv scrollRangeToVisible:NSMakeRange(_tv.text.length, 1)];
}

- (IBAction)clear:(id)sender {
    _tv.text =@"";
}

- (IBAction)test:(id)sender {
     _tv.text =@"";

    [self loadLogFile];
    
    [self testQzLocation];
    [self testQzUA];
    [self testQzKeyChain];
    [self testQzUserDefaults];
    [self testQzReachability];
    [self testQzWebFileManager];
    [self testQzCryptor];
}

- (void)loadLogFile{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *cachePath = [cachePaths objectAtIndex:0];
        NSString *filepath = [cachePath stringByAppendingPathComponent:@"Qz.log"];
        
        if (![[NSFileManager defaultManager]fileExistsAtPath:filepath]){
            return;
        }
        
        NSError *error = nil;
        NSString *str = [[NSString alloc] initWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:&error];
        if(error){
            NSLog(@"load log failed with error :%@",error);
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.tv.text = str;
            self.tv.layoutManager.allowsNonContiguousLayout = NO;
        });
    });
}

- (void)testQzLocation{
    NSDictionary* geoDic = [QzLocation geo];
    QzLogI(@"GEO: %@",geoDic);
}

- (void)testQzUA{
    NSString* ua = [QzUA UA];
    QzLogI(@"UA: %@",ua);
}

- (void)testQzReachability{
    [self.reachability startNotifier];
}

- (void)testQzWebFileManager{
    
    NSURL* downloadUrl = [NSURL URLWithString:@"http://vfx.mtime.cn/Video/2019/02/04/mp4/190204084208765161.mp4"];
    QzWebFileManager* diskFileManager =[QzWebFileManager sharedInstance];
    NSString* key = [diskFileManager cacheKeyForURL:downloadUrl];
    NSString *cachedPath= [diskFileManager filePathFromDiskCacheForKey:key];
    if(![[QzWebFileManager sharedInstance] diskFileExistsWithKey:key]){
        cachedPath = nil;
    }
    
    if (cachedPath && cachedPath.length>1) {
        QzLogI(@"video already cached to %@",cachedPath);
        return ;
    }
    [diskFileManager downloadFileWithUrl:downloadUrl completion:^(NSError * _Nullable error) {
        if(error){
            QzLogI(@"video download failed %@",error);
            return;
        }
        QzLogI(@"video cached to %@",cachedPath);
    }];
}

- (void)testQzKeyChain{
    NSString* keychainKey = @"QzTest";
    [QzKeyChain setObject:@"keychain value" forKey:keychainKey];
    
    NSString* value =  [QzKeyChain objectForKey:keychainKey];
    QzLogI(@"value from QzKeyChain: %@",value);
}

- (void)testQzUserDefaults{
    NSString* userDefaultsKey = @"QzTest";
    [QzUserDefaults setObject:@"userDefaults value" forKey:userDefaultsKey];
    
    NSString* value =  [QzUserDefaults objectForKey:userDefaultsKey];
    QzLogI(@"value from QzUserDefaults: %@",value);
}

- (void)testQzCryptor{
    
        //rsa公钥
#define Qz_RSA_PUBLIC_KEY @"-----BEGIN PUBLIC KEY-----\n\
    MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDAZz2xKE27WkPaBCaBCqM1NvSF\
    qn0aYCQNlIFnXLlqgyyLSG1c4bAk2IZ+71Znl+Rce1szBjFPuu7bex6tPtYQpdfZ\
    LRDozujpTYjfPehmhRIZ2sHCZBuyJshm1k7ZweNtReLm9zDVoSr97dTu0hUl0yeR\
    3RR8h6NVZkPOr0PjIQIDAQAB\n\
    -----END PUBLIC KEY-----"
    
        //rsa私钥
#define Qz_RSA_PRIVATE_KEY @"-----BEGIN PRIVATE KEY-----\n\
    MIICdgIBADANBgkqhkiG9w0BAQEFAASCAmAwggJcAgEAAoGBAMBnPbEoTbtaQ9oE\
    JoEKozU29IWqfRpgJA2UgWdcuWqDLItIbVzhsCTYhn7vVmeX5Fx7WzMGMU+67tt7\
    Hq0+1hCl19ktEOjO6OlNiN896GaFEhnawcJkG7ImyGbWTtnB421F4ub3MNWhKv3t\
    1O7SFSXTJ5HdFHyHo1VmQ86vQ+MhAgMBAAECgYBjvyJEjdh+oLU8eZpcm98w32S1\
    R0XEPsNyJuNPasrVZVvaeZn45SgkcfyIIhxxaFWDfJAzS6qU4xyhvJqSxljDMo9N\
    2Upybxqgzwo1SHzXyu0CKVv/CJlHUapQlB4Y4quDuIg1Ci+PJB6rAUeddgFzI/lU\
    2xQsw5h4bZkYOta44QJBAOITcybRPOnslw7SH1Hi+Js3pbH9m4LmN9b+iIETSpK8\
    TumMd/EjwHnPGUYRJtNQfyhvT9W0mq1ljWep/XM83Y8CQQDZ3swSACu7aoKD1G8h\
    HCbobkbnIzUCqSbN/3+1YsMyvH/MqnqzEvrYSnq/X7rAgmWlgI4Q83GOfjAb4miA\
    kjxPAkAfGt/4EkfYQ5YREvX+NUVRTdm9YJBZ9UTvjrvHTpkvETumRI5oHiwoVkc6\
    7bcy0dt8+7u3Qo8ZlmRbQ/c8OL6fAkEAolVGWlc0PoWiz5U2ZEY0m1SnkcsC0YO1\
    fSHVRxJafPBEjPutRsZqj0QXZ4ZtgMjn8cPylqC9SL2vHOe6k6niMwJAY0jBMKvF\
    Tjwy+xXbafinUC5tcPiCqZCIufLPzSlunZUvIJqYPXHxoPhPxxEhwM4Lse0qtsgJ\
    A5OYigVrHamdlg==\n\
    -----END PRIVATE KEY-----"
    
    NSString* string = @"this is the data.";
    NSData * data  = [string dataUsingEncoding:NSUTF8StringEncoding];
    QzLogI(@"data is %@",data);
    uint8_t randomBytes[16];
        //生成随机aes秘钥
    int result = SecRandomCopyBytes(kSecRandomDefault, 16, randomBytes);
        //秘钥生成失败，返回
    if(result != 0){
        QzLogE(@"create secret error.");
        return ;
    }
    
    NSMutableData * key = [[NSMutableData alloc]init];
    [key appendBytes:&randomBytes length:16];
    QzLogI(@"key is %@",key);
    
        //生成rsa加密的aes密钥
    NSData *encryptKey = [QzCryptor encryptData:key usingRSAWithKey:Qz_RSA_PUBLIC_KEY];
        //压缩请求data
    NSData *zipData=[QzExtension zipData:data];
        //aes加密的压缩data
    NSData *encryptData = [QzCryptor encrypt:zipData usingAES128WithKey:key];
    
        //aes解密的压缩data
    NSData *decryptData = [QzCryptor decrypt:encryptData usingAES128WithKey:key];
        //解压缩请求data
    NSData *unZipData = [QzExtension unZipData:decryptData];
    QzLogI(@"unZipData is %@",unZipData);
        //生成rsa解密的aes密钥
    NSData *decryptKey = [QzCryptor decryptData:encryptKey usingRSAWithKey:Qz_RSA_PRIVATE_KEY];
    QzLogI(@"decryptKey is %@",decryptKey);
}


#pragma mark - kQzReachabilityChangedNotification

- (void)reachabilityChanged:(NSNotification*)notification{
    QzReachability * reach = [notification object];
    @synchronized (self.shareToken) {
        if(self.currenStatus == [reach currentReachabilityStatus]){
            return;
        }
        else{
            self.currenStatus = [reach currentReachabilityStatus];
            if([reach isReachable]){
                QzLogD(@"reachabilityChanged , currenStatus update");
            }
        }
    }
}

@end
