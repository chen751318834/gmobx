//
//  GameDetail.h
//  GMBoxProject
//
//  Created by 陈雷 on 2018/6/26.
//  Copyright © 2018年 陈雷. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameDetailImage : NSObject

@property(copy,nonatomic) NSString * jietu;

@end

@interface GameDetail : NSObject


@property(copy,nonatomic) NSString * name;
@property(copy,nonatomic) NSString * game_id;
@property(copy,nonatomic) NSString * game_icon;
@property(copy,nonatomic) NSString * introduce;
@property(copy,nonatomic) NSString * details;
@property(copy,nonatomic) NSString * down_url;
@property(copy,nonatomic) NSString * down_plist;
@property(copy,nonatomic) NSString * local_plist;
@property(strong,nonatomic) NSArray<GameDetailImage *> * tu;

@end
