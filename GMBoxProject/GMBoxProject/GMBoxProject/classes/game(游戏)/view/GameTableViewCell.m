//
//  GameTableViewCell.m
//  GMBoxProject
//
//  Created by 陈雷 on 20110/6/26.
//  Copyright © 20110年 陈雷. All rights reserved.
//

#import "GameTableViewCell.h"
#import <SDAutoLayout/SDAutoLayout.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <AFNetworking/AFNetworking.h>
#import "DownLoadlistViewController.h"
#import "DownloadManager.h"
#import <Toast/Toast.h>
@interface GameTableViewCell  ()
@property (weak, nonatomic) IBOutlet UIButton *installbtn;
@property (weak, nonatomic) IBOutlet UILabel *inslb;
@property (weak, nonatomic) IBOutlet UILabel *namelb;
@property (weak, nonatomic) IBOutlet UIImageView *iconimg;

@end
@implementation GameTableViewCell
- (void)awakeFromNib{
    [super awakeFromNib];
    self.iconimg.sd_layout.leftSpaceToView(self.contentView, 10).topSpaceToView(self.contentView, 10).widthIs(60).heightEqualToWidth();
    self.installbtn.sd_layout.rightSpaceToView(self.contentView, 10).widthIs(50).heightIs(30).centerXEqualToView(self.contentView);
    self.namelb.sd_layout.leftSpaceToView(self.iconimg, 5).topEqualToView(self.iconimg).rightSpaceToView(self.installbtn, 5);
    self.inslb.sd_layout.leftEqualToView(self.namelb).topSpaceToView(self.namelb, 5).rightEqualToView(self.namelb).autoHeightRatio(0);
    [self setupAutoHeightWithBottomViewsArray:@[self.iconimg,self.inslb] bottomMargin:10];
}
- (void)setGame:(Game *)game{
    _game = game;
    [self.iconimg sd_setImageWithURL:[NSURL URLWithString:game.game_icon] placeholderImage:[UIImage imageNamed:@"placeholderImage"]];
    self.namelb.text = game.name;
    self.inslb.text = game.introduce;
    
}
- (IBAction)install:(id)sender {
    UITabBarController * tabbar = (UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    UINavigationController * nav = (UINavigationController *)tabbar.selectedViewController;
    [[UIApplication sharedApplication].keyWindow makeToastActivity:CSToastPositionCenter];
    AFHTTPSessionManager * manager =  [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:self.game.down_plist parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable data) {
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
        
        
        [[DownloadManager manager] addDownloadTaskWithUrl:[NSString stringWithFormat:@"http://%@ipa",result]  andPlistUrl:self.game.local_plist andGameName:self.game.name andGameId:[NSString stringWithFormat:@"yuxuan_%@",result2] andType:self.game.game_icon];

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
