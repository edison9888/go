//
//  SettingViewController.m
//  Chufaba
//
//  Created by 张 辛欣 on 13-2-13.
//  Copyright (c) 2013年 ChufabaAPP团队. All rights reserved.
//

#import "SettingViewController.h"
#import "LoginViewController.h"

#import "ChufabaAppDelegate.h"
#import "QuartzCore/QuartzCore.h"

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

- (void)setTitle:(NSString *)title
{
    [super setTitle:title];
    UILabel *titleView = (UILabel *)self.navigationItem.titleView;
    if (!titleView) {
        titleView = [[UILabel alloc] initWithFrame:CGRectZero];
        titleView.backgroundColor = [UIColor clearColor];
        titleView.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:20];
        titleView.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        
        titleView.textColor = [UIColor colorWithRed:196/255.0 green:230/255.0 blue:184/255.0 alpha:1.0];
        
        self.navigationItem.titleView = titleView;
    }
    titleView.text = title;
    [titleView sizeToFit];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"设置"];
    
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)] )
    {
        UIImage *image = [UIImage imageNamed:@"bar.png"];
        UINavigationBar *navBar = self.navigationController.navigationBar;
        [navBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
        
        navBar.layer.masksToBounds = NO;
        navBar.layer.shadowOffset = CGSizeMake(0, 1);
        navBar.layer.shadowRadius = 2;
        navBar.layer.shadowColor = [[UIColor colorWithRed:163/255.0 green:160/255.0 blue:155/255.0 alpha:1.0] CGColor];
        navBar.layer.shadowOpacity = 1;
    }
    
    UIButton *saveBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 7, 40, 30)];
    [saveBtn setImage:[UIImage imageNamed:@"done.png"] forState:UIControlStateNormal];
    [saveBtn addTarget:self action:@selector(saveSetting:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithCustomView:saveBtn];
    self.navigationItem.rightBarButtonItem = btn;
    
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor colorWithRed:244/255.0 green:241/255.0 blue:235/255.0 alpha:1.0];
    
    //UIView *bgColorView = [[UIView alloc] init];
    //[bgColorView setBackgroundColor:[UIColor colorWithRed:233/255.0 green:227/255.0 blue:214/255.0 alpha:1.0]];
    
    UIImageView *guideAccessory = [[UIImageView alloc] initWithFrame:CGRectMake(300, 16, 9, 12)];
    guideAccessory.image = [UIImage imageNamed:@"detailsmall.png"];
    self.guideCell.textLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:16];
    self.guideCell.textLabel.textColor = [UIColor colorWithRed:72/255.0 green:70/255.0 blue:66/255.0 alpha:1.0];
    self.guideCell.accessoryView = guideAccessory;
    //[self.guideCell setSelectedBackgroundView:bgColorView];
    
    UIImageView *reviewAccessory = [[UIImageView alloc] initWithFrame:CGRectMake(300, 16, 9, 12)];
    reviewAccessory.image = [UIImage imageNamed:@"detailsmall.png"];
    self.reviewCell.textLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:16];
    self.reviewCell.textLabel.textColor = [UIColor colorWithRed:72/255.0 green:70/255.0 blue:66/255.0 alpha:1.0];
    self.reviewCell.accessoryView = reviewAccessory;
    
    UIImageView *feedbackAccessory = [[UIImageView alloc] initWithFrame:CGRectMake(300, 16, 9, 12)];
    feedbackAccessory.image = [UIImage imageNamed:@"detailsmall.png"];
    self.feedbackCell.textLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:16];
    self.feedbackCell.textLabel.textColor = [UIColor colorWithRed:72/255.0 green:70/255.0 blue:66/255.0 alpha:1.0];
    self.feedbackCell.accessoryView = feedbackAccessory;
    
    UIImageView *aboutAccessory = [[UIImageView alloc] initWithFrame:CGRectMake(300, 16, 9, 12)];
    aboutAccessory.image = [UIImage imageNamed:@"detailsmall.png"];
    self.aboutCell.textLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:16];
    self.aboutCell.textLabel.textColor = [UIColor colorWithRed:72/255.0 green:70/255.0 blue:66/255.0 alpha:1.0];
    self.aboutCell.accessoryView = aboutAccessory;
    
