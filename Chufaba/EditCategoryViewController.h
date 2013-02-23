//
//  EditCategoryViewController.h
//  Chufaba
//
//  Created by Perry on 13-2-2.
//  Copyright (c) 2013年 ChufabaAPP团队. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationViewController.h"

@interface EditCategoryViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, copy) NSString *category;

@property (nonatomic,weak) id<EditLocationDelegate> delegate;

@property (nonatomic,strong) NSArray *categoryOptions;

@end
