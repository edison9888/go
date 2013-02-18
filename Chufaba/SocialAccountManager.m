//
//  SocialAccountManager.m
//  Chufaba
//
//  Created by kenzo on 13-2-18.
//  Copyright (c) 2013年 ChufabaAPP团队. All rights reserved.
//

#import "SocialAccountManager.h"
#import "ChufabaAppDelegate.h"

@implementation SocialAccountManager

//- (id) init
//{
//    if(self = [super init])
//    {
//        self.delegate
//    }
//    return self;
//}
//
//- (void) setDelegate:(id<SocialAccountManagerDelegate>)delegate
//{
//
//}

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
    
    //self.delegate
    
    [sinaweibo requestWithURL:@"users/show.json"
                       params:[NSMutableDictionary dictionaryWithObject:sinaweibo.userID forKey:@"uid"]
                   httpMethod:@"GET"
                     delegate:self];
    if ([self.delegate respondsToSelector:@selector(socialAccountManager:updateLogoutcell:)])
    {
        [self.delegate socialAccountManager:self updateLogoutcell:NO];
        [self.delegate socialAccountManager:self dismissLoginView:YES];
    }
    else if ([self.delegate respondsToSelector:@selector(socialAccountManager:deselectAccount:)])
    {
        [self.delegate socialAccountManager:self deselectAccount:nil];
    }
}

- (void)sinaweiboDidLogOut:(SinaWeibo *)sinaweibo
{
    NSLog(@"sinaweiboDidLogOut");
    [self removeAuthData];
    if ([self.delegate respondsToSelector:@selector(socialAccountManager:updateLogoutcell:)])
    {
        [self.delegate socialAccountManager:self updateLogoutcell:NO];
    }
    else if ([self.delegate respondsToSelector:@selector(socialAccountManager:deselectAccount:)])
    {
        [self.delegate socialAccountManager:self deselectAccount:nil];
        [self.delegate socialAccountManager:self updateAccountView:@"未绑定"];
    }
}

- (void)sinaweiboLogInDidCancel:(SinaWeibo *)sinaweibo
{
    NSLog(@"sinaweiboLogInDidCancel");
    if ([self.delegate respondsToSelector:@selector(socialAccountManager:deselectAccount:)])
    {
        [self.delegate socialAccountManager:self deselectAccount:nil];
    }
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
        
        if ([self.delegate respondsToSelector:@selector(socialAccountManager:updateDisplayName:)])
        {
            [self.delegate socialAccountManager:self updateDisplayName:[userInfo objectForKey:@"screen_name"]];
        }
        if ([self.delegate respondsToSelector:@selector(socialAccountManager:updateAccountView:)])
        {
            [self.delegate socialAccountManager:self updateAccountView:[userInfo objectForKey:@"screen_name"]];
        }        
    }
}

@end
