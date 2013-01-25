//
//  AddPlanViewController.h
//  出发吧
//
//  Created by kenzo on 13-1-16.
//  Copyright (c) 2013年 出发吧APP团队. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Utility.h" 
@class TravelPlan;

@class AddPlanViewController;

@protocol AddPlanViewControllerDelegate<NSObject>

-(void) addPlanViewController:(AddPlanViewController *) controller
                   didAddTravelPlan:(TravelPlan *) plan;

-(void) addPlanViewController:(AddPlanViewController *)controller didEditTravelPlan:(TravelPlan *)plan;

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

@property (strong, nonatomic) TravelPlan *plan;
@property (nonatomic,strong) NSArray *durationPick;

@property (nonatomic) UIImagePickerController *imgPickerController;

@end
