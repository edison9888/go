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
    aboutView.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:16];
    aboutView.textColor = [UIColor colorWithRed:77/255.0 green:73/255.0 blue:69/255.0 alpha:1.0];
    aboutView.text = @"“出发吧”是为热爱自助游的朋友们打造的一款自助游计划工具。\n热爱自助游的朋友或多或少都有过这样的经历：\n在各个网站上收集景点信息，再东拼西凑到一块，最后打印成十几页的行程单，旅途中查阅既不方便又容易丢失；\n旅行时，即使知道目的地在哪，也还是要不停问路，因为当地地图要看明白实在不容易；\n有本攻略写的确实不错，但当拿着半斤重的它站在十字路口翻看时，这本身就是一种负担。";
    
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
