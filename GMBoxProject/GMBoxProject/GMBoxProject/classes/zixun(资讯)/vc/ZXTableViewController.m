//
//  ZXTableViewController.m
//  GMBoxProject
//
//  Created by 陈雷 on 2018/6/26.
//  Copyright © 2018年 陈雷. All rights reserved.
//

#import "ZXDetailViewController.h"
#import "ZXTableViewController.h"
#import "ZXTableViewCell.h"
#import "ZxModel.h"
#import "NSString+GM.h"
#import <MJExtension/MJExtension.h>
#import <MJRefresh/MJRefresh.h>
#import <AFNetworking/AFNetworking.h>
#import <SDAutoLayout/SDAutoLayout.h>
#import <FORScrollViewEmptyAssistant/FORScrollViewEmptyAssistant.h>
@interface ZXTableViewController ()
@property(strong,nonatomic) NSMutableArray * datas;
@property(assign,nonatomic)  bool shouldDisplay;

@end

@implementation ZXTableViewController
- (NSMutableArray *)datas{
    if (!_datas) {
        _datas = [NSMutableArray array];
    }
    
    return _datas;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.userInteractionEnabled = NO;

    __weak typeof(self)weakself = self;
    [self.tableView emptyViewConfigerBlock:^(FOREmptyAssistantConfiger *configer) {
        configer.emptyTitle = @"暂无资讯！";
        configer.emptyImage = [UIImage imageNamed:@"empty"];
        configer.shouldDisplay = ^BOOL{
            return weakself.shouldDisplay;
        };
    }];
    [self.tableView registerNib:[UINib nibWithNibName:@"ZXTableViewCell" bundle:nil] forCellReuseIdentifier:@"ZXTableViewCell"];
    self.tableView.tableFooterView = [UIView new];
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(getData)];
    [self.tableView.mj_header beginRefreshing];
}

- (void)getData{
    self.tableView.userInteractionEnabled = NO;

    [[AFHTTPSessionManager manager]GET:@"http://fggood.com:8000/new/new_api.php" parameters:@{@"user":[NSString qu_user]} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable dict) {
        [self.datas removeAllObjects];
        [self.datas addObjectsFromArray:[ZxModel mj_objectArrayWithKeyValuesArray:dict[@"xinwen"]]];
        [self.tableView reloadData];
        [self.tableView.mj_header endRefreshing];
        self.shouldDisplay = YES;
        self.tableView.userInteractionEnabled = YES;

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self.tableView.mj_header endRefreshing];
        self.tableView.userInteractionEnabled = YES;

    }];
    
}
#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datas.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZXTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ZXTableViewCell"];
    cell.model  = self.datas[indexPath.row];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self cellHeightForIndexPath:indexPath cellContentViewWidth:self.view.bounds.size.width tableView:tableView];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
   ZxModel * model  = self.datas[indexPath.row];
    ZXDetailViewController * vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ZXDetailViewController"];
    vc.ID = model.ID;
    vc.title = model.bt;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}



@end
