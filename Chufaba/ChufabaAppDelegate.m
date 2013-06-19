//
//  itineraryAppDelegate.m
//  出发吧
//
//  Created by kenzo on 13-1-16.
//  Copyright (c) 2013年 出发吧APP团队. All rights reserved.
//

#import "ChufabaAppDelegate.h"
#import "ItineraryViewController.h"
#import "SocialAccountManager.h"
#import "MobClick.h"

@implementation ChufabaAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [MobClick startWithAppkey:@"5145b36356240b4c150023e6"];
    
    self.databaseName = @"travelplan.sqlite";
    
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [documentPaths objectAtIndex:0];
    self.databasePath = [documentDir stringByAppendingPathComponent:self.databaseName];
    
    [self createAndCheckDatabase];
    
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"bar"] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor colorWithRed:196/255.0 green:230/255.0 blue:184/255.0 alpha:1.0], UITextAttributeTextColor,
      [UIColor colorWithWhite:0.0 alpha:0.5], UITextAttributeTextShadowColor,
      [UIFont fontWithName:@"STHeitiSC-Medium" size:20], UITextAttributeFont,
      nil]];
    
    [[UISearchBar appearance] setSearchFieldBackgroundImage:[[UIImage imageNamed:@"skuang"] stretchableImageWithLeftCapWidth:3 topCapHeight:0] forState:UIControlStateNormal];
    
    //self.sinaweibo = [[SinaWeibo alloc] initWithAppKey:kAppKey appSecret:kAppSecret appRedirectURI:kAppRedirectURI andDelegate:_viewController];
    self.sinaweibo = [[SinaWeibo alloc] initWithAppKey:kAppKey appSecret:kAppSecret appRedirectURI:kAppRedirectURI andDelegate:nil];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *sinaweiboInfo = [defaults objectForKey:@"SinaWeiboAuthData"];
    if ([sinaweiboInfo objectForKey:@"AccessTokenKey"] && [sinaweiboInfo objectForKey:@"ExpirationDateKey"] && [sinaweiboInfo objectForKey:@"UserIDKey"])
    {
        self.sinaweibo.accessToken = [sinaweiboInfo objectForKey:@"AccessTokenKey"];
        self.sinaweibo.expirationDate = [sinaweiboInfo objectForKey:@"ExpirationDateKey"];
        self.sinaweibo.userID = [sinaweiboInfo objectForKey:@"UserIDKey"];
    }

    //weixin part
    [WXApi registerApp:@"wx9a0654e1d41f2482"];
    //[WXApi registerApp:@"wxd930ea5d5a258f4f"];
    
    return YES;
}

-(void) createAndCheckDatabase
{
    BOOL success;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    success = [fileManager fileExistsAtPath:self.databasePath];
    
    if(success){
        return;
    }
    
    NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:self.databaseName];
    [fileManager copyItemAtPath:databasePathFromApp toPath:self.databasePath error:nil];
    
    [self copySamplePlanImage];
}

-(void) copySamplePlanImage
{
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [documentPaths objectAtIndex:0];
    
    NSString *thailandPlanImgName = @"2planCover.png";
    NSString *thailandPlanImgResourcePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:thailandPlanImgName];
    NSString *thailandPlanImgPath = [documentDir stringByAppendingPathComponent:thailandPlanImgName];
    
    NSString *yunnanPlanImgName = @"1planCover.png";
    NSString *yunnanPlanImgResourcePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:yunnanPlanImgName];
    NSString *yunnanPlanImgPath = [documentDir stringByAppendingPathComponent:yunnanPlanImgName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager copyItemAtPath:thailandPlanImgResourcePath toPath:thailandPlanImgPath error:nil];
    [fileManager copyItemAtPath:yunnanPlanImgResourcePath toPath:yunnanPlanImgPath error:nil];
}

-(void) alterDB{
    sqlite3 *database;
    sqlite3_stmt *statement;
    if(sqlite3_open([self.databasePath UTF8String], &database) == SQLITE_OK)
    {
        
        NSString *updateSQL = [NSString stringWithFormat: @"ALTER TABLE location ADD COLUMN useradd INTEGER"];
        const char *update_stmt = [updateSQL UTF8String];
        sqlite3_prepare_v2(database, update_stmt, -1, &statement, NULL);
        
        if(sqlite3_step(statement)==SQLITE_DONE)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"DB altered" message:@"Success" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            alert=nil;
            
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"DB Updation" message:@"DB not Altered" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            alert=nil;
        }
        // Release the compiled statement from memory
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [self.sinaweibo applicationDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

//- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
//{
////    if ([[url scheme] isEqualToString:@"wx9a0654e1d41f2482"])
////    {
////        return [WXApi handleOpenURL:url delegate:self];
////    }
//    return NO;
//}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    if ([[url scheme] isEqualToString:@"sinaweibosso.3237810134"])
    {
        return [self.sinaweibo handleOpenURL:url];
    }
//    else if ([[url scheme] isEqualToString:@"tencent100379396"])
//    {
//        return [TencentOAuth HandleOpenURL:url];
//    }
    else if ([[url scheme] isEqualToString:@"wx9a0654e1d41f2482"])
    //else if ([[url scheme] isEqualToString:@"wxd930ea5d5a258f4f"])
    {
        return [WXApi handleOpenURL:url delegate:self];
    }
    return NO;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([[url scheme] isEqualToString:@"sinaweibosso.3237810134"])
    {
        return [self.sinaweibo handleOpenURL:url];
    }
//    else if ([[url scheme] isEqualToString:@"tencent100379396"])
//    {
//        return [TencentOAuth HandleOpenURL:url];
//    }
    else if ([[url scheme] isEqualToString:@"wx9a0654e1d41f2482"])
    //else if ([[url scheme] isEqualToString:@"wxd930ea5d5a258f4f"])
    {
        return [WXApi handleOpenURL:url delegate:self];
    }
    return NO;
}

//- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
//{
////    if ([[url scheme] isEqualToString:@"wx9a0654e1d41f2482"])
////    {
////        return [WXApi handleOpenURL:url delegate:self];
////    }
//    return NO;
//}

@end
