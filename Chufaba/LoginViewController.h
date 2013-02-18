//
//  LoginViewController.h
//  Chufaba
//
//  Created by kenzo on 13-2-18.
//  Copyright (c) 2013年 ChufabaAPP团队. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SocialAccountManager.h"

@interface LoginViewController : UIViewController
{
    NSDictionary *userInfo;
}

@property (strong, nonatomic) SocialAccountManager *accountManager;

- (IBAction)weiboLogin:(id)sender;
- (IBAction)qqLogin:(id)sender;
- (IBAction)login:(id)sender;

@end
