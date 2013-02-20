//
//  SettingViewController.m
//  Chufaba
//
//  Created by 张 辛欣 on 13-2-13.
//  Copyright (c) 2013年 ChufabaAPP团队. All rights reserved.
//

#import "SettingViewController.h"
#import "LoginViewController.h"

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
    //self.loginCell.imageView.frame =  CGRectMake(0,0,50,50);
    if([self.accountManager hasLogin])
    {
        self.logoutCell.hidden = NO;
    }
    else
    {
        self.logoutCell.hidden = YES;
        self.userName.text = @"点击登录";
        self.loginCell.imageView.image = [UIImage imageNamed:@"user.png"];
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
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.tableView.indexPathForSelectedRow.section == 0)
    {
        if(![self.accountManager hasLogin])
        {
            [self performSegueWithIdentifier:@"ShowLogin" sender:[tableView cellForRowAtIndexPath:indexPath]];
        }
    }
    else if(self.tableView.indexPathForSelectedRow.section == 2)
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"你确定登出账户吗？" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"确定", nil];
        actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
        [actionSheet showInView:self.view];
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)saveSetting:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

//implement socialaccountmanager delegate
-(void) socialAccountManager:(SocialAccountManager *) manager updateDisplayName:(NSString *) displayName updateProfileImg:(NSString *) url
{
    self.userName.text = displayName;
    self.loginCell.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
    [self.loginCell setNeedsLayout];
}

-(void) socialAccountManager:(SocialAccountManager *) manager dismissLoginView:(BOOL) show
{
    [self.navigationController popViewControllerAnimated:YES];
}

//UIActionSheetDelegate
-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 0)
    {
        [self.accountManager.sinaweibo logOut];
        self.logoutCell.hidden = YES;
        self.userName.text = @"点击登录";
        self.loginCell.imageView.image = [UIImage imageNamed:@"user.png"];
    }
}

@end
