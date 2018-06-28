//
//  GameTableViewController.m
//  GMBoxProject
//
//  Created by 陈雷 on 2018/6/26.
//  Copyright © 2018年 陈雷. All rights reserved.
//

#import "GameTableViewController.h"
#import "GameTableViewCell.h"
#import <MJRefresh/MJRefresh.h>
#import <SDCycleScrollView/SDCycleScrollView.h>
#import <MJExtension/MJExtension.h>
#import <SDAutoLayout/SDAutoLayout.h>
#import "Game.h"
#import "AutoScrollLabel.h"
#import "DownLoadlistViewController.h"
#import "NSString+GM.h"
#import "GameDetailViewController.h"
#import <AFNetworking/AFNetworking.h>
@interface GameTableViewController () <SDCycleScrollViewDelegate>
@property(strong,nonatomic) SDCycleScrollView * cycleScrollView;
@property(strong,nonatomic) NSMutableArray * datas;
@property(strong,nonatomic) NSMutableArray * topDatas;
@property(strong,nonatomic) NSMutableArray * notices;
@property(weak,nonatomic) AutoScrollLabel *autoScrollLabel;


@end

@implementation GameTableViewController
- (NSMutableArray *)notices{
    if (!_notices) {
        _notices = [NSMutableArray array];
    }
    
    return _notices;
}
- (NSMutableArray *)topDatas{
    if (!_topDatas) {
        _topDatas = [NSMutableArray array];
    }
    
    return _topDatas;
}
- (NSMutableArray *)datas{
    if (!_datas) {
        _datas = [NSMutableArray array];
    }
    
    return _datas;
}
- (void)viewDidLoad {
    [super viewDidLoad];
//    NSLog(@"FilePath====%@",[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:nil]);

    self.cycleScrollView = [[SDCycleScrollView alloc] initWithFrame:CGRectMake(0, 0, 0, (self.view.bounds.size.height - 64 - 55) / 4 + 20)];
    self.cycleScrollView.delegate = self;
    self.cycleScrollView.backgroundColor = [UIColor whiteColor];
    [self.tableView registerNib:[UINib nibWithNibName:@"GameTableViewCell" bundle:nil] forCellReuseIdentifier:@"GameTableViewCell"];
    self.tableView.tableFooterView = [UIView new];
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(getData)];
    [self.tableView.mj_header beginRefreshing];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"下载"] style:UIBarButtonItemStyleDone target:self action:@selector(openDownLoadList)];
    
//
  
}
- (void)openDownLoadList{
    DownLoadlistViewController * vc = [[DownLoadlistViewController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
    
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.autoScrollLabel scroll];
    
}
- (void)getData{
    __weak typeof(self) weakself = self;
    [[AFHTTPSessionManager manager]GET:@"http://hezi.wuyousy.com/iosbox/Game" parameters:@{@"qu_user":[NSString qu_user],@"qu_id":[NSString qu_id]} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable dict) {
        if ([dict[@"code"] isEqualToNumber:@1]) {
            [self.topDatas removeAllObjects];
            NSArray * tops = [GameTop mj_objectArrayWithKeyValuesArray:dict[@"top"]];
            [self.topDatas addObjectsFromArray:tops];
            self.tableView.tableHeaderView = self.cycleScrollView;
            NSMutableArray * temps  = [NSMutableArray array];
            [tops enumerateObjectsUsingBlock:^(GameTop *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [temps addObject:obj.game_logo];
            }];
            self.cycleScrollView.imageURLStringsGroup = temps;
            [self.datas removeAllObjects];
            [self.datas addObjectsFromArray:[Game mj_objectArrayWithKeyValuesArray:dict[@"gameinfo"]]];
            
            [[AFHTTPSessionManager manager]GET:@"http://hezi.wuyousy.com/iosbox/notice" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable dict) {
                if ([dict[@"code"] isEqualToNumber:@1]) {
                    [self.notices removeAllObjects];

                    [self.notices addObjectsFromArray:dict[@"data"]];
                }
                [self.tableView reloadData];
                [self.tableView.mj_header endRefreshing];
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [self.tableView.mj_header endRefreshing];
                
            }];
            
            
        }
//        [self.tableView reloadData];
//        [self.tableView.mj_header endRefreshing];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self.tableView.mj_header endRefreshing];
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"游戏列表加载失败，是否重试" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakself.tableView.mj_header beginRefreshing];
        }]];
        [weakself presentViewController:alert animated:YES completion:nil];
    }];
    
}

#pragma mark - SDCycleScrollViewDelegate
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index{
    GameTop * game  = self.topDatas[index];
    GameDetailViewController * vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"GameDetailViewController"];
    vc.hidesBottomBarWhenPushed = YES;
    vc.game_id = game.game_id;
    [self.navigationController pushViewController: vc  animated:YES];
    
}


#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return self.datas.count == 0 ? 0 : 80;
    
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView * v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 80)];
    v.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1];
    v.layer.borderColor = [[UIColor grayColor] colorWithAlphaComponent:0.2].CGColor;
    v.layer.borderWidth = 0.5;
    v.clipsToBounds = YES;
    UIImageView * img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"喇叭"]];
    img.contentMode = UIViewContentModeScaleAspectFit;
    img.frame = CGRectMake(8, 0, 25, 40);
    
    AutoScrollLabel *autoScrollLabel = [[AutoScrollLabel alloc]initWithFrame:CGRectMake(40, 0, self.view.bounds.size.width - 50, 40)];
    __block NSString * notice = @"";
    [self.notices enumerateObjectsUsingBlock:^(NSDictionary *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        notice = [notice stringByAppendingString:[NSString stringWithFormat:@"%@  ",obj[@"neirong"]]];
    }];
    autoScrollLabel.text = notice;
    autoScrollLabel.textColor = [UIColor redColor];
    [v addSubview:img];
    [v addSubview:autoScrollLabel];
    self.autoScrollLabel = autoScrollLabel;
    
    //火
    UIView * v2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 80)];
    v2.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1];
    v2.layer.borderColor = [[UIColor grayColor] colorWithAlphaComponent:0.2].CGColor;
    v2.layer.borderWidth = 0.5;
    v2.clipsToBounds = YES;
    [v addSubview:v2];
    v2.frame = CGRectMake(0, 40, self.view.bounds.size.width, 40);

    UIImageView * img2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"火"]];
    img2.contentMode = UIViewContentModeScaleAspectFit;
    img2.frame = CGRectMake(8, 0, 25, 40);
    [v2 addSubview:img2];
    UILabel * lb = [[UILabel alloc] init];
    lb.textColor = [UIColor blackColor];
    lb.font = [UIFont systemFontOfSize:15];
    lb.text = @"新游推荐";
    lb.frame = CGRectMake(40, 0, self.view.bounds.size.width, 40);

    [v2 addSubview:lb];

    return v;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datas.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GameTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"GameTableViewCell"];
    cell.game  = self.datas[indexPath.row];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self cellHeightForIndexPath:indexPath cellContentViewWidth:self.view.bounds.size.width tableView:tableView];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
   Game * game  = self.datas[indexPath.row];
    GameDetailViewController * vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"GameDetailViewController"];
    vc.hidesBottomBarWhenPushed = YES;
    vc.game_id = game.game_id;
    [self.navigationController pushViewController: vc  animated:YES];
}
@end
