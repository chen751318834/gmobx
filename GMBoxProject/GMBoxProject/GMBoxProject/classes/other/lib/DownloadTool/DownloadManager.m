//
//  DownloadManager.m
//  DemoDownload
//
//  Created by yingxin ye on 2017/5/2.
//  Copyright © 2017年 yingxin ye. All rights reserved.
//

#import "DownloadManager.h"
#import <UIKit/UIKit.h>
#import "HTTPServer.h"
#import <Toast/Toast.h>
#import <Reachability/Reachability.h>
#define MAX_DOWNLOAD_NUM 3 //最多下载并行数

@interface DownloadManager()

@property (nonatomic, copy) void (^completeBlock)(OneDownloadItem*oneItem);
@property (nonatomic, copy) void (^progressBlock)(NSArray*allItemArr);
@property (nonatomic, strong) HTTPServer * httpServer;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundIdentify;

@end


@implementation DownloadManager


static DownloadManager *_dataCenter = nil;
+ (DownloadManager *)manager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _dataCenter = [[DownloadManager alloc] init];
        
    });
    
    return _dataCenter;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        
        _httpServer      = [HTTPServer new];
        _httpServer.type = @"_tcp";
        _httpServer.port = 10001;
        _httpServer.documentRoot = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES).firstObject;
        NSError * error = nil;
        [_httpServer start:&error];
        
        //开始本地服务器
        //获取之前保存的下载项 数组
        self.allItemArray = [NSMutableArray array];
        self.allItemArray = [self loadFromUnarchiver];
        self.backgroundIdentify = UIBackgroundTaskInvalid;
        self.backgroundIdentify = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^
                                   {
                                       //当时间快结束时，该方法会被调用。
                                       NSLog(@"Background handler called. Not running background tasks anymore.");
                                       
                                       [[UIApplication sharedApplication] endBackgroundTask:self.backgroundIdentify];
                                       
                                       self.backgroundIdentify = UIBackgroundTaskInvalid;
                                   }];
        
        //当进入时，之前队列存在的下载项所有都设置 状态暂停
        for(OneDownloadItem * oneItem in self.allItemArray)
        {
            if(oneItem.downloadStatus != DownloadStatusComplete)        //未完成的，都先暂停
            {
                oneItem.downloadStatus = DownloadStatusPause;
            }
        }
    }
    return self;
}

//下载进度的回调
-(void)progressBlock:(void(^)(NSArray*allModelArr))progressBlock
{
    self.progressBlock = progressBlock;
}

//下载完成的回调
-(void)completeBlock:(void(^)(OneDownloadItem*oneItem))completeBlock
{
    self.completeBlock = completeBlock;
}

// 添加任务到任务列表中
- (void)addDownloadTaskWithUrl:(NSString *)urlString andPlistUrl:(NSString*)plistUrl andGameName:(NSString*)gameName andGameId:(NSString*)gameId andType:(NSString*)type
{
    
    UITabBarController * tabbar = (UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    UINavigationController * nav = (UINavigationController *)tabbar.selectedViewController;

    if (!gameName ||!urlString ||!gameId ||!type || !plistUrl)
    {
        NSLog(@"-----格式无效------");
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"游戏格式无效！" message:nil preferredStyle:UIAlertControllerStyleAlert
                                               ];
        [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil]];
        
        [nav presentViewController:alertController animated:YES completion:nil];
        
        return;
    }
    
    // 防止任务重复添加
    for (OneDownloadItem * downloadItem in self.allItemArray)
    {
        if ([urlString isEqualToString:downloadItem.urlString])
        {
            NSLog(@"任务重复");
            
            UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"游戏早已经添加到下载列表了！" message:nil preferredStyle:UIAlertControllerStyleAlert
                                                   ];
            [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil]];
            
            [nav presentViewController:alertController animated:YES completion:nil];
            
            
            return;
        }
    }
    
    OneDownloadItem * oneDownloadItem = [[OneDownloadItem alloc]initWithUrl:urlString andPlistUrl:plistUrl andGameName:gameName andGameId:gameId andType:type];
    [self.allItemArray addObject:oneDownloadItem];      //先添加
    [self startDownload:oneDownloadItem];               //再下载
    return;
}

//开始下载
-(void)startDownload:(OneDownloadItem*)oneItem
{
    oneItem.downloadStatus = DownloadStatusWaiting;
    [self updateProcessList];
}

//暂停下载
-(void)pauseDownload:(OneDownloadItem*)oneItem
{
    oneItem.downloadStatus = DownloadStatusPause;
    [self updateProcessList];
}

//完成下载
-(void)callbackDownloadComplete:(OneDownloadItem*)oneItem
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateProcessList];           //进行下一个队列
        if(self.completeBlock) self.completeBlock(oneItem);
    });
}

//处理队列
-(void)updateProcessList
{
    //先处理所有的暂停操作
    for(OneDownloadItem * oneItem in self.allItemArray)
    {
        if(oneItem.downloadStatus == DownloadStatusPause)
        {
            [oneItem pauseModelDownload];
        }
    }
    
    //当前下载数 小于 下载总数的 才处理
    for(OneDownloadItem * oneItem in self.allItemArray)
    {
        int nowDowningInt = [self nowDowningNum];
        if(nowDowningInt < MAX_DOWNLOAD_NUM)
        {
            if(oneItem.downloadStatus == DownloadStatusWaiting)
            {
                [oneItem startModelDownload];
                nowDowningInt ++;
            }
        }
    }
}

