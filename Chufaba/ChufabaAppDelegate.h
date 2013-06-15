//
//  itineraryAppDelegate.h
//  出发吧
//
//  Created by kenzo on 13-1-16.
//  Copyright (c) 2013年 出发吧APP团队. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXApi.h"

#import "LoginViewController.h"

#define kAppKey             @"3237810134"
#define kAppSecret          @"4567ec20cedfb0a482c287a0e66f5590"
#define kAppRedirectURI     @"http://chufaba.me"

@class SinaWeibo;
@class LoginViewController;

@interface ChufabaAppDelegate : UIResponder <UIApplicationDelegate, WXApiDelegate>
//@interface ChufabaAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) SinaWeibo *sinaweibo;

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) LoginViewController *loginViewController;

@property (nonatomic, strong) NSString *databaseName;
@property (nonatomic, strong) NSString *databasePath;

- (void) createAndCheckDatabase;

@end
