
//
//  ZXTableViewCell.m
//  GMBoxProject
//
//  Created by 陈雷 on 2018/6/26.
//  Copyright © 2018年 陈雷. All rights reserved.
//

#import "ZXTableViewCell.h"
#import <SDAutoLayout/SDAutoLayout.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface ZXTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *lb1;
@property (weak, nonatomic) IBOutlet UILabel *lb2;
@property (weak, nonatomic) IBOutlet UILabel *lb3;
@property (weak, nonatomic) IBOutlet UIImageView *iconimg;

@end
@implementation ZXTableViewCell
- (void)awakeFromNib{
    [super awakeFromNib];
    self.iconimg.sd_layout.rightSpaceToView(self.contentView, 8).topSpaceToView(self.contentView, 8).widthIs(110).heightIs(90);
    
    self.lb1.sd_layout.leftSpaceToView(self.contentView, 8).topEqualToView(self.iconimg).rightSpaceToView(self.iconimg, 8).autoHeightRatio(0);
    
    self.lb2.sd_layout.leftEqualToView(self.lb1).topSpaceToView(self.lb1, 8).rightEqualToView(self.lb1).autoHeightRatio(0);
    
   self.lb3.sd_layout.leftEqualToView(self.lb2).rightEqualToView(self.lb2).topSpaceToView(self.lb2,8).heightIs(20);
    
    [self setupAutoHeightWithBottomViewsArray:@[self.lb3,self.iconimg] bottomMargin:8];
//    self.lb1.backgroundColor = [UIColor greenColor];
//    self.lb2.backgroundColor = [UIColor blueColor];
//    self.lb3.backgroundColor = [UIColor yellowColor];
}
- (void)setModel:(ZxModel *)model{
    _model = model;

    [self.iconimg sd_setImageWithURL:[NSURL URLWithString:model.dt] placeholderImage:[UIImage imageNamed:@"placeholderImage"]];
    self.lb3.text = [NSString stringWithFormat:@"%@  %@",model.gly,model.time];
    self.lb2.text = model.bt;
    self.lb1.text = model.nr;
    
}
@end
