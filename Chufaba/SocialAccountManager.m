//
//  SocialAccountManager.m
//  Chufaba
//
//  Created by kenzo on 13-2-18.
//  Copyright (c) 2013年 ChufabaAPP团队. All rights reserved.
//

#import "SocialAccountManager.h"
#import "ChufabaAppDelegate.h"
#import "FMDBDataAccess.h"

@implementation SocialAccountManager

- (id) init
{
    if (self = [super init]) {
        permissions = [NSArray arrayWithObjects:
                        kOPEN_PERMISSION_GET_USER_INFO,
                        kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,
                        kOPEN_PERMISSION_ADD_SHARE,
                        nil];
        tencentOAuth = [[TencentOAuth alloc] initWithAppId:@"100379396" andDelegate:self];
    }
    return self;
}

- (TencentOAuth *) getTencentOAuth
{
    return tencentOAuth;
}

- (NSMutableArray *) getPermissions
{
    return permissions;
}

- (BOOL) hasLogin
{
    BOOL loginFlag = NO;
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if([ud stringForKey:@"LoginType"] == @"sina")
    {
        SinaWeibo *sinaweibo = [self sinaweibo];
        if(sinaweibo.isLoggedIn)
            loginFlag = YES;
    }
    else if([ud stringForKey:@"LoginType"] == @"tencent")
    {
        loginFlag = YES;
    }
    return loginFlag;
}

- (BOOL) isWeiboAuthValid
{
    SinaWeibo *sinaweibo = [self sinaweibo];
    if(sinaweibo.isAuthValid)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (NSString *)getWeiboUid
{
    SinaWeibo *sinaweibo = [self sinaweibo];
    return sinaweibo.userID;
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
    if ([self.delegate respondsToSelector:@selector(socialAccountManager:dismissLoginView:)])
    {
        [self.delegate socialAccountManager:self dismissLoginView:YES];
    }
    if ([self.delegate respondsToSelector:@selector(socialAccountManager:updateShareView:)])
    {
        [self.delegate socialAccountManager:self updateShareView:YES];
    }
    
    FMDBDataAccess *dba = [[FMDBDataAccess alloc] init];
    
    //新建一个用户，如果该weibo_uid不存在
    if(![dba userExist:sinaweibo.userID logintype:1])
    {
        [dba createUser:sinaweibo.userID accesstoken:sinaweibo.accessToken mainAccountType:1];
    }
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if(![ud objectForKey:@"LoginType"])
    {
        [ud setObject:@"sina" forKey:@"LoginType"];
        [ud synchronize];
    }
}

- (void)sinaweiboDidLogOut:(SinaWeibo *)sinaweibo
{
    NSLog(@"sinaweiboDidLogOut");
    [self removeAuthData];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"LoginType"];
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
        
        if ([self.delegate respondsToSelector:@selector(socialAccountManager:updateDisplayName:updateProfileImg:)])
        {
            [self.delegate socialAccountManager:self updateDisplayName:[userInfo objectForKey:@"screen_name"] updateProfileImg:[userInfo objectForKey:@"profile_image_url"]];
        }     
    }
}

//QQ Login part

#pragma mark - Tencent oauth delegate
- (void)tencentDidLogin {
    if (tencentOAuth.accessToken&& 0 != [tencentOAuth.accessToken length])
    {
        FMDBDataAccess *dba = [[FMDBDataAccess alloc] init];
        
        //新建一个用户，如果该weibo_uid不存在
        if(![dba userExist:tencentOAuth.openId logintype:2])
        {
            [dba createUser:tencentOAuth.openId accesstoken:tencentOAuth.accessToken mainAccountType:2];
        }
        
        [tencentOAuth getUserInfo];
        if ([self.delegate respondsToSelector:@selector(socialAccountManager:dismissLoginView:)])
        {
            [self.delegate socialAccountManager:self dismissLoginView:YES];
        }
//        if ([self.delegate respondsToSelector:@selector(socialAccountManager:updateShareView:)])
//        {
//            [self.delegate socialAccountManager:self updateShareView:YES];
//        }
        
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        if(![ud objectForKey:@"LoginType"])
        {
            [ud setObject:@"tencent" forKey:@"LoginType"];
            [ud synchronize];
        }
    }
}

- (void)tencentDidNotLogin:(BOOL)cancelled
{
	if (cancelled){
		//用户取消登录
	}
	else {
		//登录失败
	}
	
}

-(void)tencentDidNotNetWork
{
	//无网络连接，请设置网络
}

-(void)tencentDidLogout
{
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"LoginType"];
}

- (void)getUserInfoResponse:(APIResponse*) response {
	if (response.retCode == URLREQUEST_SUCCEED)
	{
		if ([self.delegate respondsToSelector:@selector(socialAccountManager:updateDisplayName:updateProfileImg:)])
        {
            [self.delegate socialAccountManager:self updateDisplayName:[response.jsonResponse objectForKey:@"nickname"] updateProfileImg:[response.jsonResponse objectForKey:@"figureurl"]];
        }
	}
}

@end
