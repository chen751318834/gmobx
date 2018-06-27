//
//  KFBViewController.m
//  GMBoxProject
//
//  Created by 陈雷 on 2018/6/26.
//  Copyright © 2018年 陈雷. All rights reserved.
//

#import "KFBViewController.h"
#import <MJExtension/MJExtension.h>
#import <MJRefresh/MJRefresh.h>
#import <AFNetworking/AFNetworking.h>
#import "KFB.h"
#import "KFBTableViewCell.h"
#import "GameDetailViewController.h"
#import <FORScrollViewEmptyAssistant/FORScrollViewEmptyAssistant.h>
@interface KFBViewController ()
@property(strong,nonatomic) NSMutableArray * datas;
@property(assign,nonatomic)bool shouldDisplay;

@end

@implementation KFBViewController
- (NSMutableArray *)datas{
    if (!_datas) {
        _datas = [NSMutableArray array];
    }
    
    return _datas;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    __weak typeof(self)weakself = self;
    [self.tableView emptyViewConfigerBlock:^(FOREmptyAssistantConfiger *configer) {
        configer.emptyTitle = @"这周还没有游戏开服！";
        configer.emptyImage = [UIImage imageNamed:@"empty"];
        configer.shouldDisplay = ^BOOL{
            return weakself.shouldDisplay;
        };
    }];
    [self.tableView registerNib:[UINib nibWithNibName:@"KFBTableViewCell" bundle:nil] forCellReuseIdentifier:@"KFBTableViewCell"];
    self.tableView.tableFooterView = [UIView new];
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(getData)];
    [self.tableView.mj_header beginRefreshing];
}

- (void)getData{
    [[AFHTTPSessionManager manager]GET:@"http://hezi.wuyousy.com/iosbox/table" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable dict) {
        if ([dict[@"code"] isEqualToNumber:@1]) {
            [self.datas removeAllObjects];
            [self.datas addObjectsFromArray:[KFB mj_objectArrayWithKeyValuesArray:dict[@"data"]]];
        }
        [self.tableView reloadData];
        [self.tableView.mj_header endRefreshing];
        self.shouldDisplay = YES;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self.tableView.mj_header endRefreshing];
        
    }];
    
}
#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datas.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    KFBTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"KFBTableViewCell"];
    cell.kfb  = self.datas[indexPath.row];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 76;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
  KFB *  kfb  = self.datas[indexPath.row];

    GameDetailViewController * vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"GameDetailViewController"];
    vc.hidesBottomBarWhenPushed = YES;
    vc.game_id = kfb.game_id;
    [self.navigationController pushViewController: vc  animated:YES];
}


@end
