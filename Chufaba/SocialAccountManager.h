//
//  SocialAccountManager.h
//  Chufaba
//
//  Created by kenzo on 13-2-18.
//  Copyright (c) 2013年 ChufabaAPP团队. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SinaWeibo.h"
#import "SinaWeiboRequest.h"
#import <TencentOpenAPI/TencentOAuth.h>

@class SocialAccountManager;

@protocol SocialAccountManagerDelegate<NSObject>

@optional
-(void) socialAccountManager:(SocialAccountManager *) manager updateDisplayName:(NSString *) displayName updateProfileImg:(NSString *) url;
-(void) socialAccountManager:(SocialAccountManager *) manager dismissLoginView:(BOOL) show;
-(void) socialAccountManager:(SocialAccountManager *) manager updateShareView:(NSInteger) loginType;
@end

@interface SocialAccountManager : NSObject <SinaWeiboDelegate, SinaWeiboRequestDelegate, TencentSessionDelegate>
{
    NSDictionary *userInfo;
    TencentOAuth* tencentOAuth;
    NSMutableArray* permissions;
}

- (BOOL) hasLogin;
- (BOOL) isWeiboAuthValid;
- (NSString *)getWeiboUid;

@property (weak, nonatomic) SinaWeibo *sinaweibo;
@property (nonatomic,weak) id<SocialAccountManagerDelegate> delegate;

- (TencentOAuth *) getTencentOAuth;

- (NSMutableArray *) getPermissions;

@end
