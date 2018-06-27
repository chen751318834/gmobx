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
@end


@implementation DownloadCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
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
}



-(void)updateCell:(OneDownloadItem*)oneDownloadItem
{
    [_img sd_setImageWithURL:[NSURL URLWithString:oneDownloadItem.type] placeholderImage:[UIImage imageNamed:@"placeholderImage"]];
    _myDownloadItem = oneDownloadItem;
    [_gameNameLabel setText:oneDownloadItem.gameName];
    if(oneDownloadItem.totalBytesWritten > 0)
    {
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
