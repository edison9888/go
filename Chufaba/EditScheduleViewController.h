//
//  EditScheduleViewController.h
//  Chufaba
//
//  Created by Perry on 13-2-2.
//  Copyright (c) 2013年 ChufabaAPP团队. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationViewController.h"
#import "Location.h"

@interface EditScheduleViewController : UITableViewController<UIPickerViewDelegate, UITextFieldDelegate>

@property (nonatomic, copy) NSString *start;

@property (nonatomic,weak) id<EditLocationDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITextField *startInput;

@property (nonatomic,strong) UIDatePicker *datePicker;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end