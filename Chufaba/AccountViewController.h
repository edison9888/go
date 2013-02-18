//
//  AccountViewController.h
//  Chufaba
//
//  Created by 张 辛欣 on 13-2-13.
//  Copyright (c) 2013年 ChufabaAPP团队. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SinaWeibo.h"
#import "SinaWeiboRequest.h"

@interface AccountViewController : UITableViewController <SinaWeiboDelegate, SinaWeiboRequestDelegate,UIActionSheetDelegate>
{
    NSDictionary *userInfo;
}

@property (weak, nonatomic) SinaWeibo *sinaweibo;
@property (weak, nonatomic) IBOutlet UILabel *isSinaBinding;

@end
