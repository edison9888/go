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
{
    BOOL clickRecomend;
}

@end

@implementation SettingViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"设置";
    
    UINavigationBar *navBar = self.navigationController.navigationBar;
    navBar.layer.shadowPath = [UIBezierPath bezierPathWithRect:navBar.bounds].CGPath;
    navBar.layer.masksToBounds = NO;
    navBar.layer.shadowOffset = CGSizeMake(0, 1);
    navBar.layer.shadowRadius = 2;
    navBar.layer.shadowColor = [[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.3] CGColor];
    navBar.layer.shadowOpacity = 1;
    navBar.layer.shouldRasterize = YES;
    navBar.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    UIButton *closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 7, 40, 30)];
    [closeBtn setImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [closeBtn setImage:[UIImage imageNamed:@"cancel_click"] forState:UIControlStateHighlighted];
    [closeBtn addTarget:self action:@selector(saveSetting:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithCustomView:closeBtn];
    self.navigationItem.leftBarButtonItem = btn;
    
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor colorWithRed:244/255.0 green:241/255.0 blue:235/255.0 alpha:1.0];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorColor = [UIColor colorWithRed:227/255.0 green:219/255.0 blue:204/255.0 alpha:1.0];

    UIImageView *guideSelView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"cell_bg.png"] stretchableImageWithLeftCapWidth:8 topCapHeight:8]];
    UIImageView *guideAccessory = [[UIImageView alloc] initWithFrame:CGRectMake(300, 16, 9, 12)];
    guideAccessory.image = [UIImage imageNamed:@"detailsmall.png"];
    self.guideCell.textLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:16];
    self.guideCell.textLabel.textColor = [UIColor colorWithRed:72/255.0 green:70/255.0 blue:66/255.0 alpha:1.0];
    self.guideCell.textLabel.highlightedTextColor = [UIColor colorWithRed:72/255.0 green:70/255.0 blue:66/255.0 alpha:1.0];
    self.guideCell.accessoryView = guideAccessory;
    [self.guideCell setSelectedBackgroundView:guideSelView];
    
    UIImageView *reviewSelView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"cell_bgm.png"] stretchableImageWithLeftCapWidth:8 topCapHeight:8]];
    UIImageView *reviewAccessory = [[UIImageView alloc] initWithFrame:CGRectMake(300, 16, 9, 12)];
    reviewAccessory.image = [UIImage imageNamed:@"detailsmall.png"];
    self.reviewCell.textLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:16];
    self.reviewCell.textLabel.textColor = [UIColor colorWithRed:72/255.0 green:70/255.0 blue:66/255.0 alpha:1.0];
    self.reviewCell.textLabel.highlightedTextColor = [UIColor colorWithRed:72/255.0 green:70/255.0 blue:66/255.0 alpha:1.0];
    self.reviewCell.accessoryView = reviewAccessory;
    [self.reviewCell setSelectedBackgroundView:reviewSelView];
    
    UIImageView *feedbackSelView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"cell_bgm.png"] stretchableImageWithLeftCapWidth:8 topCapHeight:8]];
    UIImageView *feedbackAccessory = [[UIImageView alloc] initWithFrame:CGRectMake(300, 16, 9, 12)];
    feedbackAccessory.image = [UIImage imageNamed:@"detailsmall.png"];
    self.feedbackCell.textLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:16];
    self.feedbackCell.textLabel.textColor = [UIColor colorWithRed:72/255.0 green:70/255.0 blue:66/255.0 alpha:1.0];
    self.feedbackCell.textLabel.highlightedTextColor = [UIColor colorWithRed:72/255.0 green:70/255.0 blue:66/255.0 alpha:1.0];
    self.feedbackCell.accessoryView = feedbackAccessory;
    [self.feedbackCell setSelectedBackgroundView:feedbackSelView];
    
    UIImageView *aboutSelView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"cell_bgb.png"] stretchableImageWithLeftCapWidth:8 topCapHeight:8]];
    UIImageView *aboutAccessory = [[UIImageView alloc] initWithFrame:CGRectMake(300, 16, 9, 12)];
    aboutAccessory.image = [UIImage imageNamed:@"detailsmall.png"];
    self.aboutCell.textLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:16];
    self.aboutCell.textLabel.textColor = [UIColor colorWithRed:72/255.0 green:70/255.0 blue:66/255.0 alpha:1.0];
    self.aboutCell.textLabel.highlightedTextColor = [UIColor colorWithRed:72/255.0 green:70/255.0 blue:66/255.0 alpha:1.0];
    self.aboutCell.accessoryView = aboutAccessory;
    [self.aboutCell setSelectedBackgroundView:aboutSelView];
    
    UIImageView *recommendSelView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"cell_bgb.png"] stretchableImageWithLeftCapWidth:8 topCapHeight:8]];
    UIImageView *recommendAccessory = [[UIImageView alloc] initWithFrame:CGRectMake(300, 16, 9, 12)];
    recommendAccessory.image = [UIImage imageNamed:@"detailsmall.png"];
    self.recommendCell.textLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:16];
    self.recommendCell.textLabel.textColor = [UIColor colorWithRed:72/255.0 green:70/255.0 blue:66/255.0 alpha:1.0];
    self.recommendCell.textLabel.highlightedTextColor = [UIColor colorWithRed:72/255.0 green:70/255.0 blue:66/255.0 alpha:1.0];
    self.recommendCell.accessoryView = recommendAccessory;
    [self.recommendCell setSelectedBackgroundView:recommendSelView];
    
    self.loginCell.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    self.userPic = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, 50, 50)];
    self.userPic.layer.cornerRadius = 3.0;
    self.userPic.layer.masksToBounds = YES;
    [self.loginCell.contentView addSubview:self.userPic];
    self.loginCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.userName = [[UILabel alloc] initWithFrame:CGRectMake(70, 15, 200, 20)];
    self.userName.backgroundColor = [UIColor clearColor];
    self.userName.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:16];
    self.userName.textColor = [UIColor colorWithRed:72/255.0 green:70/255.0 blue:66/255.0 alpha:1.0];
    [self.loginCell.contentView addSubview:self.userName];
    
    self.logoutCell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logout"]];
    self.logoutCell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logout_click"]];
    
    UILabel *warningLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 50, 220, 20)];
    warningLabel.backgroundColor = [UIColor clearColor];
    warningLabel.text = @"如果退出，您的数据将无法同步到云端";
    warningLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:12];
    warningLabel.textColor = [UIColor colorWithRed:153/255.0 green:150/255.0 blue:145/255.0 alpha:1.0];
    [self.logoutCell.contentView addSubview:warningLabel];
    
    self.accountManager = [[SocialAccountManager alloc] init];
    self.accountManager.delegate = self;
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if([self.accountManager hasLogin])
    {
        self.logoutCell.hidden = NO;
        self.userName.text = [ud stringForKey:@"LoginName"];
        //NSString *url = [ud stringForKey:@"LoginImage"];
        //self.loginCell.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[ud stringForKey:@"LoginImage"]]]];
        self.userPic.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[ud stringForKey:@"LoginImage"]]]];

    }
    else
    {
        self.logoutCell.hidden = YES;
        self.userName.text = @"点击登录";
        //self.loginCell.imageView.image = [UIImage imageNamed:@"user"];
        self.userPic.image = [UIImage imageNamed:@"user"];
    }
    [self.loginCell setNeedsLayout];
}

