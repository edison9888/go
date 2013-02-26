//
//  GTDoubanLoginViewController.m
//  Chufaba
//
//  Created by 张辛欣 on 13-2-24.
//  Copyright (c) 2013年 ChufabaAPP团队. All rights reserved.
//

#import "GTDoubanLoginViewController.h"

@interface GTDoubanLoginViewController ()

@end

@implementation GTDoubanLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithRequestURL:(NSString *)aURL {
    self = [super init];
    if (self) {
        requestURL = aURL;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"豆瓣登录";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonItemStyleBordered target:self action:@selector(cancelDouban:)];
	
    webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, 435)];
    [webView setDelegate:self];
    
    [self loadRequestWithURL:[NSURL URLWithString:requestURL]];
    [self.view addSubview:webView];
    
    indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [indicatorView setCenter:CGPointMake(160, 215)];
    [self.view addSubview:indicatorView];
}

- (void)cancelDouban:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark Public Methods
- (void)loadRequestWithURL:(NSURL *)url {
    NSURLRequest *request =[NSURLRequest requestWithURL:url
                                            cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                        timeoutInterval:60.0];
    [webView loadRequest:request];
}

#pragma mark UIWebViewDelegate Methods
- (void)webViewDidStartLoad:(UIWebView *)aWebView {
	[indicatorView startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)aWebView {
	[indicatorView stopAnimating];
}

- (void)webView:(UIWebView *)aWebView didFailLoadWithError:(NSError *)error {
    [indicatorView stopAnimating];
}

- (BOOL)webView:(UIWebView *)aWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    //    NSString *urlStrig = request.URL.absoluteString;
    //    NSLog(@"urlStrig:%@", urlStrig);
    NSURL *urlObj =  [request URL];
    NSString *url = [urlObj absoluteString];
    if ([url hasPrefix:kGTRedirectURI]) {
        NSString* urlStrig = [urlObj query];
        NSLog(@"urlStrig:%@", urlStrig);
        NSRange range = [urlStrig rangeOfString:@"code="];
        if (range.location != NSNotFound) {
            NSString *code = [urlStrig substringFromIndex:range.location + range.length];
            NSLog(@"code:%@", code);
            if ([self.delegate respondsToSelector:@selector(authorizeWebView:didReceiveString:)]) {
                [self.delegate authorizeWebView:self didReceiveString:code];
            }
        }
        return NO;
    }
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
