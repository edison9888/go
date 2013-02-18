//
//  AccountViewController.h
//  Chufaba
//
//  Created by 张 辛欣 on 13-2-13.
//  Copyright (c) 2013年 ChufabaAPP团队. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SocialAccountManager.h"

@interface AccountViewController : UITableViewController <UIActionSheetDelegate, SocialAccountManagerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *isSinaBinding;
@property (strong, nonatomic) SocialAccountManager *accountManager;

@end
