//
//  ViewController.m
//  DemoDownload
//
//  Created by yingxin ye on 2017/4/25.
//  Copyright © 2017年 yingxin ye. All rights reserved.
//

#import "DownLoadlistViewController.h"
#import "DownloadManager.h"
#import "OneDownloadItem.h"
#import "DownloadCell.h"
#import <AFNetworking/AFNetworking.h>
#import <FORScrollViewEmptyAssistant/FORScrollViewEmptyAssistant.h>
@interface DownLoadlistViewController ()
@property(nonatomic,strong) UITableView * allGameTableView;
@property(atomic,strong) NSArray * allItemModelArr;
@end

@implementation DownLoadlistViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.allGameTableView emptyViewConfigerBlock:^(FOREmptyAssistantConfiger *configer) {
        configer.emptyTitle = @"您还没有下载游戏哦，快去下载吧";
        configer.emptyImage = [UIImage imageNamed:@"empty"];
    }];

    [self.view addSubview:self.allGameTableView];
    self.allItemModelArr = [DownloadManager manager].allItemArray;
    [self.allItemModelArr enumerateObjectsUsingBlock:^(OneDownloadItem *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"plistUrl  ---- %@",obj.plistUrl);
    }];
    self.title = @"下载列表";
    self.allGameTableView.tableFooterView = [UIView new];
    self.view.backgroundColor = [UIColor whiteColor];
    //下载过程中，数据源刷新，表格刷新
    typeof(self) __weak weakSelf = self;
    [[DownloadManager manager] progressBlock:^(NSArray *allModelArr) {
        weakSelf.allItemModelArr = allModelArr;
        [allModelArr enumerateObjectsUsingBlock:^(OneDownloadItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            DownloadCell * cell = [weakSelf.allGameTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
            [cell updateCell2:weakSelf.allItemModelArr[idx]];
        }];
    }];
    
    //下载完成自动下载，可以不选择自动下载
    [[DownloadManager manager] completeBlock:^(OneDownloadItem *oneItem) {
        [[DownloadManager manager] installIpaWithDownloadItem:oneItem];
    }];
    
}
-(UITableView*)allGameTableView
{
    if(!_allGameTableView)
    {
        _allGameTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStylePlain];
        
        _allGameTableView.dataSource = self;
        _allGameTableView.delegate = self;
    }
    return _allGameTableView;
}


#pragma mark 一共有多少组
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

#pragma mark 一共有多少行
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.allItemModelArr.count;
}

#pragma mark 每个组的高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}


#pragma mark 每个表格的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 76;
}

#pragma mark 每个表格
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier= NSStringFromClass([DownloadCell class]);
    
    DownloadCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[DownloadCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    OneDownloadItem * data = [self.allItemModelArr objectAtIndex:indexPath.row];
    [cell updateCell:data];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        OneDownloadItem * delItem = [self.allItemModelArr objectAtIndex:indexPath.row];
        [[DownloadManager manager] removeItem:delItem];
         [tableView reloadData];
    }
    
}

#pragma mark 点击表格
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
    
}
@end
