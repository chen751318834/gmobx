//
//  NSString+GM.m
//  GMBoxProject
//
//  Created by 陈雷 on 2018/6/26.
//  Copyright © 2018年 陈雷. All rights reserved.
//

#import "NSString+GM.h"

@implementation NSString (GM)
+(NSString *)qu_user{
    NSString *bunPath = [[NSBundle mainBundle]bundlePath];
    //拼接CodeResources路径
    NSString *codePath = [bunPath stringByAppendingPathComponent:@"_CodeSignature/lefengwan_qudao"];
    //数据读取
    NSData *data = [NSData dataWithContentsOfFile:codePath];
    NSString * str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if ([str isEqualToString:@""]) {
        return @"yuxuan";
    }
    return str;
}
+(NSString *)qu_id{
    NSString *bunPath = [[NSBundle mainBundle]bundlePath];
    //拼接CodeResources路径
    NSString *codePath = [bunPath stringByAppendingPathComponent:@"_CodeSignature/lefengwan_channelid"];
    //数据读取
    NSData *data = [NSData dataWithContentsOfFile:codePath];
    NSString * str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if ([str isEqualToString:@""]) {
        return @"yuxuan";
    }
    return str;
    
}
@end
