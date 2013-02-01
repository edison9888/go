//
//  itineraryBudgetViewController.h
//  出发吧
//
//  Created by Perry on 13-1-29.
//  Copyright (c) 2013年 出发吧APP团队. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "itineraryDetailViewController.h"

@interface itineraryCostViewController : UITableViewController <UIPickerViewDelegate, UITextFieldDelegate, UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet UITextField *amountInput;
@property (weak, nonatomic) IBOutlet UITextField *currencyInput;

@property (nonatomic, copy) NSNumber *amount;
@property (nonatomic, copy) NSString *currency;

@property (nonatomic,weak) id<locationEditDelegate> delegate;

@property (nonatomic,strong) NSArray *currencyOptions;


@end
