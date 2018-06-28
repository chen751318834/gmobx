
//
//  ZXDetailViewController.m
//  GMBoxProject
//
//  Created by 陈雷 on 2018/6/26.
//  Copyright © 2018年 陈雷. All rights reserved.
//

#import "ZXDetailViewController.h"

@interface ZXDetailViewController ()
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (weak, nonatomic) IBOutlet UIWebView *webview;

@end

@implementation ZXDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([[UIDevice currentDevice].systemVersion floatValue] < 11.0) {
        self.webview.scrollView.contentInset = UIEdgeInsetsMake(-64, 0, 0, 0);
    }
    NSString * url = [NSString stringWithFormat:@"http://fggood.com:8000/new/new.php?id=%@",self.ID];
    [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    [self.activityIndicatorView startAnimating];
    self.webview.userInteractionEnabled = NO;

}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [self.activityIndicatorView stopAnimating];
    self.webview.userInteractionEnabled = YES;

}
@end
