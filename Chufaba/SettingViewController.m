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
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if([ud stringForKey:@"LoginType"] == @"sina" || [ud stringForKey:@"LoginType"] == @"tencent")
    {
        self.logoutCell.hidden = NO;
        self.userName.text = [ud stringForKey:@"LoginName"];
        self.loginCell.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[ud stringForKey:@"LoginImage"]]]];
    }
    else
    {
        self.logoutCell.hidden = YES;
        self.userName.text = @"点击登录";
        self.loginCell.imageView.image = [UIImage imageNamed:@"user.png"];
    }
    [self.loginCell setNeedsLayout];
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
    self.logoutCell.hidden = NO;
}

//UIActionSheetDelegate
-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 0)
    {
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        if([ud stringForKey:@"LoginType"] == @"sina")
        {
            [self.accountManager.sinaweibo logOut];
        }
        else
        {
            [[self.accountManager getTencentOAuth] logout:self.accountManager];
        }
        //[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"LoginType"];
        
        self.logoutCell.hidden = YES;
        self.userName.text = @"点击登录";
        self.loginCell.imageView.image = [UIImage imageNamed:@"user.png"];
        [self.loginCell setNeedsLayout];
    }
}

@end
