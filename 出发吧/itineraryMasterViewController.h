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
#import "NIDropDown.h"
#import "PullDownMenuView.h"
@class itineraryDataController;

@interface itineraryMasterViewController : ATSDragToReorderTableViewController<SearchLocationViewControllerDelegate, NIDropDownDelegate>
{
    NIDropDown *dropDown;
    PullDownMenuView *pullDownMenuView;
    BOOL singleDayMode;
}
@property (weak, nonatomic) IBOutlet UINavigationItem *itineraryNavItem;

@property (nonatomic,weak) NSNumber *planID;
@property (strong, nonatomic) itineraryDataController *dataController;
@property (strong, nonatomic) NSMutableArray *itineraryListBackup;
@property (nonatomic,weak) NSNumber *itineraryDuration;
@property (nonatomic,weak) NSNumber *daySelected;
@property (nonatomic,weak) NSNumber *dayToAdd;
@property (nonatomic,weak) NSNumber *seqToAdd;

@end
