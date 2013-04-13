//
//  itineraryMasterViewController.h
//  出发吧
//
//  Created by kenzo on 13-1-16.
//  Copyright (c) 2013年 出发吧APP团队. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "FMDBDataAccess.h" 
//#import "SearchLocationViewController.h"
//#import "SelectCategoryViewController.h"
#import "SearchViewController.h"
#import "NIDropDown.h"
#import "PullDownMenuView.h"
//#import "AddPlanViewController.h"
#import "FMDBDataAccess.h" 
#import "LocationViewController.h"

#import "JTTransformableTableViewCell.h"
#import "JTTableViewGestureRecognizer.h"
#import "UIColor+JTGestureBasedTableViewHelper.h"

#import "ShareViewController.h"
#import "LoginViewController.h"

#import "ItineraryViewTableViewCell.h"


@class ItineraryDataController;

@protocol ItineraryViewControllerDelegate<NSObject>
-(void) didAddLocationToPlan;
-(void) didDeleteLocationFromPlan;
@end

//@interface ItineraryViewController:UIViewController <JTTableViewGestureMoveRowDelegate, UITableViewDataSource, UITableViewDelegate, AddLocationDelegate, NavigateLocationDelegate, NIDropDownDelegate,PullDownMenuDelegate,AddPlanViewControllerDelegate,MKMapViewDelegate,CLLocationManagerDelegate, UIActionSheetDelegate, SocialAccountManagerDelegate>
@interface ItineraryViewController:SwipeableViewController <JTTableViewGestureMoveRowDelegate, UITableViewDataSource, UITableViewDelegate, AddLocationDelegate, NavigateLocationDelegate, NIDropDownDelegate,MKMapViewDelegate,CLLocationManagerDelegate, UIActionSheetDelegate, SocialAccountManagerDelegate, SearchViewControllerDelegate>
{
    NIDropDown *dropDown;
    PullDownMenuView *pullDownMenuView;
    BOOL singleDayMode;
    id <MKAnnotation> tappedAnnotation;
    NSMutableArray *oneDimensionLocationList;
    
    BOOL loginForShare;
}

- (BOOL) hasOneLocation;
- (NSIndexPath *) indexPathForTappedAnnotation;
- (NSInteger) oneDimensionCountOfIndexPath:(NSIndexPath *)indexPath;

//JTGesture code
@property (nonatomic, strong) JTTableViewGestureRecognizer *tableViewRecognizer;
@property (nonatomic, strong) id grabbedObject;

@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) CLLocation *curLocation;

@property (nonatomic, strong) NSArray *annotations; // of id <MKAnnotation>

@property (nonatomic,strong) MKMapView *mapView;
@property (nonatomic,weak) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UINavigationItem *itineraryNavItem;
@property (nonatomic,strong) Plan *plan;
@property (strong, nonatomic) ItineraryDataController *dataController;
@property (strong, nonatomic) NSMutableArray *itineraryListBackup;
@property (nonatomic,weak) NSNumber *daySelected;
@property (nonatomic,weak) NSNumber *dayToAdd;
@property (nonatomic,weak) NSNumber *seqToAdd;

@property (nonatomic,weak) id<ItineraryViewControllerDelegate> itineraryDelegate;

@property (nonatomic,strong) NSIndexPath *indexPathOfLocationToDelete;

//@property (strong, nonatomic) SocialAccountManager *accountManager;

@end
