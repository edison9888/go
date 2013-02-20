//
//  ShareViewController.h
//  Chufaba
//
//  Created by 张 辛欣 on 13-2-11.
//  Copyright (c) 2013年 ChufabaAPP团队. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SocialAccountManager.h"

@interface ShareViewController : UIViewController <UITextViewDelegate, SocialAccountManagerDelegate>
{
    UILabel *label;
    BOOL sinaEnabled;
}

@property (strong, nonatomic) SocialAccountManager *accountManager;
//@property (nonatomic,weak) id<SocialAccountManagerDelegate> delegate;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIButton *weiboBtn;
@property (nonatomic, strong) UIBarButtonItem *confirmBtnBackup;

@end
