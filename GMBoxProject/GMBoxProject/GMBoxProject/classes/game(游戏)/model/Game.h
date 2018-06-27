//
//  Game.h
//  GMBoxProject
//
//  Created by 陈雷 on 2018/6/26.
//  Copyright © 2018年 陈雷. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameTop : NSObject
@property(copy,nonatomic) NSString * game_id;
@property(copy,nonatomic) NSString * game_logo;


@end

@interface Game : NSObject
@property(copy,nonatomic) NSString * name;
@property(copy,nonatomic) NSString * game_id;
@property(copy,nonatomic) NSString * game_icon;
@property(copy,nonatomic) NSString * introduce;
@property(copy,nonatomic) NSString * down_url;
@property(copy,nonatomic) NSString * down_plist;
@property(copy,nonatomic) NSString * local_plist;

@end
