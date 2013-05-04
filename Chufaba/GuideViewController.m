//
//  GuideViewController.m
//  Chufaba
//
//  Created by 张辛欣 on 13-4-11.
//  Copyright (c) 2013年 ChufabaAPP团队. All rights reserved.
//

#import "GuideViewController.h"

@interface GuideViewController ()

@end

@implementation GuideViewController

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
	
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 7, 40, 30)];
    [backBtn setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backToPrevious:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = btn;
    
    self.view.backgroundColor = [UIColor colorWithRed:244/255.0 green:241/255.0 blue:235/255.0 alpha:1.0];
    self.navigationItem.title = @"新用户指南";
}

- (IBAction)backToPrevious:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
