//
//  ShareViewController.m
//  Chufaba
//
//  Created by 张 辛欣 on 13-2-11.
//  Copyright (c) 2013年 ChufabaAPP团队. All rights reserved.
//

#import "ShareViewController.h"
#import "ChufabaAppDelegate.h"
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
    
    //set the state of all the social service
    
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
    
    [self.weiboBtn setTitleColor:[UIColor colorWithRed:36/255.0 green:71/255.0 blue:113/255.0 alpha:1.0] forState:UIControlStateNormal];
    self.weiboBtn.backgroundColor = [UIColor clearColor];
    [[self.weiboBtn layer] setBorderWidth:1.0f];
    [[self.weiboBtn layer] setBorderColor:[UIColor grayColor].CGColor];
    [self.weiboBtn addTarget:self action:@selector(weiboOauth:) forControlEvents:UIControlEventTouchDown];
    
    self.confirmBtnBackup = self.navigationItem.rightBarButtonItem;
    
    [self.view addSubview:self.weiboBtn];
}

-(void) viewDidAppear:(BOOL)animated
{
    if([self.accountManager.sinaweibo isAuthValid])
    {
        [self.weiboBtn setTitle:@"微博已选" forState:UIControlStateNormal];
        sinaEnabled = YES;
        if(!self.navigationItem.rightBarButtonItem)
        {
            self.navigationItem.rightBarButtonItem = self.confirmBtnBackup;
        }
    }
    else
    {
        [self.weiboBtn setTitle:@"微博未选" forState:UIControlStateNormal];
        sinaEnabled = NO;
        self.navigationItem.rightBarButtonItem = nil;
    }
}

-(IBAction) weiboOauth:(id) sender
{
    //[self.delegate ShareViewController:self doWeiboOauth:self.textView.text];
    if([self.accountManager.sinaweibo isAuthValid])
    {
        sinaEnabled = !sinaEnabled;
        if(sinaEnabled)
        {
            [self.weiboBtn setTitle:@"微博已选" forState:UIControlStateNormal];
            self.navigationItem.rightBarButtonItem = self.confirmBtnBackup;
        }
        else
        {
            [self.weiboBtn setTitle:@"微博未选" forState:UIControlStateNormal];
            self.navigationItem.rightBarButtonItem = nil;
        }
    }
    else
    {
        [self.accountManager.sinaweibo logIn];
    }
}

-(IBAction) cancelTapped:(id) sender
{
    [self dismissViewControllerAnimated:YES completion: nil];
}

-(IBAction) doneTapped:(id) sender
{
    [self.accountManager.sinaweibo requestWithURL:@"statuses/update.json"
                       params:[NSMutableDictionary dictionaryWithObjectsAndKeys:self.textView.text, @"status", nil]
                   httpMethod:@"POST"
                     delegate:self.accountManager];
    
    [self dismissViewControllerAnimated:YES completion: nil];
}

-(void) socialAccountManager:(SocialAccountManager *) manager updateShareView:(BOOL) hasLogin
{
    [self.weiboBtn setTitle:@"微博已选" forState:UIControlStateNormal];
    sinaEnabled = YES;
    if(!self.navigationItem.rightBarButtonItem)
    {
        self.navigationItem.rightBarButtonItem = self.confirmBtnBackup;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
