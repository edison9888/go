//
//  TravelPlanMasterViewController.h
//  出发吧
//
//  Created by kenzo on 13-1-16.
//  Copyright (c) 2013年 出发吧APP团队. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddPlanViewController.h"
#import "ATSDragToReorderTableViewController.h"
#import "FMDBDataAccess.h" 
#import "itineraryMasterViewController.h"

@class TravelPlanDataController;

@interface TravelPlanMasterViewController : ATSDragToReorderTableViewController<AddPlanViewControllerDelegate, itineraryMasterViewDelegate>

@property (strong, nonatomic) TravelPlanDataController *dataController;
@property (nonatomic,strong) NSMutableArray *travelPlans;

//- (IBAction)done:(UIStoryboardSegue *)segue;
//- (IBAction)cancel:(UIStoryboardSegue *)segue;

-(void) populateTravelPlans;

@end
