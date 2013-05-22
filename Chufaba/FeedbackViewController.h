//
//  FeedbackViewController.h
//  Chufaba
//
//  Created by 张辛欣 on 13-4-11.
//  Copyright (c) 2013年 ChufabaAPP团队. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIPlaceHolderTextView.h"

@interface FeedbackViewController : UIViewController

//@property (weak, nonatomic) IBOutlet UITextView *feedbackTextView;
//@property (weak, nonatomic) IBOutlet UITextField *emailTextField;

@property (strong, nonatomic) UIPlaceHolderTextView *feedbackTextView;
@property (strong, nonatomic) UITextField *emailTextField;

@end
