//
//  itineraryAppDelegate.h
//  出发吧
//
//  Created by kenzo on 13-1-16.
//  Copyright (c) 2013年 出发吧APP团队. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChufabaAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) NSString *databaseName;
@property (nonatomic, strong) NSString *databasePath;

- (void) createAndCheckDatabase;

@end
