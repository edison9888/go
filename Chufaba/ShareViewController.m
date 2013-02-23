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
    
    //set the state of all the social service
    self.accountManager = [[SocialAccountManager alloc] init];
    
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
    
    self.weiboBtn = [[UIButton alloc] initWithFrame:(CGRectMake(10.0, 200.0, 32.0, 32.0))];
    //[self.weiboBtn setImage:[UIImage imageNamed:@"wlogo.png"] forState:UIControlStateNormal];
    
    self.tWeiboBtn = [[UIButton alloc] initWithFrame:(CGRectMake(80.0, 200.0, 32.0, 32.0))];
    //[self.tWeiboBtn setImage:[UIImage imageNamed:@"tlogo.png"] forState:UIControlStateNormal];
    
    [self.weiboBtn addTarget:self action:@selector(weiboOauth:) forControlEvents:UIControlEventTouchDown];
    [self.tWeiboBtn addTarget:self action:@selector(tWeiboOauth:) forControlEvents:UIControlEventTouchDown];
    
    self.confirmBtnBackup = self.navigationItem.rightBarButtonItem;
    
    if([self.accountManager.sinaweibo isAuthValid])
    {
        [self.weiboBtn setImage:[UIImage imageNamed:@"wlogo.png"] forState:UIControlStateNormal];
        sinaEnabled = YES;
    }
    else
    {
        [self.weiboBtn setImage:[UIImage imageNamed:@"wlogogray.jpg"] forState:UIControlStateNormal];
        sinaEnabled = NO;
    }
    if([[self.accountManager getTencentOAuth] isSessionValid])
    {
        [self.tWeiboBtn setImage:[UIImage imageNamed:@"tlogo.png"] forState:UIControlStateNormal];
        tencentEnabled = YES;
    }
    else
    {
        [self.tWeiboBtn setImage:[UIImage imageNamed:@"tlogogray.jpg"] forState:UIControlStateNormal];
        tencentEnabled = NO;
    }
    shareBtnEnabled = sinaEnabled | tencentEnabled;
    
    [self.view addSubview:self.weiboBtn];
    [self.view addSubview:self.tWeiboBtn];
}

-(void) viewDidAppear:(BOOL)animated
{

}

-(IBAction) weiboOauth:(id) sender
{
    if([self.accountManager.sinaweibo isAuthValid])
    {
        sinaEnabled = !sinaEnabled;
        if(sinaEnabled)
        {
            [self.weiboBtn setImage:[UIImage imageNamed:@"wlogo.png"] forState:UIControlStateNormal];
        }
        else
        {
            [self.weiboBtn setImage:[UIImage imageNamed:@"wlogogray.jpg"] forState:UIControlStateNormal];
        }
    }
    else
    {
        [self.accountManager.sinaweibo logIn];
    }
    shareBtnEnabled = sinaEnabled | tencentEnabled;
    if(shareBtnEnabled)
    {
        self.navigationItem.rightBarButtonItem = self.confirmBtnBackup;
    }
    else
    {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

-(IBAction) tWeiboOauth:(id) sender
{
    if([[self.accountManager getTencentOAuth] isSessionValid])
    {
        tencentEnabled = !tencentEnabled;
        if(tencentEnabled)
        {
            [self.tWeiboBtn setImage:[UIImage imageNamed:@"tlogo.png"] forState:UIControlStateNormal];
        }
        else
        {
            [self.tWeiboBtn setImage:[UIImage imageNamed:@"tlogogray.jpg"] forState:UIControlStateNormal];
        }
    }
    else
    {
        [[self.accountManager getTencentOAuth] authorize:[self.accountManager getPermissions] inSafari:NO];
    }
    shareBtnEnabled = sinaEnabled | tencentEnabled;
    if(shareBtnEnabled)
    {
        self.navigationItem.rightBarButtonItem = self.confirmBtnBackup;
    }
    else
    {
        self.navigationItem.rightBarButtonItem = nil;
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

-(void) socialAccountManager:(SocialAccountManager *) manager updateShareView:(NSInteger) loginType
{
    if(loginType == 1)
    {
        sinaEnabled = YES;
        [self.weiboBtn setImage:[UIImage imageNamed:@"wlogo.png"] forState:UIControlStateNormal];
    }
    else if(loginType == 2)
    {
        tencentEnabled = YES;
        [self.tWeiboBtn setImage:[UIImage imageNamed:@"tlogo.png"] forState:UIControlStateNormal];
    }
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
