//
//  itineraryMasterViewController.h
//  出发吧
//
//  Created by kenzo on 13-1-16.
//  Copyright (c) 2013年 出发吧APP团队. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "ATSDragToReorderTableViewController.h"
#import "FMDBDataAccess.h" 
#import "SearchLocationViewController.h"
#import "NIDropDown.h"
#import "PullDownMenuView.h"
#import "AddPlanViewController.h"
#import "FMDBDataAccess.h" 
#import "LocationViewController.h"


@class ItineraryDataController;
@class ItineraryViewController;

@protocol ItineraryDelegate<NSObject>

-(void) travelPlanDidChange:(ItineraryViewController *) controller;

@end

@interface ItineraryViewController:UIViewController <UITableViewDataSource, UITableViewDelegate, AddLocationDelegate, NIDropDownDelegate,PullDownMenuDelegate,AddPlanViewControllerDelegate,MKMapViewDelegate>
{
    NIDropDown *dropDown;
    PullDownMenuView *pullDownMenuView;
    BOOL singleDayMode;
}

@property (nonatomic,weak) id<ItineraryDelegate> delegate;

@property (nonatomic,weak) IBOutlet MKMapView *mapView;
@property (nonatomic,weak) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UINavigationItem *itineraryNavItem;
@property (nonatomic,strong) Plan *plan;
@property (strong, nonatomic) ItineraryDataController *dataController;
@property (strong, nonatomic) NSMutableArray *itineraryListBackup;
@property (nonatomic,weak) NSNumber *daySelected;
@property (nonatomic,weak) NSNumber *dayToAdd;
@property (nonatomic,weak) NSNumber *seqToAdd;

@end