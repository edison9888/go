//
//  GTDoubanLoginViewController.h
//  Chufaba
//
//  Created by 张辛欣 on 13-2-24.
//  Copyright (c) 2013年 ChufabaAPP团队. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTDoubanHeader.h"

@class GTDoubanLoginViewController;

@protocol GTDoubanLoginViewControllerDelegate <NSObject>
@optional
- (void)authorizeWebView:(GTDoubanLoginViewController *)webView didReceiveString:(NSString *)string;
- (void)authorizeWebView:(GTDoubanLoginViewController *)webView cancel:(BOOL)cancel;

@end

@interface GTDoubanLoginViewController : UIViewController <UIWebViewDelegate>
{
    UIWebView *webView;
    UIActivityIndicatorView *indicatorView;
    NSString *requestURL;
}

@property (nonatomic, assign) id<GTDoubanLoginViewControllerDelegate> delegate;

- (id)initWithRequestURL:(NSString *)aURL;

@end
