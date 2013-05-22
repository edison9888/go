//
//  AddPlanViewController.h
//  出发吧
//
//  Created by kenzo on 13-1-16.
//  Copyright (c) 2013年 出发吧APP团队. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Utility.h" 
#import "SearchDestinationViewController.h"
@class Plan;

@class AddPlanViewController;
@class SearchDestinationViewController;

@protocol AddPlanViewControllerDelegate<NSObject>
@optional
-(void) addPlanViewController:(AddPlanViewController *) controller
                   didAddTravelPlan:(Plan *) plan;

-(void) addPlanViewController:(AddPlanViewController *)controller didEditTravelPlan:(Plan *)plan;

-(void) addPlanViewControllerDidCancel:(AddPlanViewController *) controller;

@end

@interface AddPlanViewController : UITableViewController <UIPickerViewDelegate, UITextFieldDelegate, UIPickerViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, SearchDestinationViewControllerDelegate>
{
    UIImage *defaultCover;
}

@property (weak, nonatomic) IBOutlet UITextField *destinationInput;
@property (weak, nonatomic) IBOutlet UITextField *nameInput;
@property (weak, nonatomic) IBOutlet UITextField *dateInput;
@property (weak, nonatomic) IBOutlet UITextField *durationInput;
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UILabel *coverImply;

@property (assign, nonatomic) BOOL coverChanged;

@property (nonatomic,weak) id<AddPlanViewControllerDelegate> delegate;
@property (nonatomic, strong) NSString *destination;

- (IBAction)done:(id)sender;
- (IBAction)cancel:(id)sender;
- (void) showSearch;

@property (strong, nonatomic) Plan *plan;
@property (nonatomic,strong) NSMutableArray *durationPick;

@property (nonatomic) UIImagePickerController *imgPickerController;
@property (nonatomic,strong) UIDatePicker *datePicker;
@property (nonatomic,strong) UIPickerView *durationPicker;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end