-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0)
         return 16.0f;
    else
        return 5.0f;
}


-(CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section
{
    if(section == 0 || section == 2)
        return 11.0f;
    else
        return 5.0f;
}

-(UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
}

-(UIView*)tableView:(UITableView*)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.tableView.indexPathForSelectedRow.section == 0)
    {
        if(![self.accountManager hasLogin])
        {
            LoginViewController *loginController = [[LoginViewController alloc] init];
            loginController.accountManager = [[SocialAccountManager alloc] init];
            loginController.accountManager.delegate = self;
            [self.navigationController pushViewController:loginController animated:YES];
            
            ChufabaAppDelegate *chufabaDelegate = (ChufabaAppDelegate *)[UIApplication sharedApplication].delegate;
            chufabaDelegate.loginViewController = loginController;
        }
    }
    else if(self.tableView.indexPathForSelectedRow.section == 1)
    {
        switch (indexPath.row)
        {
            case 0:
                [self performSegueWithIdentifier:@"ShowUserGuide" sender:nil];
                break;
            case 1:
                [self performSegueWithIdentifier:@"ShowAbout" sender:nil];
                break;
            case 2:
                [self performSegueWithIdentifier:@"ShowFeedback" sender:nil];
                break;
            default:
                break;
        }
    }
    else if(self.tableView.indexPathForSelectedRow.section == 2)
    {
        if(indexPath.row == 0)
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/app/id611640407"]];
        }
        else
        {
            clickRecomend = TRUE;
            [self openShareMenu];
        }
    }
    else if(self.tableView.indexPathForSelectedRow.section == 3)
    {
        clickRecomend = FALSE;
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"退出后行程修改不能同步到云端" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"退出登录" otherButtonTitles:nil, nil];
        actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
        [actionSheet showInView:self.view];
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)openShareMenu
{
    if (!([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]))
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"错误" message:@"您还没有安装微信或者您的版本不支持分享功能!" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    else
    {
        self.tableView.contentInset = UIEdgeInsetsZero;
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"分享给微信好友", @"分享到微信朋友圈", nil];
        actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
        [actionSheet showInView:self.view];
    }
}

