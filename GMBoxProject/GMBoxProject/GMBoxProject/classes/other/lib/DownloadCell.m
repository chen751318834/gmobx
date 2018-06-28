//
//  DownloadCell.m
//  DemoDownload
//
//  Created by yingxin ye on 2017/5/3.
//  Copyright © 2017年 yingxin ye. All rights reserved.
//

#import "DownloadCell.h"
#import "DownloadManager.h"
#import <SDWebImage/UIImageView+WebCache.h>
@interface DownTask()

@end

@implementation DownTask
- (NSString*)formatByteCount:(long long)size
{
    return [NSByteCountFormatter stringFromByteCount:size countStyle:NSByteCountFormatterCountStyleFile];
}
@end


@interface DownloadCell()
{
    OneDownloadItem * _myDownloadItem;
    UILabel * _gameNameLabel;
    UILabel * _progressLabel;
    UIButton * _startDownloadBtn;
    UIButton * _pauseBtn;
    UIButton * _installBtn;
    UIProgressView * _proView;
    UIImageView * _img;
}
@property(strong,nonatomic) DownTask * downTask;
@end


@implementation DownloadCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.downTask = [[DownTask alloc] init];
        [self initData];
        [self initView];
    }
    return self;
}


-(void)initData
{
    
}

-(void)initView
{
    
    _img = [[UIImageView alloc] initWithFrame:CGRectMake(8, 8, 60, 60)];
    _img.contentMode = UIViewContentModeScaleToFill;
    _img.layer.cornerRadius = 4;
    _img.clipsToBounds = YES;
    [self.contentView addSubview:_img];

    _gameNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(76, 8, [UIScreen mainScreen].bounds.size.width - 76 - 8, 20)];
    _gameNameLabel.font = [UIFont systemFontOfSize:16];
    _gameNameLabel.textColor = [UIColor blackColor];
    [self.contentView addSubview:_gameNameLabel];

    _proView = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleBar];
    _proView.frame=CGRectMake(CGRectGetMinX(_gameNameLabel.frame), 45, [UIScreen mainScreen].bounds.size.width - 76 - 8 - 50 - 8, 50);
    //设置进度条颜色
    _proView.transform = CGAffineTransformMakeScale(1.0f,3.0f);

    _proView.trackTintColor=[UIColor grayColor];
    //设置进度默认值，这个相当于百分比，范围在0~1之间，不可以设置最大最小值
    _proView.progress=0;
    //设置进度条上进度的颜色
    _proView.progressTintColor=[UIColor redColor];
    //设置进度值并动画显示
    [self.contentView addSubview:_proView];
    
    _progressLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(_proView.frame), 52, _proView.frame.size.width, 20)];
    _progressLabel.textAlignment = NSTextAlignmentCenter;
    _progressLabel.font = [UIFont systemFontOfSize:12];
    _progressLabel.textColor = [UIColor blackColor];
    [self.contentView addSubview:_progressLabel];
    
    _startDownloadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _startDownloadBtn.frame = CGRectMake( [UIScreen mainScreen].bounds.size.width - 58, 23, 50, 30);
    [_startDownloadBtn setTitle:@"下载" forState:UIControlStateNormal];
    _startDownloadBtn.backgroundColor = [UIColor grayColor];
    [_startDownloadBtn addTarget:self action:@selector(startDownload) forControlEvents:UIControlEventTouchUpInside];
    
    _pauseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _pauseBtn.frame = CGRectMake( [UIScreen mainScreen].bounds.size.width - 58, 23, 50, 30);;
    [_pauseBtn setTitle:@"暂停" forState:UIControlStateNormal];
    _pauseBtn.backgroundColor = [UIColor redColor];
    [_pauseBtn addTarget:self action:@selector(btnPauseDownload) forControlEvents:UIControlEventTouchUpInside];
    
    _installBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _installBtn.frame = CGRectMake( [UIScreen mainScreen].bounds.size.width - 58, 23, 50, 30);
    [_installBtn setTitle:@"安装" forState:UIControlStateNormal];
    _installBtn.backgroundColor = [UIColor colorWithRed:43 / 255.0 green:211 / 255.0 blue:7 / 255.0 alpha:1];
    [_installBtn addTarget:self action:@selector(installHanler) forControlEvents:UIControlEventTouchUpInside];
    
    _startDownloadBtn.layer.cornerRadius= 4;
    _startDownloadBtn.clipsToBounds = YES;
    
    
    _pauseBtn.layer.cornerRadius= 4;
    _pauseBtn.clipsToBounds = YES;
    
    _installBtn.layer.cornerRadius= 4;
    _installBtn.clipsToBounds = YES;
    
    _startDownloadBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    _pauseBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    _installBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [_progressLabel setText:@"0.00%"];

}
- (void)updateCell2:(OneDownloadItem *)oneDownloadItem{
    
    if(oneDownloadItem.totalBytesWritten > 0){

        [_progressLabel setText:[NSString stringWithFormat:@"%.2f%%",((float)oneDownloadItem.currentBytesWritten/(float)oneDownloadItem.totalBytesWritten)*100]];
        _proView.progress = (float)oneDownloadItem.currentBytesWritten/(float)oneDownloadItem.totalBytesWritten;

        }

    [_startDownloadBtn removeFromSuperview];
    [_pauseBtn removeFromSuperview];
    
    if(oneDownloadItem.downloadStatus == DownloadStatusWaiting) //等待中
    {
        //显示暂停按钮
        [self.contentView addSubview:_pauseBtn];
    }
    else if(oneDownloadItem.downloadStatus == DownloadStatusPause)  //暂停中
    {
        //显示下载按钮
        [self.contentView addSubview:_startDownloadBtn];
    }
    else if(oneDownloadItem.downloadStatus == DownloadStatusDownloading)    //下载中
    {
        //显示暂停按钮
        [self.contentView addSubview:_pauseBtn];
    }
    else if (oneDownloadItem.downloadStatus == DownloadStatusComplete)  //下载完成
    {
        //显示下载按钮
        [self.contentView addSubview:_installBtn];
    }
    

}
-(void)updateCell:(OneDownloadItem*)oneDownloadItem
{
    [_img sd_setImageWithURL:[NSURL URLWithString:oneDownloadItem.type] placeholderImage:[UIImage imageNamed:@"placeholderImage"]];
    _myDownloadItem = oneDownloadItem;
    [_gameNameLabel setText:oneDownloadItem.gameName];
    if(oneDownloadItem.totalBytesWritten > 0)
    {

//        oneDownloadItem.totalRead += oneDownloadItem.totalBytesWritten;
//
//        //获取当前时间
//        NSDate *currentDate = [NSDate date];
//
//        //当前时间和上一秒时间做对比，大于等于一秒就去计算
//        if ([currentDate timeIntervalSinceDate:oneDownloadItem.date] >= 1) {
//            //时间差
//            double time = [currentDate timeIntervalSinceDate:oneDownloadItem.date];
//
//            //计算速度
//            long long speed = oneDownloadItem.totalRead/time;
//            //NSLog(@"speed --- %lld",speed);
//            //把速度转成KB或M
//            oneDownloadItem.taskSpeed = [self formatByteCount:speed];
//
//            //维护变量，将计算过的清零
//            oneDownloadItem.totalRead = 0.0;
//
//            //维护变量，记录这次计算的时间
//            oneDownloadItem.date = currentDate;
//
//        }
        
        
        
        self.downTask.totalRead += oneDownloadItem.currentBytesWritten;
        //获取当前时间
        NSDate *currentDate = [NSDate date];
        
        //当前时间和上一秒时间做对比，大于等于一秒就去计算
//        if ([currentDate timeIntervalSinceDate:self.downTask.date] >= 1) {
            //时间差
            double time = [currentDate timeIntervalSinceDate:self.downTask.date];
            
            //计算速度
            long long speed = self.downTask.totalRead/time;
            //NSLog(@" --  speed --- %lld",speed / 1024 / 1024 / 1024);
            //把速度转成KB或M
            self.downTask.speed = [self.downTask formatByteCount:speed];
            
            //维护变量，将计算过的清零
            self.downTask.totalRead = 0.0;
            
            //维护变量，记录这次计算的时间
            
            
//        //NSLog(@"self.downTask.speed   --- %@",self.downTask.speed);
//        }
        self.downTask.date = currentDate;
        [_progressLabel setText:[NSString stringWithFormat:@"%.2f%%",((float)oneDownloadItem.currentBytesWritten/(float)oneDownloadItem.totalBytesWritten)*100]];
        _proView.progress = (float)oneDownloadItem.currentBytesWritten/(float)oneDownloadItem.totalBytesWritten;
    }
    [_startDownloadBtn removeFromSuperview];
    [_pauseBtn removeFromSuperview];
    
    if(oneDownloadItem.downloadStatus == DownloadStatusWaiting) //等待中
    {
        //显示暂停按钮
        [self.contentView addSubview:_pauseBtn];
    }
    else if(oneDownloadItem.downloadStatus == DownloadStatusPause)  //暂停中
    {
        //显示下载按钮
        [self.contentView addSubview:_startDownloadBtn];
    }
    else if(oneDownloadItem.downloadStatus == DownloadStatusDownloading)    //下载中
    {
        //显示暂停按钮
        [self.contentView addSubview:_pauseBtn];
    }
    else if (oneDownloadItem.downloadStatus == DownloadStatusComplete)  //下载完成
    {
        //显示下载按钮
        [self.contentView addSubview:_installBtn];
    }
}

-(void)startDownload
{
    [[DownloadManager manager] startDownload:_myDownloadItem];
}

-(void)btnPauseDownload
{
    [[DownloadManager manager] pauseDownload:_myDownloadItem];
}

-(void)installHanler
{
    [[DownloadManager manager] installIpaWithDownloadItem:_myDownloadItem];
}



- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
