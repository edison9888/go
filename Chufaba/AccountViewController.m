//
//  AccountViewController.m
//  Chufaba
//
//  Created by 张 辛欣 on 13-2-13.
//  Copyright (c) 2013年 ChufabaAPP团队. All rights reserved.
//

#import "AccountViewController.h"
#import "ChufabaAppDelegate.h"

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
    SinaWeibo *sinaweibo = [self sinaweibo];
    if([sinaweibo isAuthValid])
    {
        [sinaweibo requestWithURL:@"users/show.json"
                           params:[NSMutableDictionary dictionaryWithObject:sinaweibo.userID forKey:@"uid"]
                       httpMethod:@"GET"
                         delegate:self];
        //self.isSinaBinding.text = [userInfo objectForKey:@"screen_name"];
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

//sina weibo part
- (SinaWeibo *)sinaweibo
{
    ChufabaAppDelegate *delegate = (ChufabaAppDelegate *)[UIApplication sharedApplication].delegate;
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

    [self storeAuthData];
    
    [sinaweibo requestWithURL:@"users/show.json"
                       params:[NSMutableDictionary dictionaryWithObject:sinaweibo.userID forKey:@"uid"]
                   httpMethod:@"GET"
                     delegate:self];
    
    NSIndexPath	*selection = [self.tableView indexPathForSelectedRow];
	if (selection)
		[self.tableView deselectRowAtIndexPath:selection animated:YES];
    
    //self.isSinaBinding.text = [userInfo objectForKey:@"screen_name"];
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
    self.isSinaBinding.text = @"未绑定";
    
    NSIndexPath	*selection = [self.tableView indexPathForSelectedRow];
	if (selection)
		[self.tableView deselectRowAtIndexPath:selection animated:YES];
}

- (void)sinaweiboLogInDidCancel:(SinaWeibo *)sinaweibo
{
    NSLog(@"sinaweiboLogInDidCancel");
    NSIndexPath	*selection = [self.tableView indexPathForSelectedRow];
	if (selection)
		[self.tableView deselectRowAtIndexPath:selection animated:YES];
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

#pragma mark - SinaWeiboRequest Delegate

- (void)request:(SinaWeiboRequest *)request didFailWithError:(NSError *)error
{
    if ([request.url hasSuffix:@"users/show.json"])
    {
        userInfo = nil;
    }
}

- (void)request:(SinaWeiboRequest *)request didFinishLoadingWithResult:(id)result
{
    if ([request.url hasSuffix:@"users/show.json"])
    {
        userInfo = result;
        self.isSinaBinding.text = [userInfo objectForKey:@"screen_name"];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
        {
            SinaWeibo *sinaweibo = [self sinaweibo];
            if([sinaweibo isAuthValid])
            {
                UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"解除", nil];
                actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
                [actionSheet showInView:self.view];
            }
            else
            {
                [sinaweibo logIn];
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
        SinaWeibo *sinaweibo = [self sinaweibo];
        [sinaweibo logOut];
    }
}

@end
