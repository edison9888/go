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
    [backBtn setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backToPrevious:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = btn;
    
    self.view.backgroundColor = [UIColor colorWithRed:244/255.0 green:241/255.0 blue:235/255.0 alpha:1.0];
    self.navigationItem.title = @"关于出发吧";
    
    UITextView *aboutView = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, 300, self.view.bounds.size.height-65)];
//    UIColor *background = [[UIColor alloc] initWithPatternImage:[[UIImage imageNamed:@"kuang"] stretchableImageWithLeftCapWidth:8 topCapHeight:8]];
//    aboutView.backgroundColor = background;
    
    aboutView.editable = FALSE;
    aboutView.backgroundColor = [UIColor whiteColor];
    aboutView.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:16];
    aboutView.textColor = [UIColor colorWithRed:77/255.0 green:73/255.0 blue:69/255.0 alpha:1.0];
    aboutView.text = @"出发吧团队荣誉出品";
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
