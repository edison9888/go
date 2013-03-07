//
//  TravelPlanMasterViewController.h
//  出发吧
//
//  Created by kenzo on 13-1-16.
//  Copyright (c) 2013年 出发吧APP团队. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddPlanViewController.h"
#import "FMDBDataAccess.h" 
#import "ItineraryViewController.h"
#import "SwipeableTableViewCell.h"

@interface PlanViewController : SwipeableTableViewController <AddPlanViewControllerDelegate, ItineraryDelegate>

@property (nonatomic,strong) NSMutableArray *travelPlans;

- (IBAction)showLogin:(id)sender;

-(void) populateTravelPlans;

@end
