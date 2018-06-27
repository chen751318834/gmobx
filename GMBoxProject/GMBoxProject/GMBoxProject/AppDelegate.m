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
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [[AFHTTPSessionManager manager]GET:@"http://hezi.wuyousy.com/iosbox/version" parameters:@{@"qu_user":[NSString qu_user],@"qu_id":[NSString qu_id]} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable dict) {
        if ([dict[@"code"] isEqualToNumber:@1]) {
            NSDictionary * d = dict[@"versioninfo"];
            NSLog(@"dict   ---- %@",dict[@"versioninfo"]);
            NSString * version = d[@"bb"];
            NSString * nr = d[@"nr"];
            NSString * down_plist = d[@"down_plist"];
            NSLog(@"version   ---- %f",[self version:version]);

            NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
   
            NSString *app_build = [infoDictionary objectForKey:@"CFBundleVersion"];
            
            CGFloat localversion = [self version:app_build];
            NSLog(@"localversion   ---- %f   [UIDevice currentDevice].systemVersion --- %@",localversion,app_build);
            if ([self version:version] > localversion) {
                UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"检测到新版本" message:[NSString stringWithFormat:@"本次更新内容：\n\n %@",nr] preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"稍后更新" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    
                }]];
                
                [alert addAction:[UIAlertAction actionWithTitle:@"立即更新" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                    NSString * plistStr = [NSString stringWithFormat:@"itms-services://?action=download-manifest&url=%@",down_plist];
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:plistStr]];
                    
                    exit(0);
                }]];
                [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
            }
        }

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
    
    
//
    return YES;
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
