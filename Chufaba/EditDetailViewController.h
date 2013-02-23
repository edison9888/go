//
//  EditDetailViewController.h
//  Chufaba
//
//  Created by Perry on 13-2-2.
//  Copyright (c) 2013年 ChufabaAPP团队. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationViewController.h"

@interface EditDetailViewController : UIViewController<UITextViewDelegate>

@property (nonatomic, copy) NSString *detail;

@property (nonatomic,weak) id<EditLocationDelegate> delegate;

@end
