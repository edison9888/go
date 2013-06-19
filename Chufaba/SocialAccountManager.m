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
#import "AFHTTPClient.h"

@implementation SocialAccountManager

- (id) init
{
    if (self = [super init]) {
        //permissions = [NSArray arrayWithObjects:kOPEN_PERMISSION_GET_USER_INFO, kOPEN_PERMISSION_GET_SIMPLE_USER_INFO, kOPEN_PERMISSION_ADD_SHARE, nil];
        permissions =  [NSArray arrayWithObjects:@"get_user_info", @"add_share", nil];
        tencentOAuth = [[TencentOAuth alloc] initWithAppId:@"100379396" andDelegate:self];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSDictionary *tencentAuthInfo = [defaults objectForKey:@"TencentAuthData"];
        if ([tencentAuthInfo objectForKey:@"AccessTokenKey"] && [tencentAuthInfo objectForKey:@"ExpirationDateKey"] && [tencentAuthInfo objectForKey:@"OpenIDKey"])
        {
            tencentOAuth.accessToken = [tencentAuthInfo objectForKey:@"AccessTokenKey"];
            tencentOAuth.expirationDate = [tencentAuthInfo objectForKey:@"ExpirationDateKey"];
            tencentOAuth.openId = [tencentAuthInfo objectForKey:@"OpenIDKey"];
        }
        
//        aDouban = [[GTDouban alloc] init];
//        [aDouban setDelegate:self];
    }
    return self;
}

//- (GTDouban *) getGTDouban
//{
//    return aDouban;
//}

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
    //if([[ud stringForKey:@"LoginType"] isEqual: @"sina"] || [[ud stringForKey:@"LoginType"] isEqual: @"tencent"] || [[ud stringForKey:@"LoginType"] isEqual: @"douban"])
    if([[ud stringForKey:@"LoginType"] isEqual: @"sina"] || [[ud stringForKey:@"LoginType"] isEqual: @"tencent"])
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

- (void)removeTencentAuthData
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"TencentAuthData"];
}

