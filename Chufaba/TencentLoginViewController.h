//
//  TencentLoginViewController.h
//  Chufaba
//
//  Created by 张辛欣 on 13-6-16.
//  Copyright (c) 2013年 ChufabaAPP团队. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TencentLoginView.h"

@interface TencentLoginViewController : UIViewController

@property (nonatomic, strong) TencentLoginView* loginView;

- (void)initWithTencentLoginView:(TencentLoginView *)view;

@end
