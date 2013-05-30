//
//  AboutViewController.m
//  Chufaba
//
//  Created by 张辛欣 on 13-4-11.
//  Copyright (c) 2013年 ChufabaAPP团队. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

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
    [backBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backBtn setImage:[UIImage imageNamed:@"back_click"] forState:UIControlStateHighlighted];
    [backBtn addTarget:self action:@selector(backToPrevious:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = btn;
    
    self.view.backgroundColor = [UIColor colorWithRed:244/255.0 green:241/255.0 blue:235/255.0 alpha:1.0];
    self.navigationItem.title = @"关于出发吧";
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(75, 40, 170, 72)];
    imageView.image = [UIImage imageNamed:@"aboutlogo"];
    
    UITextView *aboutView = [[UITextView alloc] initWithFrame:CGRectMake(10, 140, 300, self.view.bounds.size.height-200)];
    aboutView.editable = FALSE;
    aboutView.backgroundColor = [UIColor clearColor];
    aboutView.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:14];
    aboutView.textColor = [UIColor colorWithRed:77/255.0 green:73/255.0 blue:69/255.0 alpha:1.0];
    aboutView.text = @"出发吧，是同样喜欢旅行的我们为你精心打造的一款自助游计划工具，希望它能帮你解决旅行期间的诸多不便，让你轻松享受旅行。\n\n有些景，如果不站在高处，你永远不知道它有多美丽；\n\n有些路，如果不启程，你永远不知道它有多激动人心；\n\n出发吧，去看看这个世界！";
    
    [self.view addSubview:imageView];
    [self.view addSubview:aboutView];
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
