//
//  GameDetailHeaderView.m
//  GMBoxProject
//
//  Created by 陈雷 on 2018/6/26.
//  Copyright © 2018年 陈雷. All rights reserved.
//

#import "GameDetailHeaderView.h"
#import <SDWebImage/UIImageView+WebCache.h>


@interface GameDetailHeaderView ()<UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;
@property (weak, nonatomic) IBOutlet UIImageView *iconimg;
@property (weak, nonatomic) IBOutlet UIImageView *bgimg;
@property (weak, nonatomic) IBOutlet UILabel *namelb;
@property (weak, nonatomic) IBOutlet UILabel *subnamelb;

@end
@implementation GameDetailHeaderView
- (void)awakeFromNib{
    [super awakeFromNib];
    self.iconimg.layer.borderColor = [UIColor whiteColor].CGColor;
    self.iconimg.layer.borderWidth = 1;
    self.iconimg.clipsToBounds = YES;
}
+ (instancetype)headerView{
    return [[NSBundle mainBundle] loadNibNamed:@"GameDetailHeaderView" owner:nil options:nil].firstObject;
    
}
- (void)setGameDetail:(GameDetail *)gameDetail{
    _gameDetail = gameDetail;
    [self.iconimg sd_setImageWithURL:[NSURL URLWithString:gameDetail.game_icon] placeholderImage:[UIImage imageNamed:@"placeholderImage"]];
    [self.bgimg sd_setImageWithURL:[NSURL URLWithString:gameDetail.game_icon] placeholderImage:[UIImage imageNamed:@"placeholderImage"]];
    self.namelb.text = gameDetail.name;
    self.subnamelb.text = gameDetail.introduce;
    CGFloat w =  [UIScreen mainScreen].bounds.size.width / 3 + 30;
    
    [gameDetail.tu enumerateObjectsUsingBlock:^(GameDetailImage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIView * v = [[UIView alloc] initWithFrame:CGRectMake(w * idx, 0, w, 247)];
        v.backgroundColor = [UIColor whiteColor];
        UIImageView * img = [[UIImageView alloc] initWithFrame:CGRectMake(2.5, 2.5, w - 5, 247 - 5)];
        img.clipsToBounds = YES;
        img.userInteractionEnabled = YES;
        img.layer.cornerRadius = 4;
//        img.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:1].CGColor;
//        img.layer.borderWidth = 5;
        img.contentMode = UIViewContentModeScaleAspectFill;
        img.tag = idx;
        [img addGestureRecognizer:  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickedImg:)]];
        [img sd_setImageWithURL:[NSURL URLWithString:obj.jietu] placeholderImage:[UIImage imageNamed:@"placeholderImage"]];
        [v addSubview:img];
        [self.scrollview addSubview:v ];
    }];
    self.scrollview.contentSize = CGSizeMake(w * gameDetail.tu.count, 0);
}
- (void)didClickedImg:(UITapGestureRecognizer *)tap{
    
    if ([self.delegate respondsToSelector:@selector(didClickImageViewWithIndex:img:)]) {
        [self.delegate didClickImageViewWithIndex:tap.view.tag img:tap.view];
    }
    
}
@end
