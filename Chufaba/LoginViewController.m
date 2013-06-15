//
//  LoginViewController.m
//  Chufaba
//
//  Created by kenzo on 13-2-18.
//  Copyright (c) 2013年 ChufabaAPP团队. All rights reserved.
//

#import "LoginViewController.h"
#import "ChufabaAppDelegate.h"
#import <QuartzCore/QuartzCore.h>

@interface LoginViewController ()

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.accountManager = [[SocialAccountManager alloc] init];
    
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 7, 40, 30)];
    [backBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backBtn setImage:[UIImage imageNamed:@"back_click"] forState:UIControlStateHighlighted];
    [backBtn addTarget:self action:@selector(backToPrevious:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = btn;
    
    UIButton *weiboLoginBtn = [[UIButton alloc] initWithFrame:CGRectMake(60,60,200,45)];
    [weiboLoginBtn setImage:[UIImage imageNamed:@"weibologin.png"] forState:UIControlStateNormal];
    
    UIButton *qqLoginBtn = [[UIButton alloc] initWithFrame:CGRectMake(60,160,200,45)];
    [qqLoginBtn setImage:[UIImage imageNamed:@"qqlogin.png"] forState:UIControlStateNormal];
    
    UIButton *doubanLoginBtn = [[UIButton alloc] initWithFrame:CGRectMake(60,260,200,45)];
    [doubanLoginBtn setImage:[UIImage imageNamed:@"doubanlogin.png"] forState:UIControlStateNormal];
    
    [weiboLoginBtn addTarget:self action:@selector(weiboLogin:) forControlEvents:UIControlEventTouchDown];
    [qqLoginBtn addTarget:self action:@selector(qqLogin:) forControlEvents:UIControlEventTouchDown];
    [doubanLoginBtn addTarget:self action:@selector(doubanLogin:) forControlEvents:UIControlEventTouchDown];
    
    [self.view addSubview:weiboLoginBtn];
    [self.view addSubview:qqLoginBtn];
    [self.view addSubview:doubanLoginBtn];
    
    self.navigationItem.title = @"登录";
    self.view.backgroundColor = [UIColor whiteColor];
}

- (IBAction)backToPrevious:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)weiboLogin:(id)sender
{
    [self.accountManager.sinaweibo logIn];
}

- (IBAction)qqLogin:(id)sender
{
    [[self.accountManager getTencentOAuth] authorize:[self.accountManager getPermissions] inSafari:NO];
}

- (IBAction)doubanLogin:(id)sender
{
    [[self.accountManager getGTDouban] logIn];
}

@end
