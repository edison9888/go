//
//  EditScheduleViewController.h
//  Chufaba
//
//  Created by Perry on 13-2-2.
//  Copyright (c) 2013年 ChufabaAPP团队. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationViewController.h"

@interface EditScheduleViewController : UITableViewController<UIPickerViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *startInput;
@property (weak, nonatomic) IBOutlet UITextField *endInput;

@property (nonatomic, copy) NSDate *start;
@property (nonatomic, copy) NSDate *end;

@property (nonatomic,weak) id<EditLocationDelegate> delegate;

@end
