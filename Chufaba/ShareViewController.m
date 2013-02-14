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
    //[chooseService addSubview:btn];
    //[self.view addSubview:chooseService];
}

-(void) viewDidAppear:(BOOL)animated
{
    SinaWeibo *sinaweibo = [self sinaweibo];
    if([sinaweibo isAuthValid])
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
    SinaWeibo *sinaweibo = [self sinaweibo];
    if([sinaweibo isAuthValid])
    {
        //self.sinaEnabled = [NSNumber numberWithBool:![self.sinaEnabled boolValue]];
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
        [sinaweibo logIn];
    }
}

-(IBAction) cancelTapped:(id) sender
{
    //[self.delegate ShareViewController:self didCancelShare:@"cancel tapped"];
    [self dismissViewControllerAnimated:YES completion: nil];
}

-(IBAction) doneTapped:(id) sender
{
    //[self.delegate ShareViewController:self didConfirmShare:self.textView.text];
    SinaWeibo *sinaweibo = [self sinaweibo];
    [sinaweibo requestWithURL:@"statuses/update.json"
                       params:[NSMutableDictionary dictionaryWithObjectsAndKeys:self.textView.text, @"status", nil]
                   httpMethod:@"POST"
                     delegate:self];
    
    [self dismissViewControllerAnimated:YES completion: nil];
}

//sina weibo part
- (SinaWeibo *)sinaweibo
{
    ChufabaAppDelegate *delegate = (ChufabaAppDelegate *)[UIApplication sharedApplication].delegate;
    //set itineraryviewcontroller as the delegate of sinaweibo
    delegate.sinaweibo.delegate = self;
    return delegate.sinaweibo;
}

- (void)removeAuthData
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"SinaWeiboAuthData"];
}

- (void)storeAuthData
{
    SinaWeibo *sinaweibo = [self sinaweibo];
    
    NSDictionary *authData = [NSDictionary dictionaryWithObjectsAndKeys:
                              sinaweibo.accessToken, @"AccessTokenKey",
                              sinaweibo.expirationDate, @"ExpirationDateKey",
                              sinaweibo.userID, @"UserIDKey",
                              sinaweibo.refreshToken, @"refresh_token", nil];
    [[NSUserDefaults standardUserDefaults] setObject:authData forKey:@"SinaWeiboAuthData"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - SinaWeibo Delegate

- (void)sinaweiboDidLogIn:(SinaWeibo *)sinaweibo
{
    NSLog(@"sinaweiboDidLogIn userID = %@ accesstoken = %@ expirationDate = %@ refresh_token = %@", sinaweibo.userID, sinaweibo.accessToken, sinaweibo.expirationDate,sinaweibo.refreshToken);
    
    //[self resetButtons];
    [self storeAuthData];
    
    [self.weiboBtn setTitle:@"微博已选" forState:UIControlStateNormal];
    sinaEnabled = YES;
    if(!self.navigationItem.rightBarButtonItem)
    {
        self.navigationItem.rightBarButtonItem = self.confirmBtnBackup;
    }
    
    //zxx add to bring post status view after login
    //[self bringPostStatusView:nil];
    
    //    ShareViewController *shareController = [[ShareViewController alloc] init];
    //    shareController.delegate = self;
    //
    //    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:shareController];
    //    [self presentViewController:navigationController animated:YES completion: nil];
}

- (void)sinaweiboDidLogOut:(SinaWeibo *)sinaweibo
{
    NSLog(@"sinaweiboDidLogOut");
    [self removeAuthData];
    //[self resetButtons];
}

- (void)sinaweiboLogInDidCancel:(SinaWeibo *)sinaweibo
{
    NSLog(@"sinaweiboLogInDidCancel");
}

- (void)sinaweibo:(SinaWeibo *)sinaweibo logInDidFailWithError:(NSError *)error
{
    NSLog(@"sinaweibo logInDidFailWithError %@", error);
}

- (void)sinaweibo:(SinaWeibo *)sinaweibo accessTokenInvalidOrExpired:(NSError *)error
{
    NSLog(@"sinaweiboAccessTokenInvalidOrExpired %@", error);
    [self removeAuthData];
    //[self resetButtons];
}

//- (void)bringPostStatusView:(SinaWeibo *)sinaweibo
//{
//    ShareViewController *shareController = [[ShareViewController alloc] init];
//    shareController.delegate = self;
//    
//    // Create the navigation controller and present it.
//    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:shareController];
//    [self presentViewController:navigationController animated:YES completion: nil];
//}

#pragma mark - SinaWeiboRequest Delegate

- (void)request:(SinaWeiboRequest *)request didFailWithError:(NSError *)error
{
    if ([request.url hasSuffix:@"users/show.json"])
    {
        userInfo = nil;
    }
    else if ([request.url hasSuffix:@"statuses/user_timeline.json"])
    {
        statuses = nil;
    }
    else if ([request.url hasSuffix:@"statuses/update.json"])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                            message:[NSString stringWithFormat:@"Post status \"%@\" failed!", postStatusText]
                                                           delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alertView show];
        
        NSLog(@"Post status failed with error : %@", error);
    }
    else if ([request.url hasSuffix:@"statuses/upload.json"])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                            message:[NSString stringWithFormat:@"Post image status \"%@\" failed!", postImageStatusText]
                                                           delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alertView show];
        
        NSLog(@"Post image status failed with error : %@", error);
    }
    
    
    //[self resetButtons];
}

- (void)request:(SinaWeiboRequest *)request didFinishLoadingWithResult:(id)result
{
    if ([request.url hasSuffix:@"users/show.json"])
    {
        //userInfo = [result retain];
    }
    else if ([request.url hasSuffix:@"statuses/user_timeline.json"])
    {
        //statuses = [[result objectForKey:@"statuses"] retain];
    }
    else if ([request.url hasSuffix:@"statuses/update.json"])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                            message:[NSString stringWithFormat:@"Post status \"%@\" succeed!", [result objectForKey:@"text"]]
                                                           delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alertView show];
        
        postStatusText = nil;
    }
    else if ([request.url hasSuffix:@"statuses/upload.json"])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                            message:[NSString stringWithFormat:@"Post image status \"%@\" succeed!", [result objectForKey:@"text"]]
                                                           delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alertView show];
        
        postImageStatusText = nil;
    }
    
    //[self resetButtons];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
