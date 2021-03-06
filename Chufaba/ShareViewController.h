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
    BOOL tencentEnabled;
    BOOL shareBtnEnabled;
}

@property (strong, nonatomic) SocialAccountManager *accountManager;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIButton *weiboBtn;
@property (nonatomic, strong) UIButton *tWeiboBtn;
@property (nonatomic, strong) UIBarButtonItem *confirmBtnBackup;

@end
