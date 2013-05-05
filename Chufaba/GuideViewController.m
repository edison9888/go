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
    [backBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backBtn setImage:[UIImage imageNamed:@"back_click"] forState:UIControlStateHighlighted];
    [backBtn addTarget:self action:@selector(backToPrevious:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = btn;
    
    self.view.backgroundColor = [UIColor colorWithRed:244/255.0 green:241/255.0 blue:235/255.0 alpha:1.0];
    self.navigationItem.title = @"新用户指南";
    
    UITextView *aboutView = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, 300, self.view.bounds.size.height-65)];
    aboutView.editable = FALSE;
    aboutView.backgroundColor = [UIColor clearColor];
    aboutView.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:16];
    aboutView.textColor = [UIColor colorWithRed:77/255.0 green:73/255.0 blue:69/255.0 alpha:1.0];
    aboutView.text = @" 1. 首页，左滑可编辑或删除旅行计划。\n\n 2. 行程页，左滑可删除旅行地点。\n\n 3. 行程页，长按地点可以调整次序。\n\n 4. 地点详情页，点小地图可查看大地图进行导航。\n\n 5. 添加旅行地点页，出发吧未能提供的地点，您可以自行创建，设定坐标。";
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:[aboutView bounds]];
    imageView.image = [[UIImage imageNamed:@"kuang"] stretchableImageWithLeftCapWidth:8 topCapHeight:8];
    [aboutView addSubview:imageView];
    [aboutView sendSubviewToBack:imageView];
    
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
