//
//  AddPlanViewController.h
//  出发吧
//
//  Created by kenzo on 13-1-16.
//  Copyright (c) 2013年 出发吧APP团队. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TravelPlan;

@interface AddPlanViewController : UITableViewController <UIPickerViewDelegate, UITextFieldDelegate, UIPickerViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *dateInput;
@property (weak, nonatomic) IBOutlet UITextField *durationInput;
@property (weak, nonatomic) IBOutlet UITextField *nameInput;
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;

@property (strong, nonatomic) TravelPlan *plan;
@property (nonatomic,strong) NSArray *durationPick;

@property (nonatomic) UIImagePickerController *imgPickerController;

@end
