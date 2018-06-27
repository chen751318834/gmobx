
//
//  KFBTableViewCell.m
//  GMBoxProject
//
//  Created by 陈雷 on 2018/6/26.
//  Copyright © 2018年 陈雷. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>
#import "KFBTableViewCell.h"
#import <AFNetworking/AFNetworking.h>
#import "NSString+GM.h"
#import <Toast/Toast.h>
#import "DownloadManager.h"
#import "DownLoadlistViewController.h"
@interface KFBTableViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *iconimg;
@property (weak, nonatomic) IBOutlet UILabel *namelb;
@property (weak, nonatomic) IBOutlet UILabel *subnamelb;

@end
@implementation KFBTableViewCell
- (void)setKfb:(KFB *)kfb{
    _kfb = kfb;
    self.namelb.text = kfb.game_name;
    self.subnamelb.text = [NSString stringWithFormat:@"%@ | %@",kfb.open_time,kfb.area];
    
    if (self.iconimg.image == nil) {
        [[AFHTTPSessionManager manager]GET:@"http://hezi.wuyousy.com/iosbox/details?qu_user=yuxuan&qu_id=1000001&game_id=1197" parameters:@{@"qu_user":[NSString qu_user],@"qu_id":[NSString qu_id],@"game_id":kfb.game_id} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable dict) {
            if ([dict[@"code"] isEqualToNumber:@1]) {
                kfb.game_logo = dict[@"gameinfo"][@"game_icon"];
                kfb.down_plist = dict[@"gameinfo"][@"down_plist"];
                kfb.local_plist = dict[@"gameinfo"][@"local_plist"];

            }

            [self.iconimg sd_setImageWithURL:[NSURL URLWithString:kfb.game_logo] placeholderImage:[UIImage imageNamed:@"placeholderImage"]];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
        }];
    }


}

- (IBAction)install:(id)sender {
    if (self.kfb.down_plist) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"itms-services://?action=download-manifest&url=%@",self.kfb.down_plist]]];
        
        [self installApp:self.kfb];

    }else{
        [[AFHTTPSessionManager manager]GET:@"http://hezi.wuyousy.com/iosbox/details?qu_user=yuxuan&qu_id=1000001&game_id=1197" parameters:@{@"qu_user":[NSString qu_user],@"qu_id":[NSString qu_id],@"game_id":self.kfb.game_id} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable dict) {
            if ([dict[@"code"] isEqualToNumber:@1]) {
                self.kfb.game_logo = dict[@"gameinfo"][@"game_icon"];
                self.kfb.down_plist = dict[@"gameinfo"][@"down_plist"];
                self.kfb.local_plist = dict[@"gameinfo"][@"local_plist"];
            }
            [self installApp:self.kfb];
//            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"itms-services://?action=download-manifest&url=%@",self.kfb.down_plist]]];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
        }];
    }

    

}
- (void)installApp:(KFB *)model{
    UITabBarController * tabbar = (UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    UINavigationController * nav = (UINavigationController *)tabbar.selectedViewController;
    [[UIApplication sharedApplication].keyWindow makeToastActivity:CSToastPositionCenter];
    AFHTTPSessionManager * manager =  [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:model.down_plist parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable data) {
        NSString * string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"string   --- %@",string);
        NSRange startRange = [string rangeOfString:@"<string>http://"];
        NSRange endRange = [string rangeOfString:@"ipa</string>"];
        NSRange range = NSMakeRange(startRange.location + startRange.length, endRange.location - startRange.location - startRange.length);
        NSString *result = [string substringWithRange:range];
        [[UIApplication sharedApplication].keyWindow hideToastActivity];
        NSString * end = [NSString stringWithFormat:@"http://%@ipa",result];
        
        NSRange startRange2 = [end rangeOfString:@"/yuxuan_"];
        NSRange endRange2 = [end rangeOfString:@".ipa"];
        NSRange range2 = NSMakeRange(startRange2.location + startRange2.length, endRange2.location - startRange2.location - startRange2.length);
        NSString *result2 = [end substringWithRange:range2];
        
        
        [[DownloadManager manager] addDownloadTaskWithUrl:[NSString stringWithFormat:@"http://%@ipa",result]  andPlistUrl:model.local_plist andGameName:model.game_name andGameId:[NSString stringWithFormat:@"yuxuan_%@",result2] andType:model.game_logo];
        
        UIAlertController * alertControlle = [UIAlertController alertControllerWithTitle:@"已经添加游戏到下载列表" message:nil preferredStyle:UIAlertControllerStyleAlert
                                              ];
        [alertControlle addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [alertControlle addAction:[UIAlertAction actionWithTitle:@"查看" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            DownLoadlistViewController * vc = [[DownLoadlistViewController alloc] init];
            vc.hidesBottomBarWhenPushed = YES;
            [nav pushViewController:vc animated:YES];
        }]];
        [nav presentViewController:alertControlle animated:YES completion:nil];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [[UIApplication sharedApplication].keyWindow hideToastActivity];
        
    }];
    
}

@end
