//
//  itineraryMasterViewController.h
//  出发吧
//
//  Created by kenzo on 13-1-16.
//  Copyright (c) 2013年 出发吧APP团队. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMDBDataAccess.h" 
#import "SearchViewController.h"
#import "NIDropDown.h"
#import "PullDownMenuView.h"
#import "FMDBDataAccess.h" 
#import "LocationViewController.h"

//#import "ShareViewController.h"
//#import "LoginViewController.h"

#import "ItineraryViewTableViewCell.h"
#import "MapViewController.h"
#import "EditItineraryViewController.h"


@class ItineraryDataController;

@protocol ItineraryViewControllerDelegate<NSObject>
-(void) didAddLocationToPlan;
-(void) didDeleteLocationFromPlan;
@end

@interface ItineraryViewController:SwipeableViewController <UITableViewDataSource, UITableViewDelegate, AddLocationDelegate, NIDropDownDelegate, SearchViewControllerDelegate, PullDownMenuDelegate, MapViewControllerDelegate, EditItineraryViewControllerDelegate>
{
    NIDropDown *dropDown;
    PullDownMenuView *pullDownMenuView;
    BOOL singleDayMode;
    BOOL loginForShare;
}

@property (nonatomic,weak) IBOutlet UITableView *tableView;
@property (nonatomic,strong) Plan *plan;
@property (nonatomic,weak) NSNumber *daySelected;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSCalendar *gregorian;

@property (nonatomic, strong) NSDictionary *categoryImage;

@property (nonatomic,strong) NSIndexPath *indexPathOfLocationToDelete;

//@property (strong, nonatomic) SocialAccountManager *accountManager;

@end
