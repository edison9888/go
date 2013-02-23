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

@property (strong, nonatomic) SocialAccountManager *accountManager;

//@property (weak, nonatomic) IBOutlet UIButton *weiboLoginBtn;
//@property (weak, nonatomic) IBOutlet UIButton *qqLoginBtn;
//@property (weak, nonatomic) IBOutlet UIButton *doubanLoginBtn;

//- (IBAction)weiboLogin:(id)sender;
//- (IBAction)qqLogin:(id)sender;
//- (IBAction)doubanLogin:(id)sender;

@end
