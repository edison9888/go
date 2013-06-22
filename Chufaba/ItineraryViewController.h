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

#import "JTTransformableTableViewCell.h"
#import "JTTableViewGestureRecognizer.h"
#import "UIColor+JTGestureBasedTableViewHelper.h"

//#import "ShareViewController.h"
//#import "LoginViewController.h"

#import "ItineraryViewTableViewCell.h"
#import "MapViewController.h"


@class ItineraryDataController;

@protocol ItineraryViewControllerDelegate<NSObject>
-(void) didAddLocationToPlan;
-(void) didDeleteLocationFromPlan;
@end

@interface ItineraryViewController:SwipeableViewController <JTTableViewGestureMoveRowDelegate, UITableViewDataSource, UITableViewDelegate, AddLocationDelegate, NavigateLocationDelegate, NIDropDownDelegate,CLLocationManagerDelegate, SearchViewControllerDelegate, PullDownMenuDelegate, MapViewControllerDelegate>
{
    NIDropDown *dropDown;
    PullDownMenuView *pullDownMenuView;
    BOOL singleDayMode;
    NSMutableArray *oneDimensionLocationList;
    BOOL loginForShare;
}

- (NSInteger) oneDimensionCountOfIndexPath:(NSIndexPath *)indexPath;

//JTGesture code
@property (nonatomic, strong) JTTableViewGestureRecognizer *tableViewRecognizer;
@property (nonatomic, strong) id grabbedObject;

@property (nonatomic,weak) IBOutlet UITableView *tableView;

//@property (weak, nonatomic) IBOutlet UINavigationItem *itineraryNavItem;
@property (nonatomic,strong) Plan *plan;
@property (strong, nonatomic) ItineraryDataController *dataController;
@property (strong, nonatomic) NSMutableArray *itineraryListBackup;
@property (nonatomic,weak) NSNumber *daySelected;
@property (nonatomic,weak) NSNumber *dayToAdd;
@property (nonatomic,weak) NSNumber *seqToAdd;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSCalendar *gregorian;

@property (nonatomic, strong) NSDictionary *categoryImage;

@property (nonatomic,weak) id<ItineraryViewControllerDelegate> itineraryDelegate;

@property (nonatomic,strong) NSIndexPath *indexPathOfLocationToDelete;

//@property (strong, nonatomic) SocialAccountManager *accountManager;

@end