//implement weixin delegate

-(void) onResp:(BaseResp*)resp
{
    if([resp isKindOfClass:[SendMessageToWXResp class]])
    {
        NSString *strTitle = [NSString stringWithFormat:@"发送结果"];
        NSString *strMsg = [NSString stringWithFormat:@"发送媒体消息结果:%d", resp.errCode];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    else if([resp isKindOfClass:[SendAuthResp class]])
    {
        NSString *strTitle = [NSString stringWithFormat:@"Auth结果"];
        NSString *strMsg = [NSString stringWithFormat:@"Auth结果:%d", resp.errCode];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享成功" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (IBAction)saveSetting:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

//implement socialaccountmanager delegate
-(void) socialAccountManager:(SocialAccountManager *) manager updateDisplayName:(NSString *) displayName updateProfileImg:(NSString *) url
{
    self.userName.text = displayName;
    //self.loginCell.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
    self.userPic.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
    [self.loginCell setNeedsLayout];
}

//-(void) socialAccountManager:(SocialAccountManager *) manager dismissLoginView:(BOOL) show
//{
//    [self.navigationController popViewControllerAnimated:YES];
//    self.logoutCell.hidden = NO;
//}

-(void) socialAccountManager:(SocialAccountManager *) manager dismissLoginView:(BOOL) show
{
    [self dismissViewControllerAnimated:YES completion:NULL];
    [self.navigationController popViewControllerAnimated:NO];
    self.logoutCell.hidden = NO;
}

//UIActionSheetDelegate
-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(clickRecomend)
    {
        if(buttonIndex == 0)
        {
            WXMediaMessage *message = [WXMediaMessage message];
            message.title = @"我的行程，求建议";
            message.description = @"云南之旅，7天32个地点";
            [message setThumbImage:[UIImage imageNamed:@"tlogo"]];
            
            //        WXImageObject *ext = [WXImageObject object];
            //        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"tlogo" ofType:@"png"];
            //        ext.imageData = [NSData dataWithContentsOfFile:filePath] ;
            //        message.mediaObject = ext;
            
            WXWebpageObject *ext = [WXWebpageObject object];
            //ext.webpageUrl = @"http://www.chufaba.me";
            ext.webpageUrl = @"http://www.baidu.com";
            message.mediaObject = ext;
            
            SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
            req.bText = NO;
            req.message = message;
            req.scene = WXSceneSession;
            
            [WXApi sendReq:req];
        }
        else if(buttonIndex == 1)
        {
            SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
            req.bText = YES;
            req.text = @"t";
            req.scene = WXSceneTimeline;
            
            [WXApi sendReq:req];
        }
    }
    else
    {
        if(buttonIndex == 0)
        {
            NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
            if([[ud stringForKey:@"LoginType"] isEqual: @"sina"])
            {
                [self.accountManager.sinaweibo logOut];
            }
            else if([[ud stringForKey:@"LoginType"] isEqual: @"tencent"])
            {
                [[self.accountManager getTencentOAuth] logout:self.accountManager];
            }
            else if([[ud stringForKey:@"LoginType"] isEqual: @"douban"])
            {
                [[self.accountManager getGTDouban] logOut];
            }
            
            self.logoutCell.hidden = YES;
            self.userName.text = @"点击登录";
            //self.loginCell.imageView.image = [UIImage imageNamed:@"user"];
            self.userPic.image = [UIImage imageNamed:@"user"];
            [self.loginCell setNeedsLayout];
        }
    }
}

- (void)viewDidUnload {
    [self setLogoutCell:nil];
    [self setLoginCell:nil];
    [self setUserName:nil];
    [self setRecommendCell:nil];
    [super viewDidUnload];
}
@end
