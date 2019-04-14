//
//  ViewController.m
//  sandboxApp
//
//  Created by Taylor Thompson on 14/04/2019.
//  Copyright © 2019 Taylor Thompson. All rights reserved.
//

#import "ViewController.h"
@import Foundation;
@import WebKit;

#pragma mark - private interface
@interface ViewController () <WKScriptMessageHandler, WKNavigationDelegate>
@property(strong, nonatomic) WKWebView *webView;
@property (nonatomic, strong) WKWebViewConfiguration *webConfig;
@end

#if DEBUG
  NSString * const WEB_URL = @"http://<IPADDRESS_HERE>:8080/";
#else
  NSString * const WEB_URL = @"https://myprodsite.io";
#endif
@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  // Create WKWebView instance and load page at WEB_URL
  NSURL *url = [NSURL URLWithString:WEB_URL];
  NSURLRequest *request = [NSURLRequest requestWithURL:url];
  _webView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:self.webConfig];
  // We are our own nav delegate
  _webView.navigationDelegate = self;

  [_webView loadRequest:request];

  // Set the active view as the web view
  [self.view addSubview:self.webView];
}

- (void)viewDidAppear:(BOOL)animated {
  // [super viewDidAppear:animated];
  // Load HTML when view appears maybe ship in with prod bundle?
  // [self loadHtml];
}

-(void)loadHtml {
  // Grab our index.html file in the bunlde containing this private class
  NSString *htmlPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"index" ofType:@"html"];
  if (htmlPath) {
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:htmlPath]]];
  } else {
    [self showAlertWithMessage:@"Could not load index.html"];
  }
}

#pragma mark - WKNavigationDelegate
-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
  NSLog(@"%s",__func__);
}

-(void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
  NSLog(@"%s. Navigation Error %@", __func__,error);
}

#pragma mark - accessors
-(WKWebViewConfiguration*) webConfig {
  // if config doesn't exist, create one
  if (!_webConfig) {
    _webConfig = [[WKWebViewConfiguration alloc] init];

    // We need a content controller for injecting user scripts
    WKUserContentController* userController = [self CreateWebScriptHandler];
    _webConfig.userContentController = userController;

  }
  return _webConfig;
}

#pragma mark - helpers
-(WKUserContentController*)CreateWebScriptHandler
{
  WKUserContentController* ContentController = [[WKUserContentController alloc] init];
  // Create message handler for events -- names are arbitrary
  [ContentController addScriptMessageHandler:self name:@"action"];

  return ContentController;
}

-(void)showAlertWithMessage:(NSString*)message {
  UIAlertAction* action = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel
                                                 handler:^(UIAlertAction *action) {
                                                   [self dismissViewControllerAnimated:YES completion:nil];
                                                 }];
  UIAlertController* alertVC = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
  [alertVC addAction:action];
  [self presentViewController:alertVC animated:YES completion:^{

                                                 }];
                                                 }
@end

