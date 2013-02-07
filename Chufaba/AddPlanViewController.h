//
//  AddPlanViewController.h
//  出发吧
//
//  Created by kenzo on 13-1-16.
//  Copyright (c) 2013年 出发吧APP团队. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Utility.h" 
@class Plan;

@class AddPlanViewController;

@protocol AddPlanViewControllerDelegate<NSObject>
@optional
-(void) addPlanViewController:(AddPlanViewController *) controller
                   didAddTravelPlan:(Plan *) plan;

-(void) addPlanViewController:(AddPlanViewController *)controller didEditTravelPlan:(Plan *)plan;

-(void) addPlanViewControllerDidCancel:(AddPlanViewController *) controller;

@end

@interface AddPlanViewController : UITableViewController <UIPickerViewDelegate, UITextFieldDelegate, UIPickerViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *dateInput;
@property (weak, nonatomic) IBOutlet UITextField *durationInput;
@property (weak, nonatomic) IBOutlet UITextField *nameInput;
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;

@property (nonatomic,weak) id<AddPlanViewControllerDelegate> delegate;

- (IBAction)done:(id)sender;
- (IBAction)cancel:(id)sender;

@property (strong, nonatomic) Plan *plan;
@property (nonatomic,strong) NSMutableArray *durationPick;

@property (nonatomic) UIImagePickerController *imgPickerController;

@end
