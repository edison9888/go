//
//  ShareViewController.h
//  Chufaba
//
//  Created by 张 辛欣 on 13-2-11.
//  Copyright (c) 2013年 ChufabaAPP团队. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SinaWeibo.h"
#import "SinaWeiboRequest.h"

@class ShareViewController;

@protocol ShareViewControllerDelegate <NSObject>
//- (void)ShareViewController:(ShareViewController *)ShareViewController didConfirmShare:(NSString *)content;
//- (void)ShareViewController:(ShareViewController *)ShareViewController didCancelShare:(NSString *)content;
//- (void)ShareViewController:(ShareViewController *)ShareViewController doWeiboOauth:(NSString *)content;
@end

@interface ShareViewController : UIViewController <UITextViewDelegate, SinaWeiboDelegate, SinaWeiboRequestDelegate>
{
    UILabel *label;
    //sina weibo part
    NSDictionary *userInfo;
    NSArray *statuses;
    NSString *postStatusText;
    NSString *postImageStatusText;
    BOOL sinaEnabled;
}

@property (nonatomic,weak) id<ShareViewControllerDelegate> delegate;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIButton *weiboBtn;
@property (nonatomic, strong) UIBarButtonItem *confirmBtnBackup;
//@property (nonatomic, strong) NSNumber *sinaEnabled;

@end
