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

#import "JTTransformableTableViewCell.h"
#import "JTTableViewGestureRecognizer.h"
#import "UIColor+JTGestureBasedTableViewHelper.h"


@class ItineraryDataController;
@class ItineraryViewController;

@protocol ItineraryDelegate<NSObject>

-(void) travelPlanDidChange:(ItineraryViewController *) controller;

@end

@interface ItineraryViewController:UIViewController <JTTableViewGestureMoveRowDelegate, UITableViewDataSource, UITableViewDelegate, AddLocationDelegate, NavigateLocationDelegate, NIDropDownDelegate,PullDownMenuDelegate,AddPlanViewControllerDelegate,MKMapViewDelegate,CLLocationManagerDelegate>
{
    NIDropDown *dropDown;
    PullDownMenuView *pullDownMenuView;
    BOOL singleDayMode;
    id <MKAnnotation> tappedAnnotation;
    NSMutableArray *oneDimensionLocationList;
}

- (BOOL) hasOneLocation;
- (NSIndexPath *) indexPathForTappedAnnotation;

//JTGesture code
//@property (nonatomic, strong) NSMutableArray *rows;
@property (nonatomic, strong) JTTableViewGestureRecognizer *tableViewRecognizer;
@property (nonatomic, strong) id grabbedObject;

@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) CLLocation *curLocation;

@property (nonatomic,weak) id<ItineraryDelegate> delegate;
@property (nonatomic, strong) NSArray *annotations; // of id <MKAnnotation>

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
