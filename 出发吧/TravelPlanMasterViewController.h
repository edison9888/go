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

@interface TravelPlanMasterViewController : ATSDragToReorderTableViewController<AddPlanViewControllerDelegate, itineraryMasterViewDelegate>

@property (nonatomic,strong) NSMutableArray *travelPlans;

-(void) populateTravelPlans;

@end