-(int)nowDowningNum
{
    int tempNow = 0;
    for(OneDownloadItem * oneItem in self.allItemArray)
    {
        if(oneItem.downloadStatus == DownloadStatusDownloading)
        {
            tempNow ++;
        }
    }
    return tempNow;
}

//下载ipa
-(void)installIpaWithDownloadItem:(OneDownloadItem*)oneItem
{
    NSString * plistStr = [NSString stringWithFormat:@"itms-services://?action=download-manifest&url=%@",oneItem.plistUrl];

    NSURL * url = [NSURL URLWithString:plistStr];
    if (![[UIApplication sharedApplication] canOpenURL:url]) {
        UITabBarController * tabbar = (UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        UINavigationController * nav = (UINavigationController *)tabbar.selectedViewController;
        
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"游戏下载地址有误,无法完成下载 \n\n %@",oneItem.plistUrl] message:nil preferredStyle:UIAlertControllerStyleAlert
                                               ];
        [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil]];
        
        [nav presentViewController:alertController animated:YES completion:nil];
        
        
        return;
    }
    [[UIApplication sharedApplication].keyWindow makeToastActivity:CSToastPositionCenter];
    Reachability* reach = [Reachability reachabilityWithHostname:@"http://127.0.0.1"];
    if ([reach currentReachabilityStatus] == NotReachable) {
        [self.httpServer start:nil];
        if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication] openURL:url options:nil completionHandler:^(BOOL success) {
                if (success) {
                    [[UIApplication sharedApplication].keyWindow hideToastActivity];
                    
                }else{
                    [[UIApplication sharedApplication].keyWindow makeToast:@"下载链接有误，无法完成下载！"];
                }
            }];
        } else {
            [[UIApplication sharedApplication]  openURL:url];
            [[UIApplication sharedApplication].keyWindow hideToastActivity];
            
            // Fallback on earlier versions
        }
    }else{
        
        if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication] openURL:url options:nil completionHandler:^(BOOL success) {
                if (success) {
                    [[UIApplication sharedApplication].keyWindow hideToastActivity];
                    
                }else{
                    [[UIApplication sharedApplication].keyWindow makeToast:@"下载链接有误，无法完成下载！"];
                }
            }];
        } else {
            [[UIApplication sharedApplication]  openURL:url];
            [[UIApplication sharedApplication].keyWindow hideToastActivity];

            // Fallback on earlier versions
        }
    }
}

//删除一个下载项
-(void)removeItem:(OneDownloadItem*)oneItem
{
    [self pauseDownload:oneItem];       //先暂停
    [self.allItemArray removeObject:oneItem];   //总数组删除这个元素
    [self deleteFile:oneItem.saveName];         //删除对应的文件
    [self saveArchiverAndUpdateUI];             //保存刷新界面
}

/**文件存放路径*/
-(NSString*)getFilePath:(NSString*)saveName
{
//    NSLog(@"FilePath====%@",[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:saveName]);
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:saveName];
}

//删除沙盒文件
-(void)deleteFile:(NSString*)fileName
{
    NSString * delPath = [self getFilePath:fileName];
    BOOL isHave=[[NSFileManager defaultManager] fileExistsAtPath:delPath];
    if (!isHave)
    {
        NSLog(@"no have file");
        return;
    }else {
        BOOL isDel= [[NSFileManager defaultManager] removeItemAtPath:delPath error:nil];
        if (isDel)
        {
            NSLog(@"del success");
        }
        else
        {
            NSLog(@"del fail");
        }
    }
}


/**已经下载的文件长度*/
-(NSInteger)getAlreadyDownloadLength:(NSString*)saveName
{
    return [[[NSFileManager defaultManager]attributesOfItemAtPath:[self getFilePath:saveName] error:nil][NSFileSize] integerValue];
}


/**文件总长度字典存放的路径*/
-(NSString *)getAllItemArrayPath
{
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"allItemArray.data"];
}

//更新下载项的状态，并保存和更新界面
-(void)updateModel:(OneDownloadItem*)oneModel andStatus:(DownloadStatus)downloadStatus
{
    oneModel.downloadStatus = downloadStatus;
    [self saveArchiverAndUpdateUI];
}

//所有下载item归档
-(void)saveArchiverAndUpdateUI
{
    NSMutableArray * temps = [NSMutableArray array];
    [temps addObjectsFromArray:self.allItemArray];
    [NSKeyedArchiver archiveRootObject:temps toFile:[self getAllItemArrayPath]];
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.progressBlock) self.progressBlock(self.allItemArray);  //回调界面
    });
}

//反归档
-(NSMutableArray*)loadFromUnarchiver
{
    NSMutableArray * decodedArray = [NSKeyedUnarchiver unarchiveObjectWithFile:[self getAllItemArrayPath]];
    if(!decodedArray)
    {
        decodedArray = [NSMutableArray array];
    }
    return decodedArray;
}




@end
