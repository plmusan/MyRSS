//
//  RSSDetailController.m
//  MyRSS
//
//  Created by x.wang on 2018/11/6.
//  Copyright © 2018 x.wang. All rights reserved.
//

#import "RSSDetailController.h"
#import <WebKit/WebKit.h>
#import <SafariServices/SafariServices.h>
#import "RSSModel.h"

@interface RSSDetailController () <WKUIDelegate, WKNavigationDelegate>

@property (nonatomic, strong) WKWebView *webView;

@end

@implementation RSSDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = _item.title;
    
    NSString *html = [NSString stringWithFormat:@"<!DOCTYPE html><html><head><title>%@</title><meta http-equiv=Content-Type content=\"text/html; charset=utf-8\"><style>body{font-size:20px;}</style></head><body>%@</body></html>", _item.title, _item.descriptionStr];
    
    _webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
    _webView.UIDelegate = self;
    _webView.navigationDelegate = self;
    [self.view addSubview:_webView];
    [_webView loadHTMLString:html baseURL:nil];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"Safari"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(loadDetailData)];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSString *scheme = [NSString stringWithFormat:@"%@",navigationAction.request.URL.scheme];
    if ([scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"]) {
        SFSafariViewController *sf = [[SFSafariViewController alloc] initWithURL:navigationAction.request.URL];
        [self presentViewController:sf animated:YES completion:nil];
        decisionHandler(WKNavigationActionPolicyCancel);
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
    
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    //修改字体大小 300%
    [ webView evaluateJavaScript:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '200%'"completionHandler:nil];
    
}

- (void)loadDetailData {
    NSURL *url = [NSURL URLWithString:_item.link];
    SFSafariViewController *sf = [[SFSafariViewController alloc] initWithURL:url];
    [self presentViewController:sf animated:YES completion:nil];
}

@end
