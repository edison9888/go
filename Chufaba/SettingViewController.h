//
//  SettingViewController.h
//  Chufaba
//
//  Created by 张 辛欣 on 13-2-13.
//  Copyright (c) 2013年 ChufabaAPP团队. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SocialAccountManager.h"

//@interface SettingViewController : UITableViewController <SocialAccountManagerDelegate, UIActionSheetDelegate>
@interface SettingViewController : UITableViewController

//@property (strong, nonatomic) SocialAccountManager *accountManager;

//@property (weak, nonatomic) IBOutlet UITableViewCell *loginCell;
//@property (weak, nonatomic) IBOutlet UILabel *userName;
//@property (weak, nonatomic) IBOutlet UILabel *userEmail;
//@property (weak, nonatomic) IBOutlet UITableViewCell *logoutCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *guideCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *reviewCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *feedbackCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *aboutCell;

- (IBAction)saveSetting:(id)sender;

@end