- (void)storeTencentAuthData
{
    NSDictionary *authData = [NSDictionary dictionaryWithObjectsAndKeys:
                              tencentOAuth.accessToken, @"AccessTokenKey",
                              tencentOAuth.expirationDate, @"ExpirationDateKey",
                              tencentOAuth.openId, @"OpenIDKey", nil];
    [[NSUserDefaults standardUserDefaults] setObject:authData forKey:@"TencentAuthData"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - SinaWeibo Delegate

- (void)sinaweiboDidLogIn:(SinaWeibo *)sinaweibo
{
    NSLog(@"sinaweiboDidLogIn userID = %@ accesstoken = %@ expirationDate = %@ refresh_token = %@", sinaweibo.userID, sinaweibo.accessToken, sinaweibo.expirationDate,sinaweibo.refreshToken);
    
    [self storeAuthData];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *loginTypeVal = [ud objectForKey:@"LoginType"];
    if(![loginTypeVal isEqual: @"tencent"])
    {
        [ud setObject:@"sina" forKey:@"LoginType"];
        [ud synchronize];
        [sinaweibo requestWithURL:@"users/show.json"
                           params:[NSMutableDictionary dictionaryWithObject:sinaweibo.userID forKey:@"uid"]
                       httpMethod:@"GET"
                         delegate:self];
    }    
    
    if ([self.delegate respondsToSelector:@selector(socialAccountManager:dismissLoginView:)])
    {
        [self.delegate socialAccountManager:self dismissLoginView:YES];
    }
    if ([self.delegate respondsToSelector:@selector(socialAccountManager:updateShareView:)])
    {
        [self.delegate socialAccountManager:self updateShareView:1];
    }
    if ([self.delegate respondsToSelector:@selector(socialAccountManager:openShareMenu:)])
    {
        [self.delegate socialAccountManager:self openShareMenu:1];
    }
    
    FMDBDataAccess *dba = [[FMDBDataAccess alloc] init];
    
    //新建一个用户，如果该weibo_uid不存在
    if(![dba userExist:sinaweibo.userID logintype:1])
    {
        [dba createUser:sinaweibo.userID accesstoken:sinaweibo.accessToken mainAccountType:1];
    }
}

- (void)sinaweiboDidLogOut:(SinaWeibo *)sinaweibo
{
    [self removeAuthData];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud removeObjectForKey:@"LoginType"];
    [ud synchronize];
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
        
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        if([[ud stringForKey:@"LoginType"] isEqual: @"sina"])
        {
            [ud setObject:[userInfo objectForKey:@"screen_name"] forKey:@"LoginName"];
            [ud setObject:[userInfo objectForKey:@"profile_image_url"] forKey:@"LoginImage"];
            [ud synchronize];
        }
        
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
        [self storeTencentAuthData];
        
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        NSString *loginTypeVal = [ud objectForKey:@"LoginType"];
        if(![loginTypeVal isEqual: @"sina"])
        {
            [ud setObject:@"tencent" forKey:@"LoginType"];
            [ud synchronize];
            [tencentOAuth getUserInfo];
        }
        
        FMDBDataAccess *dba = [[FMDBDataAccess alloc] init];
        
        //新建一个用户，如果该weibo_uid不存在
        if(![dba userExist:tencentOAuth.openId logintype:2])
        {
            [dba createUser:tencentOAuth.openId accesstoken:tencentOAuth.accessToken mainAccountType:2];
        }
        
        if ([self.delegate respondsToSelector:@selector(socialAccountManager:dismissLoginView:)])
        {
            [self.delegate socialAccountManager:self dismissLoginView:YES];
        }
        if ([self.delegate respondsToSelector:@selector(socialAccountManager:updateShareView:)])
        {
            [self.delegate socialAccountManager:self updateShareView:2];
        }
        if ([self.delegate respondsToSelector:@selector(socialAccountManager:openShareMenu:)])
        {
            [self.delegate socialAccountManager:self openShareMenu:2];
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
	[self removeTencentAuthData];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud removeObjectForKey:@"LoginType"];
    [ud synchronize];
}

- (void)getUserInfoResponse:(APIResponse*) response {
	if (response.retCode == URLREQUEST_SUCCEED)
	{
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        if([[ud stringForKey:@"LoginType"] isEqual: @"tencent"])
        {
            [ud setObject:[response.jsonResponse objectForKey:@"nickname"] forKey:@"LoginName"];
            [ud setObject:[response.jsonResponse objectForKey:@"figureurl"] forKey:@"LoginImage"];
            [ud synchronize];
        }
        
        if ([self.delegate respondsToSelector:@selector(socialAccountManager:updateDisplayName:updateProfileImg:)])
        {
            [self.delegate socialAccountManager:self updateDisplayName:[response.jsonResponse objectForKey:@"nickname"] updateProfileImg:[response.jsonResponse objectForKey:@"figureurl"]];
        }
	}
}

#pragma mark - GT douban delegate

//- (void)engineAlreadyLoggedIn:(GTDouban *)engine
//{
//
//}

//- (void)engineDidLogOut:(GTDouban *)engine
//{
//    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
//    [ud removeObjectForKey:@"LoginType"];
//    [ud synchronize];
//}

//- (void)engineNotAuthorized:(GTDouban *)engine
//{
//
//}

//- (void)engineAuthorizeExpired:(GTDouban *)engine
//{
//
//}

//- (void)engineDidLogIn:(GTDouban *)engine
//{
//    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
//    NSString *loginTypeVal = [ud objectForKey:@"LoginType"];
//    if(![loginTypeVal isEqual: @"douban"])
//    {
//        [ud setObject:@"douban" forKey:@"LoginType"];
//        [ud synchronize];
//        [aDouban getUserInfo];
//    }
//    
//    
//    if ([self.delegate respondsToSelector:@selector(socialAccountManager:dismissLoginView:)])
//    {
//        [self.delegate socialAccountManager:self dismissLoginView:YES];
//    }
//    
//    FMDBDataAccess *dba = [[FMDBDataAccess alloc] init];
//    
//    //新建一个用户，如果该douban_uid不存在
//    if(![dba userExist:aDouban.userID logintype:3])
//    {
//        [dba createUser:aDouban.userID accesstoken:aDouban.accessToken mainAccountType:3];
//    }
//}

//- (void)engine:(GTDouban *)engine didFailToLogInWithError:(NSError *)error
//{
//
//}

//- (void)engine:(GTDouban *)engine didCancel:(BOOL)cancel
//{
//
//}

//- (void)engine:(GTDouban *)engine requestDidFailWithError:(NSError *)error
//{
//
//}

//- (void)engine:(GTDouban *)engine requestDidSucceedWithResult:(id)result
//{
//    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
//    if([[ud stringForKey:@"LoginType"] isEqual: @"douban"])
//    {
//        [ud setObject:[result objectForKey:@"name"] forKey:@"LoginName"];
//        [ud setObject:[result objectForKey:@"avatar"] forKey:@"LoginImage"];
//        [ud synchronize];
//    }
//    
//    if ([self.delegate respondsToSelector:@selector(socialAccountManager:updateDisplayName:updateProfileImg:)])
//    {
//        [self.delegate socialAccountManager:self updateDisplayName:[result objectForKey:@"name"] updateProfileImg:[result objectForKey:@"avatar"]];
//    }
//}

/*
 * provider: 登录服务提供商 1:weibo 2:qq 3:douban
 * expire: 过期时间戳
 *
 */
- (void)getUidByOpenidOf:(NSNumber *)provider withOpenid:(NSString *)openid andName:(NSString *)name andToken:(NSString *)token andExpire:(NSNumber *)expire
{
    NSURL *url = [NSURL URLWithString:@"http://chufaba.me:3000"];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    NSDictionary *account = [NSDictionary dictionaryWithObjectsAndKeys:
                            provider, @"provider",
                            openid, @"openid",
                            name, @"name",
                            token, @"token",
                            expire, @"expire",
                            nil];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            account, @"openid",
                            nil];
    [httpClient postPath:@"/openids.json" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error = nil;
        NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&error];
        if (error) {
            NSLog(@"Error serializing %@", error);
        } else {
            NSNumber *uid = [responseJSON objectForKey:@"uid"];
            NSLog([NSString stringWithFormat:@"%d", [uid intValue]]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
    }];
}

@end
