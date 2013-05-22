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

#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSInteger scrollYPosition = 35;
    NSInteger pageYposition = 385;
	
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 7, 40, 30)];
    [backBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backBtn setImage:[UIImage imageNamed:@"back_click"] forState:UIControlStateHighlighted];
    [backBtn addTarget:self action:@selector(backToPrevious:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = btn;
    
    self.view.backgroundColor = [UIColor colorWithRed:244/255.0 green:241/255.0 blue:235/255.0 alpha:1.0];
    self.navigationItem.title = @"新用户指南";
    
    NSMutableArray *picArray = [[NSMutableArray alloc] init];
    [picArray addObject:[UIImage imageNamed:@"Guide1"]];
    [picArray addObject:[UIImage imageNamed:@"Guide2"]];
    [picArray addObject:[UIImage imageNamed:@"Guide3"]];
    [picArray addObject:[UIImage imageNamed:@"Guide4"]];
    [picArray addObject:[UIImage imageNamed:@"Guide5"]];
    
    if(IS_IPHONE_5)
    {
        scrollYPosition = 80;
        pageYposition = 430;
    }
    
    self.scrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, scrollYPosition, 320, 320)];
    self.scrollview.contentSize = CGSizeMake(1600, 320);
    self.scrollview.showsVerticalScrollIndicator = NO;
    self.scrollview.showsHorizontalScrollIndicator = NO;
    self.scrollview.delegate = self;
    self.scrollview.scrollEnabled = YES;
    self.scrollview.pagingEnabled = YES; 
    self.scrollview.bounces = NO;
    
    for (int i = 0; i < 5; i++)
    {
		CGFloat xOrigin = i * 320;
		UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(xOrigin,0,320,320)];
		[imageView setImage:[picArray objectAtIndex:i]];
		[self.scrollview addSubview:imageView];
	}
    
    self.pageControl = [[PageControl alloc] initWithFrame:CGRectMake(120, pageYposition, 80, 10)];
    self.pageControl.numberOfPages = 5;
    self.pageControl.currentPage = 0;
    self.pageControl.delegate = self;
    
    [self.view addSubview:self.scrollview];
    [self.view addSubview:self.pageControl];
}

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    int page = self.scrollview.contentOffset.x/310;
    self.pageControl.currentPage = page;
}

- (IBAction)changePage:(id)sender
{
    int page = self.pageControl.currentPage;
    [self.scrollview setContentOffset:CGPointMake(320*page, 0)];
}

- (void)pageControlPageDidChange:(PageControl *)pageControl
{
    CGRect visibleRect = CGRectMake(self.pageControl.currentPage * 320, 0, 320, 320);
    [self.scrollview scrollRectToVisible:visibleRect animated:YES];
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
