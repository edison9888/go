//
//  ShareViewController.h
//  Chufaba
//
//  Created by 张 辛欣 on 13-2-11.
//  Copyright (c) 2013年 ChufabaAPP团队. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ShareViewController;

@protocol ShareViewControllerDelegate <NSObject>
- (void)ShareViewController:(ShareViewController *)ShareViewController didConfirmShare:(NSString *)content;
- (void)ShareViewController:(ShareViewController *)ShareViewController didCancelShare:(NSString *)content;
- (void)ShareViewController:(ShareViewController *)ShareViewController doWeiboOauth:(NSString *)content;
@end

@interface ShareViewController : UIViewController <UITextViewDelegate>
{
    UILabel *label;
    UILabel *chooseService;
}

@property (nonatomic,weak) id<ShareViewControllerDelegate> delegate;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIButton *weiboBtn;

@end
