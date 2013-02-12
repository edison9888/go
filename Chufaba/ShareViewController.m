//
//  ShareViewController.m
//  Chufaba
//
//  Created by 张 辛欣 on 13-2-11.
//  Copyright (c) 2013年 ChufabaAPP团队. All rights reserved.
//

#import "ShareViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface ShareViewController ()

@end

@implementation ShareViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization 
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelTapped:)];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneTapped:)];
        self.view.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(10.0, 10.0, 300.0, 160.0)];
    
    self.textView.textColor = [UIColor blackColor];
    
    self.textView.font = [UIFont fontWithName:@"Arial" size:18.0];
    
    self.textView.delegate = self;
    
    self.textView.backgroundColor = [UIColor whiteColor];//设置它的背景颜色
    
    self.textView.layer.borderWidth = 2.0f;
    self.textView.layer.borderColor = [[UIColor grayColor] CGColor];
    
    [self.textView.layer setCornerRadius:10];
    
    self.textView.text = @"英伦自由行 7天35个地点，供各位参考";
    
    self.textView.returnKeyType = UIReturnKeyDefault;
    
    self.textView.keyboardType = UIKeyboardTypeDefault;
    
    self.textView.scrollEnabled = YES;
    
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleHeight;//自适应高度    
    
    [self.view addSubview: self.textView];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 140.0, 300.0, 40.0)];
    label.text = @"分享至：";
    [self.view addSubview:label];
    
    //chooseService = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 200.0, 300.0, 60.0)];
    
    self.weiboBtn = [[UIButton alloc] initWithFrame:(CGRectMake(10.0, 200.0, 80.0, 40.0))];
    [self.weiboBtn setTitle:@"新浪微博" forState:UIControlStateNormal];
    [self.weiboBtn setTitleColor:[UIColor colorWithRed:36/255.0 green:71/255.0 blue:113/255.0 alpha:1.0] forState:UIControlStateNormal];
    self.weiboBtn.backgroundColor = [UIColor clearColor];
    [[self.weiboBtn layer] setBorderWidth:1.0f];
    [[self.weiboBtn layer] setBorderColor:[UIColor grayColor].CGColor];
    [self.weiboBtn addTarget:self action:@selector(weiboOauth:) forControlEvents:UIControlEventTouchDown];
    
    [self.view addSubview:self.weiboBtn];
    //[chooseService addSubview:btn];
    //[self.view addSubview:chooseService];
}

-(IBAction) weiboOauth:(id) sender
{
    [self.delegate ShareViewController:self doWeiboOauth:@"placeholder"];
}

-(IBAction) cancelTapped:(id) sender
{
    [self.delegate ShareViewController:self didCancelShare:@"cancel tapped"];
}

-(IBAction) doneTapped:(id) sender
{
    [self.delegate ShareViewController:self didConfirmShare:@"done tapped"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
