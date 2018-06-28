//
//  DownloadCell.h
//  DemoDownload
//
//  Created by yingxin ye on 2017/5/3.
//  Copyright © 2017年 yingxin ye. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OneDownloadItem.h"


@interface DownTask : NSObject
//totalRead（一秒读取的数据）、speed（速度）、date（记录上一秒计算之后的时间）。注意：这里的一秒不是严格意义上的一秒，有可能大于一秒，我们计算的是平均速度，所以不会误差太大。

@property(nonatomic,assign) float totalRead;
@property(nonatomic,copy) NSString * speed;
@property(nonatomic,strong) NSDate * date;
- (NSString*)formatByteCount:(long long)size;

@end
@interface DownloadCell : UITableViewCell


-(void)updateCell:(OneDownloadItem*)oneDownloadItem;
-(void)updateCell2:(OneDownloadItem*)oneDownloadItem;



@end
