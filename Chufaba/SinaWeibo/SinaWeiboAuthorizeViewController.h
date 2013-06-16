//
//  SinaWeiboAuthorizeViewController.h
//  Chufaba
//
//  Created by 张辛欣 on 13-6-16.
//  Copyright (c) 2013年 ChufabaAPP团队. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SinaWeiboAuthorizeView.h"

@interface SinaWeiboAuthorizeViewController : UIViewController

@property (nonatomic, strong) SinaWeiboAuthorizeView* authorizeView;

- (void)initWithSinaAuthorizeView:(SinaWeiboAuthorizeView *)view;

@end
