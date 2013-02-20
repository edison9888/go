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

- (BOOL) hasLogin
{
    SinaWeibo *sinaweibo = [self sinaweibo];
    if(sinaweibo.isLoggedIn)
    {
        return YES;
    }
    else
    {
        return NO;
    }
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
    
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    
    //新建一个用户，如果该weibo_uid不存在
    if(![dba userExist:[f numberFromString:sinaweibo.userID] logintype:1])
    {
        [dba createUser:[f numberFromString:sinaweibo.userID] accesstoken:sinaweibo.accessToken mainAccountType:1];
    }
}

- (void)sinaweiboDidLogOut:(SinaWeibo *)sinaweibo
{
    NSLog(@"sinaweiboDidLogOut");
    [self removeAuthData];
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

@end
