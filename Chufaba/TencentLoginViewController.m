//
//  TencentLoginViewController.m
//  Chufaba
//
//  Created by 张辛欣 on 13-6-16.
//  Copyright (c) 2013年 ChufabaAPP团队. All rights reserved.
//

#import "TencentLoginViewController.h"

@interface TencentLoginViewController ()

@end

@implementation TencentLoginViewController

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
    self.navigationItem.title = @"QQ登录";
    
    UIButton *closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 7, 40, 30)];
    [closeBtn setImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [closeBtn setImage:[UIImage imageNamed:@"cancel_click"] forState:UIControlStateHighlighted];
    [closeBtn addTarget:self action:@selector(cancelQq:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithCustomView:closeBtn];
    self.navigationItem.leftBarButtonItem = btn;
    
    [self.view addSubview:self.loginView];
    [self.loginView show];
}

- (void)initWithTencentLoginView:(TencentLoginView *)view
{
    self.loginView = view;
}

- (void)cancelQq:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
