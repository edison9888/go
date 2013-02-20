//
//  SettingViewController.h
//  Chufaba
//
//  Created by 张 辛欣 on 13-2-13.
//  Copyright (c) 2013年 ChufabaAPP团队. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SocialAccountManager.h"

@interface SettingViewController : UITableViewController <SocialAccountManagerDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) SocialAccountManager *accountManager;

@property (weak, nonatomic) IBOutlet UITableViewCell *loginCell;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *userEmail;
@property (weak, nonatomic) IBOutlet UITableViewCell *logoutCell;

- (IBAction)saveSetting:(id)sender;

@end
