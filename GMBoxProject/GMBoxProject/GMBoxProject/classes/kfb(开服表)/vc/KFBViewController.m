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
#import <Toast/Toast.h>
#import "GameDetailViewController.h"
#import <FORScrollViewEmptyAssistant/FORScrollViewEmptyAssistant.h>
@interface KFBViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UISegmentedControl *segc;
@property(strong,nonatomic) NSMutableArray * datas;
@property(strong,nonatomic) NSMutableArray * data2s;
@property(strong,nonatomic) NSMutableArray * data3s;
@property(assign,nonatomic)bool shouldDisplay;
@property(assign,nonatomic)NSInteger index;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation KFBViewController
- (NSMutableArray *)data2s{
    if (!_data2s) {
        _data2s = [NSMutableArray array];
    }
    return _data2s;
}
- (NSMutableArray *)data3s{
    if (!_data3s) {
        _data3s = [NSMutableArray array];
    }
    return _data3s;
}
- (NSMutableArray *)datas{
    if (!_datas) {
        _datas = [NSMutableArray array];
    }
    return _datas;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.index = 0;
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
    [self getData];
}
- (IBAction)segmentedControlValueChanged:(UISegmentedControl *)sender {
    self.index = sender.selectedSegmentIndex;
    [self.tableView reloadData];
}

-(NSString *)getUTCFormateDate:(NSDate *)newsDate
{
    
    
    NSString *dateContent;
    NSTimeInterval secondsPerDay = 24 * 60 * 60;
    NSDate *today=[[NSDate alloc] init];
    NSDate *yearsterDay =  [[NSDate alloc] initWithTimeIntervalSinceNow:-secondsPerDay];
    NSDate *qianToday =  [[NSDate alloc] initWithTimeIntervalSinceNow:-2*secondsPerDay];
    NSDate *mtToday =  [[NSDate alloc] initWithTimeIntervalSinceNow:secondsPerDay];
    //假设这是你要比较的date：NSDate *yourDate = ……
    //日历
    NSCalendar* calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:newsDate];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:yearsterDay];
    NSDateComponents* comp3 = [calendar components:unitFlags fromDate:qianToday];
    NSDateComponents* comp4 = [calendar components:unitFlags fromDate:today];
    NSDateComponents* comp5 = [calendar components:unitFlags fromDate:mtToday];
    if ( comp1.year == comp2.year && comp1.month == comp2.month && comp1.day == comp2.day) {
        dateContent = @"昨天";
    }
    else if (comp1.year == comp3.year && comp1.month == comp3.month && comp1.day == comp5.day)
    {
        dateContent = @"明天";
    }
    else if (comp1.year == comp4.year && comp1.month == comp4.month && comp1.day == comp4.day)
    {
        dateContent = @"今天";
    }
    else
    {
        //返回0说明该日期不是今天、昨天、前天
        dateContent = @"0";
    }
    return dateContent;
}

- (void)getData{
    [self.view makeToastActivity:CSToastPositionCenter];
    [[AFHTTPSessionManager manager]GET:@"http://hezi.wuyousy.com/iosbox/table" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable dict) {
        if ([dict[@"code"] isEqualToNumber:@1]) {
            NSDateFormatter * form = [[NSDateFormatter alloc] init];
            form.dateFormat = @"YYYY-MM-dd HH:mm:ss";
//
            [self.datas removeAllObjects];
            [self.data2s removeAllObjects];
            [self.data3s removeAllObjects];
            NSArray * datas = [KFB mj_objectArrayWithKeyValuesArray:dict[@"data"]];
            [datas enumerateObjectsUsingBlock:^(KFB *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString * date = [self getUTCFormateDate:[form dateFromString:obj.open_time]];
                NSLog(@"date --- %@",date);
                if ([date isEqualToString:@"昨天"]) {
                    [self.data2s addObject:obj];
                }else if ([date isEqualToString:@"今天"]){
                    [self.datas addObject:obj];
                }else if ([date isEqualToString:@"明天"]){
                    [self.data3s addObject:obj];
                }
            }];
//            [self.datas addObjectsFromArray:[KFB mj_objectArrayWithKeyValuesArray:dict[@"data"]]];
        }
        [self.tableView reloadData];
        self.shouldDisplay = YES;
        [self.view hideToastActivity];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self.view hideToastActivity];

    }];
    
}
#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.index == 0) {
        return self.datas.count;

    }else if (self.index == 1){
        return self.data2s.count;

    }
    return self.data3s.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    KFBTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"KFBTableViewCell"];
    if (self.index == 0) {
        cell.kfb  = self.datas[indexPath.row];

    }else if (self.index == 1){
        cell.kfb  = self.data2s[indexPath.row];

    }else{
        cell.kfb  = self.data3s[indexPath.row];

        
    }
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 76;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    KFB *  kfb ;
    if (self.index == 0) {
        kfb  = self.datas[indexPath.row];

    }else if (self.index == 1){
        kfb  = self.data2s[indexPath.row];
    }else{
        
        kfb  = self.data3s[indexPath.row];
    }
    

    GameDetailViewController * vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"GameDetailViewController"];
    vc.hidesBottomBarWhenPushed = YES;
    vc.game_id = kfb.game_id;
    [self.navigationController pushViewController: vc  animated:YES];
}


@end
