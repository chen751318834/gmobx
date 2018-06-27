
//
//  KefuViewController.m
//  GMBoxProject
//
//  Created by 陈雷 on 2018/6/26.
//  Copyright © 2018年 陈雷. All rights reserved.
//

#import "KefuViewController.h"
#import "NSString+GM.h"

@interface KefuViewController () <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (weak, nonatomic) IBOutlet UIWebView *webview;
@end
@implementation KefuViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    if ([[UIDevice currentDevice].systemVersion floatValue] < 11.0) {
        self.webview.scrollView.contentInset = UIEdgeInsetsMake(-64, 0, 0, 0);
    }
}
- (void)viewWillAppear:(BOOL)animated{
    [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://yun.wuyousy.com/service?user=%@",[NSString qu_user]]]]];
    
}
- (void)webViewDidStartLoad:(UIWebView *)webView{
    [self.activityIndicatorView startAnimating];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [self.activityIndicatorView stopAnimating];
    
}
@end
