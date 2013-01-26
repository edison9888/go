//
//  itineraryMasterViewController.h
//  出发吧
//
//  Created by kenzo on 13-1-16.
//  Copyright (c) 2013年 出发吧APP团队. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATSDragToReorderTableViewController.h"
#import "FMDBDataAccess.h" 
#import "SearchLocationViewController.h"
@class itineraryDataController;

@interface itineraryMasterViewController : ATSDragToReorderTableViewController<SearchLocationViewControllerDelegate>

@property (nonatomic,weak) NSNumber *planID;
@property (strong, nonatomic) itineraryDataController *dataController;
@property (nonatomic,weak) NSNumber *dayToAdd;
@property (nonatomic,weak) NSNumber *seqToAdd;
//- (IBAction)cancel:(UIStoryboardSegue *)segue;

@end
