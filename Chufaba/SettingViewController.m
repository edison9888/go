//
//  SettingViewController.m
//  Chufaba
//
//  Created by 张 辛欣 on 13-2-13.
//  Copyright (c) 2013年 ChufabaAPP团队. All rights reserved.
//

#import "SettingViewController.h"
#import "LoginViewController.h"
#import "AccountViewController.h"

@interface SettingViewController ()

@end

@implementation SettingViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.accountManager = [[SocialAccountManager alloc] init];
    self.accountManager.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    if([self.accountManager hasLogin])
    {
        self.logoutCell.hidden = NO;
    }
    else
    {
        self.logoutCell.hidden = YES;
        self.userName.text = @"点击登录";
    }
    if([self.accountManager isWeiboAuthValid])
    {
        [self.accountManager.sinaweibo requestWithURL:@"users/show.json"
                                               params:[NSMutableDictionary dictionaryWithObject:self.accountManager.sinaweibo.userID forKey:@"uid"]
                                           httpMethod:@"GET"
                                             delegate:self.accountManager];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

 - (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ShowLogin"])
    {
        LoginViewController *loginController = [segue destinationViewController];
        loginController.accountManager = [[SocialAccountManager alloc] init];
        loginController.accountManager.delegate = self;
    }
    else if ([[segue identifier] isEqualToString:@"AccountBinding"])
    {
        AccountViewController *accountController = [segue destinationViewController];
        accountController.accountManager = [[SocialAccountManager alloc] init];
        accountController.accountManager.delegate = accountController;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.tableView.indexPathForSelectedRow.section == 0 && self.tableView.indexPathForSelectedRow.row == 0)
    {
        //if(![self.accountManager.sinaweibo isAuthValid])
        if(![self.accountManager hasLogin])
        {
            [self performSegueWithIdentifier:@"ShowLogin" sender:[tableView cellForRowAtIndexPath:indexPath]];
        }
    }
    else if(self.tableView.indexPathForSelectedRow.section == 0 && self.tableView.indexPathForSelectedRow.row == 1)
    {
        if([self.accountManager hasLogin])
        {
            [self performSegueWithIdentifier:@"AccountBinding" sender:[tableView cellForRowAtIndexPath:indexPath]];
        }
        else
        {
            [self performSegueWithIdentifier:@"ShowLogin" sender:[tableView cellForRowAtIndexPath:indexPath]];
        }
    }
    else if(self.tableView.indexPathForSelectedRow.section == 2)
    {
        [self.accountManager.sinaweibo logOut];
        self.logoutCell.hidden = YES;
        self.userName.text = @"点击登录";
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)saveSetting:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

//implement socialaccountmanager delegate
-(void) socialAccountManager:(SocialAccountManager *) manager updateDisplayName:(NSString *) displayName
{
    self.userName.text = displayName;
}

-(void) socialAccountManager:(SocialAccountManager *) manager dismissLoginView:(BOOL) show
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
