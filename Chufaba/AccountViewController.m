//
//  AccountViewController.m
//  Chufaba
//
//  Created by 张 辛欣 on 13-2-13.
//  Copyright (c) 2013年 ChufabaAPP团队. All rights reserved.
//

#import "AccountViewController.h"

@interface AccountViewController ()

@end

@implementation AccountViewController

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
    if([self.accountManager.sinaweibo isAuthValid])
    {
        [self.accountManager.sinaweibo requestWithURL:@"users/show.json"
                           params:[NSMutableDictionary dictionaryWithObject:self.accountManager.sinaweibo.userID forKey:@"uid"]
                       httpMethod:@"GET"
                         delegate:self.accountManager];
    }
    else
    {
        self.isSinaBinding.text = @"未绑定";
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//implement SocialAccountManagerDelegate
-(void) socialAccountManager:(SocialAccountManager *) manager updateAccountView:(NSString *) displayName
{
    self.isSinaBinding.text = displayName;
}

-(void) socialAccountManager:(SocialAccountManager *) manager deselectAccount:(NSIndexPath *) indexPath
{
    NSIndexPath	*selection = [self.tableView indexPathForSelectedRow];
    if(selection)
        [self.tableView deselectRowAtIndexPath:selection animated:YES];
}

#pragma mark - SinaWeibo Delegate

//- (void)sinaweiboDidLogIn:(SinaWeibo *)sinaweibo
//{
//    NSLog(@"sinaweiboDidLogIn userID = %@ accesstoken = %@ expirationDate = %@ refresh_token = %@", sinaweibo.userID, sinaweibo.accessToken, sinaweibo.expirationDate,sinaweibo.refreshToken);
//
//    [self storeAuthData];
//    
//    [sinaweibo requestWithURL:@"users/show.json"
//                       params:[NSMutableDictionary dictionaryWithObject:sinaweibo.userID forKey:@"uid"]
//                   httpMethod:@"GET"
//                     delegate:self];
//    
//    NSIndexPath	*selection = [self.tableView indexPathForSelectedRow];
//	if (selection)
//		[self.tableView deselectRowAtIndexPath:selection animated:YES];
//}
//
//- (void)sinaweiboDidLogOut:(SinaWeibo *)sinaweibo
//{
//    NSLog(@"sinaweiboDidLogOut");
//    [self removeAuthData];
//    self.isSinaBinding.text = @"未绑定";
//    
//    NSIndexPath	*selection = [self.tableView indexPathForSelectedRow];
//	if (selection)
//		[self.tableView deselectRowAtIndexPath:selection animated:YES];
//}
//
//- (void)sinaweiboLogInDidCancel:(SinaWeibo *)sinaweibo
//{
//    NSLog(@"sinaweiboLogInDidCancel");
//    NSIndexPath	*selection = [self.tableView indexPathForSelectedRow];
//	if (selection)
//		[self.tableView deselectRowAtIndexPath:selection animated:YES];
//}

//- (void)request:(SinaWeiboRequest *)request didFinishLoadingWithResult:(id)result
//{
//    if ([request.url hasSuffix:@"users/show.json"])
//    {
//        userInfo = result;
//        self.isSinaBinding.text = [userInfo objectForKey:@"screen_name"];
//    }
//}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
        {
            if([self.accountManager.sinaweibo isAuthValid])
            {
                UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"解除", nil];
                actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
                [actionSheet showInView:self.view];
            }
            else
            {
                [self.accountManager.sinaweibo logIn];
            }
        }
            break;
        case 1:
            break;
        case 2:
            break;
        case 3:
            break;
            
        default:
            break;
    }
}

-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 0)
    {
        [self.accountManager.sinaweibo logOut];
    }
}

@end
