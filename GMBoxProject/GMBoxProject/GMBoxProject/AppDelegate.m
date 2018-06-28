//
//  AppDelegate.m
//  GMBoxProject
//
//  Created by 陈雷 on 2018/6/26.
//  Copyright © 2018年 陈雷. All rights reserved.
//

#import "AppDelegate.h"
#import <AFNetworking/AFNetworking.h>
#import "NSString+GM.h"
#import "JANALYTICSService.h"
#import <JSPatchPlatform/JSPatch.h>
#import <Reachability/Reachability.h>

#define  jspatchPublicKey @"-----BEGIN PUBLIC KEY-----MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDsHsl93+6hHsOWfp/3GTKy9nvucHRFQ+4KfxVspSppAIliefzlSMW1aCR3yx0wNAXB0569w3gPVMJlesR+5I4Aiv/y6V8/xnVaA02kWtnXnyd3GginHA7T11nQfJ7wt7XHTM6f+BsVs6rcjubNEC/Le1Mav7dapyckbj1WhlVhUQIDAQAB-----END PUBLIC KEY-----"
#define jspatchAppKey @"ea4055fc34a48b3f"

@interface AppDelegate ()
@property(assign,nonatomic)bool update;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [JSPatch setupCallback:^(JPCallbackType type, NSDictionary *data, NSError *error) {
        if (type == JPCallbackTypeRunScript) {
        }
    }];
    
    //        [JSPatch testScriptInBundle];
    [JSPatch startWithAppKey:jspatchAppKey];
    [JSPatch setupRSAPublicKey:jspatchPublicKey];
    [JSPatch sync];
    
//    JANALYTICSLaunchConfig * config = [[JANALYTICSLaunchConfig alloc] init];
//    
//    config.appKey = @"ec215059719ac58dbb9cd2f2";
//    
//    config.channel = [NSString qu_user];
//    
//    [JANALYTICSService setupWithConfig:config];
//    [JANALYTICSService setFrequency:0];
//    [JANALYTICSService crashLogON];
    [self updateapp];

    Reachability* reach = [Reachability reachabilityForInternetConnection];
    __weak typeof(self) wself = self;
    // Set the blocks
    reach.reachableBlock = ^(Reachability*reach)
    {
        // keep in mind this is called on a background thread
        // and if you are updating the UI it needs to happen
        // on the main thread, like this:
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"REACHABLE!");
            [wself updateapp];
            
        });
    };
    
    reach.unreachableBlock = ^(Reachability*reach)
    {
        NSLog(@"UNREACHABLE!");
    };
    
    // Start the notifier, which will cause the reachability object to retain itself!
    [reach startNotifier];

    
    
//
    return YES;
}
- (void)updateapp{
    if (self.update) {
        return;
    }
    [[AFHTTPSessionManager manager]GET:@"http://hezi.wuyousy.com/iosbox/version" parameters:@{@"qu_user":[NSString qu_user],@"qu_id":[NSString qu_id]} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable dict) {
        if ([dict[@"code"] isEqualToNumber:@1]) {
            self.update = YES;
            NSDictionary * d = dict[@"versioninfo"];
            NSLog(@"dict   ---- %@",dict[@"versioninfo"]);
            NSString * version = d[@"bb"];
            NSString * nr = d[@"nr"];
            NSString * down_plist = d[@"down_plist"];
            //            NSString * down_url = d[@"down_url"];
            NSLog(@"version   ---- %f",[self version:version]);
            
            NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
            
            NSString *app_build = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
            
            CGFloat localversion = [self version:app_build];
            NSLog(@"localversion   ---- %f   [UIDevice currentDevice].systemVersion --- %@",localversion,app_build);
            if ([self version:version] != localversion) {
                
                AFHTTPSessionManager * manager =  [AFHTTPSessionManager manager];
                manager.responseSerializer = [AFHTTPResponseSerializer serializer];
                [manager GET:[NSString stringWithFormat:@"http://down.wuyousy.com/down.php?game_type=iosgmbox&game_bs=GMBoxProject&qu_id=%@",[NSString qu_id]] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable data) {
                    
                    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"检测到新版本" message:[NSString stringWithFormat:@"本次更新内容：\n\n %@",nr] preferredStyle:UIAlertControllerStyleAlert];
                    [alert addAction:[UIAlertAction actionWithTitle:@"稍后更新" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                        
                    }]];
                    
                    [alert addAction:[UIAlertAction actionWithTitle:@"立即更新" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        
                        NSString * plistStr = [NSString stringWithFormat:@"itms-services://?action=download-manifest&url=%@",down_plist];
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:plistStr]];
                        
                        exit(0);
                    }]];
                    [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"检测到新版本" message:[NSString stringWithFormat:@"本次更新内容：\n\n %@",nr] preferredStyle:UIAlertControllerStyleAlert];
                    [alert addAction:[UIAlertAction actionWithTitle:@"稍后更新" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                        
                    }]];
                    
                    [alert addAction:[UIAlertAction actionWithTitle:@"立即更新" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        
                        NSString * plistStr = [NSString stringWithFormat:@"itms-services://?action=download-manifest&url=%@",down_plist];
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:plistStr]];
                        
                        exit(0);
                    }]];
                    [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
                }];
                
                
            }
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
    
}
- (CGFloat )version:(NSString *)version{
    
    
    NSRange fRange = [version rangeOfString:@"."];
    
    
    CGFloat v = 0.0f;
    
    if(fRange.location != NSNotFound){
        version = [version stringByReplacingOccurrencesOfString:@"." withString:@""];
        NSMutableString *mVersion = [NSMutableString stringWithString:version];
        [mVersion insertString:@"." atIndex:fRange.location];
        v = [mVersion floatValue];
    }else {
        // 版本应该有问题(由于ios 的版本 是7.0.1，没有发现出现过没有小数点的情况)
        v = [version floatValue];
    }
    
    return v;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
