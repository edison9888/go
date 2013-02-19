//
//  LoginViewController.m
//  Chufaba
//
//  Created by kenzo on 13-2-18.
//  Copyright (c) 2013年 ChufabaAPP团队. All rights reserved.
//

#import "LoginViewController.h"
#import "ChufabaAppDelegate.h"


@interface LoginViewController ()

@end

@implementation LoginViewController

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
    //self.accountManager = [[SocialAccountManager alloc] init];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)weiboLogin:(id)sender
{
    [self.accountManager.sinaweibo logIn];
}

- (IBAction)qqLogin:(id)sender
{
    
}

- (IBAction)doubanLogin:(id)sender
{
    
}

@end
