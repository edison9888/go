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

@interface PlanViewController : SwipeableTableViewController <AddPlanViewControllerDelegate, UIActionSheetDelegate,ItineraryViewControllerDelegate>

@property (nonatomic,strong) NSMutableArray *travelPlans;

@property (nonatomic,strong) NSIndexPath *indexPathOfplanToEditOrDelete;

-(void) populateTravelPlans;

@end