//    self.accountManager = [[SocialAccountManager alloc] init];
//    self.accountManager.delegate = self;
//    
//    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
//    if([self.accountManager hasLogin])
//    {
//        self.logoutCell.hidden = NO;
//        self.userName.text = [ud stringForKey:@"LoginName"];
//        self.loginCell.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[ud stringForKey:@"LoginImage"]]]];
//    }
//    else
//    {
//        self.logoutCell.hidden = YES;
//        self.userName.text = @"点击登录";
//        self.loginCell.imageView.image = [UIImage imageNamed:@"user.png"];
//    }
//    [self.loginCell setNeedsLayout];
}

- (void)viewWillAppear:(BOOL)animated
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if(self.tableView.indexPathForSelectedRow.section == 0)
//    {
//        if(![self.accountManager hasLogin])
//        {
//            LoginViewController *loginController = [[LoginViewController alloc] init];
//            loginController.accountManager = [[SocialAccountManager alloc] init];
//            loginController.accountManager.delegate = self;
//            [self.navigationController pushViewController:loginController animated:YES];
//            
//            ChufabaAppDelegate *chufabaDelegate = (ChufabaAppDelegate *)[UIApplication sharedApplication].delegate;
//            chufabaDelegate.loginViewController = loginController;
//        }
//    }
//    else if(self.tableView.indexPathForSelectedRow.section == 2)
//    {
//        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"你确定登出账户吗？" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"确定", nil];
//        actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
//        [actionSheet showInView:self.view];
//    }
    
    switch (indexPath.row)
    {
        case 0:
            [self performSegueWithIdentifier:@"ShowUserGuide" sender:nil];
            break;
        case 1:
            break;
        case 2:
            [self performSegueWithIdentifier:@"ShowFeedback" sender:nil];
            break;
        case 3:
            [self performSegueWithIdentifier:@"ShowAbout" sender:nil];
            break;
            
        default:
            break;
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ShowUserGuide"])
    {
    
    }
    else if ([[segue identifier] isEqualToString:@"ShowFeedback"])
    {
    
    }
    else if ([[segue identifier] isEqualToString:@"ShowAbout"])
    {
    
    }
}

- (IBAction)saveSetting:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

//implement socialaccountmanager delegate
//-(void) socialAccountManager:(SocialAccountManager *) manager updateDisplayName:(NSString *) displayName updateProfileImg:(NSString *) url
//{
//    self.userName.text = displayName;
//    self.loginCell.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
//    [self.loginCell setNeedsLayout];
//}

//-(void) socialAccountManager:(SocialAccountManager *) manager dismissLoginView:(BOOL) show
//{
//    [self.navigationController popViewControllerAnimated:YES];
//    self.logoutCell.hidden = NO;
//}

//-(void) socialAccountManager:(SocialAccountManager *) manager dismissLoginView:(BOOL) show
//{
//    [self dismissViewControllerAnimated:YES completion:NULL];
//    [self.navigationController popViewControllerAnimated:NO];
//    self.logoutCell.hidden = NO;
//}

//UIActionSheetDelegate
//-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
//    if(buttonIndex == 0)
//    {
//        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
//        if([[ud stringForKey:@"LoginType"] isEqual: @"sina"])
//        {
//            [self.accountManager.sinaweibo logOut];
//        }
//        else if([[ud stringForKey:@"LoginType"] isEqual: @"tencent"])
//        {
//            [[self.accountManager getTencentOAuth] logout:self.accountManager];
//        }
//        else if([[ud stringForKey:@"LoginType"] isEqual: @"douban"])
//        {
//            [[self.accountManager getGTDouban] logOut];
//        }
//        
//        self.logoutCell.hidden = YES;
//        self.userName.text = @"点击登录";
//        self.loginCell.imageView.image = [UIImage imageNamed:@"user.png"];
//        [self.loginCell setNeedsLayout];
//    }
//}

@end
