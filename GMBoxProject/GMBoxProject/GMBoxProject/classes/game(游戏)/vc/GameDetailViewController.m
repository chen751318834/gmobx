//
//  GameDetailViewController.m
//  GMBoxProject
//
//  Created by 陈雷 on 2018/6/26.
//  Copyright © 2018年 陈雷. All rights reserved.
//

#import "GameDetailViewController.h"
#import <AFNetworking/AFNetworking.h>
#import <MJExtension/MJExtension.h>
#import "GameDetail.h"
#import "NSString+GM.h"
#import "GameDetailHeaderView.h"
#import <Toast/Toast.h>
#import "GameDetail.h"
#import "DownLoadlistViewController.h"
#import "DownloadManager.h"
#import <KSPhotoBrowser/KSPhotoBrowser.h>
@interface GameDetailViewController () <UITableViewDelegate,UITableViewDataSource,GameDetailHeaderViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic)  GameDetailHeaderView *headerView;
@property (strong, nonatomic)  GameDetail *gameDetail;

@end

@implementation GameDetailViewController
- (GameDetailHeaderView *)headerView{
    if (!_headerView) {
        _headerView = [GameDetailHeaderView headerView];
    }
    return _headerView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"游戏专区";
    if ([[UIDevice currentDevice].systemVersion floatValue] < 11.0) {
        self.tableView.contentInset = UIEdgeInsetsMake(-64, 0, 0, 0);
    }
    self.headerView.delegate = self;
    self.tableView.alpha = 0;
    self.headerView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 457);
    self.tableView.tableHeaderView = self.headerView;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    self.tableView.tableFooterView = [UIView new];
    [self getData];
}
- (IBAction)install:(UIButton *)sender {
    [self installApp:self.gameDetail];
}
- (void)installApp:(GameDetail *)model{
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
        
        
        [[DownloadManager manager] addDownloadTaskWithUrl:[NSString stringWithFormat:@"http://%@ipa",result]  andPlistUrl:model.local_plist andGameName:model.name andGameId:[NSString stringWithFormat:@"yuxuan_%@",result2] andType:model.game_icon];
        
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
- (void)getData{
    [self.view makeToastActivity:CSToastPositionCenter];
    [[AFHTTPSessionManager manager]GET:@"http://hezi.wuyousy.com/iosbox/details" parameters:@{@"qu_user":[NSString qu_user],@"qu_id":[NSString qu_id],@"game_id":self.game_id} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable dict) {
        if ([dict[@"code"] isEqualToNumber:@1]) {
            self.gameDetail = [GameDetail mj_objectWithKeyValues:dict[@"gameinfo"]];
            self.headerView.gameDetail = self.gameDetail;
        }
        [self.tableView reloadData];
        [self.view hideToastActivity];
        self.tableView.alpha = 1;

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self.view hideToastActivity];
        self.tableView.alpha = 1;

    }];
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.textLabel.text = self.gameDetail.details;
    cell.textLabel.font = [UIFont systemFontOfSize:17];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.textColor = [[UIColor grayColor] colorWithAlphaComponent:0.7 ];;
    return cell;
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self.gameDetail.details boundingRectWithSize:CGSizeMake(self.view.bounds.size.width - 16, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]} context:nil].size.height + 40;
    
}
#pragma mark - GameDetailHeaderViewDelegate
- (void)didClickImageViewWithIndex:(NSInteger)index img:(UIView *)img{
    NSMutableArray * temps = [NSMutableArray array];
    [self.gameDetail.tu enumerateObjectsUsingBlock:^(GameDetailImage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [temps addObject:obj.jietu];
    }];
    NSMutableArray *items = @[].mutableCopy;
    for (int i = 0; i < temps.count; i++) {
        KSPhotoItem *item = [KSPhotoItem itemWithSourceView:(UIImageView *)img imageUrl:[NSURL URLWithString:temps[i]]];
        [items addObject:item];
    }
    KSPhotoBrowser *browser = [KSPhotoBrowser browserWithPhotoItems:items selectedIndex:index];
    [browser showFromViewController:self];
}

@end
