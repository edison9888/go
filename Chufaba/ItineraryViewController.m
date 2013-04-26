//
//  itineraryMasterViewController.m
//  出发吧
//
//  Created by kenzo on 13-1-16.
//  Copyright (c) 2013年 出发吧APP团队. All rights reserved.
//

#import "ItineraryViewController.h"
#import "Utility.h"
#import "LocationViewController.h"
#import "Location.h"
#import "ItineraryDataController.h"
#import "SearchLocationViewController.h"
#import "LocationAnnotation.h"
#import "ShareViewController.h"

@interface ItineraryViewController () {
    NSNumber *lastLatitude;
    NSNumber *lastLongitude;
    BOOL isEmptyItinerary;
}
- (NSMutableArray *)getOneDimensionLocationList;

- (void)setEmptyItinerary;
@end

@implementation ItineraryViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.dataController = [[ItineraryDataController alloc] init];
}

- (NSDateFormatter *)dateFormatter {
    if (! _dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = @"YYYY-MM-d EEEE";
        NSLocale *cnLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
        _dateFormatter.locale = cnLocale;
    }
    return _dateFormatter;
}

- (NSCalendar *)gregorian {
    if (! _gregorian) {
        _gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    }
    return _gregorian;
}

- (void)setEmptyItinerary
{
    isEmptyItinerary = TRUE;
    for (NSMutableArray *array in self.dataController.masterTravelDayList)
    {
        if([array count] > 0)
        {
            isEmptyItinerary = FALSE;
            break;
        }
    }
}

- (void)reloadDataController
{
    FMDatabase *db = [FMDatabase databaseWithPath:[Utility getDatabasePath]];
    
    [db open];
    
    NSNumber *planID = self.plan.planId;
    FMResultSet *results = [db executeQuery:@"SELECT * FROM location,plan WHERE plan_id=? AND plan_id=plan.id AND whichday=? order by seqofday",planID, self.dayToAdd];

    NSMutableArray *array = [[NSMutableArray alloc] init];
    while([results next])
    {
        Location *location = [[Location alloc] init];
        location.locationId = [NSNumber numberWithInt:[results intForColumnIndex:0]];
        location.whichday = [NSNumber numberWithInt:[results intForColumn:@"whichday"]];
        location.seqofday = [NSNumber numberWithInt:[results intForColumn:@"seqofday"]];
        location.name = [results stringForColumn:@"name"];
        location.nameEn = [results stringForColumn:@"name_en"];
        location.country = [results stringForColumn:@"country"];
        location.city = [results stringForColumn:@"city"];
        location.address = [results stringForColumn:@"address"];
        location.transportation = [results stringForColumn:@"transportation"];
        location.cost = [NSNumber numberWithInt:[results intForColumn:@"cost"]];
        location.currency = [results stringForColumn:@"currency"];
        location.visitBegin = [results stringForColumn:@"visit_begin"];
        location.detail = [results stringForColumn:@"detail"];
        location.category = [results stringForColumn:@"category"];
        location.latitude = [NSNumber numberWithDouble:[results doubleForColumn:@"latitude"]];
        location.longitude = [NSNumber numberWithDouble:[results doubleForColumn:@"longitude"]];
        location.useradd = [results boolForColumn:@"useradd"];
        location.poiId = [NSNumber numberWithInt:[results intForColumn:@"poi_id"]];
        location.opening = [results stringForColumn:@"opening"];
        location.fee = [results stringForColumn:@"fee"];
        location.website = [results stringForColumn:@"website"];
        [array addObject:location];
    }
    if(singleDayMode)
    {
        [self.dataController.masterTravelDayList replaceObjectAtIndex:0 withObject:array];
        [self.itineraryListBackup replaceObjectAtIndex:[self.dayToAdd intValue]-1 withObject:array];
    }
    else
    {
        [self.dataController.masterTravelDayList replaceObjectAtIndex:[self.dayToAdd intValue]-1 withObject:array];
        [self.itineraryListBackup replaceObjectAtIndex:[self.dayToAdd intValue]-1 withObject:array];
    }
    
    [db close];
    
    oneDimensionLocationList = [self getOneDimensionLocationList];
    self.annotations = [self mapAnnotations];
    [self.itineraryDelegate didAddLocationToPlan];
}

- (NSMutableArray *) getOneDimensionLocationList
{
    NSMutableArray *locationList = [[NSMutableArray alloc] init];
    for(int i=0;i<[self.itineraryListBackup count];i++)
    {
        for (Location *location in [self.itineraryListBackup objectAtIndex:i]) {
            [locationList addObject:location];
        }
    }
    return locationList;
}

#define MAP_BUTTON_TITLE @"地图"
#define LIST_BUTTON_TITLE @"列表"

#define ADDING_CELL @"Continue..."
#define DONE_CELL @"Done"
#define DUMMY_CELL @"Dummy"
#define COMMITING_CREATE_CELL_HEIGHT 60
#define NORMAL_CELL_FINISHING_HEIGHT 60
#define DAY_FILTER_FONT_SIZE 20
#define TAG_DAY_FILTER_ARROW 1
#define TAG_IMPLY_IMAGE 10000
#define TAG_IMPLY_LABEL 10001

#pragma mark - Synchronize Model and View
- (void)updateMapView
{
    if (self.mapView.annotations) [self.mapView removeAnnotations:self.mapView.annotations];
    if (self.annotations) [self.mapView addAnnotations:self.annotations];
}

- (void)setMapView:(MKMapView *)mapView
{
    _mapView = mapView;
    [self updateMapView];
}

- (void)setAnnotations:(NSArray *)annotations
{
    _annotations = annotations;
    [self updateMapView];
}

- (NSArray *)mapAnnotations
{
    //NSMutableArray *annotations = [NSMutableArray arrayWithCapacity:[self.photos count]];
    NSMutableArray *annotations = [[NSMutableArray alloc] init];
    for(int i=0;i<[self.dataController.masterTravelDayList count];i++)
    {
        for (Location *location in [self.dataController.masterTravelDayList objectAtIndex:i]) {
            if([location hasCoordinate])
            {
                [annotations addObject:[LocationAnnotation annotationForLocation:location ShowTitle:YES]];
            }
        }
    }
    return annotations;
}

- (BOOL) hasOneLocation
{
    BOOL flag = FALSE;
    if(singleDayMode)
    {
        if([[self.dataController.masterTravelDayList objectAtIndex:0] count])
        {
            flag = TRUE;
        }    
    }
    else
    {
        for(int i=0;i<[self.dataController.masterTravelDayList count];i++)
        {
            if([[self.dataController.masterTravelDayList objectAtIndex:i] count])
            {
                flag = TRUE;
            }       
        }
    }
    return flag;
}

- (NSIndexPath *) indexPathForTappedAnnotation
{
    int row = 0;
    int section = 0;
    if(singleDayMode)
    {
        section = 0;
        row = [self.annotations indexOfObject:tappedAnnotation];
    }
    else
    {
        int annotationCount = [self.annotations indexOfObject:tappedAnnotation]+1;
        for(int i=0;i<[self.dataController.masterTravelDayList count];i++)
        {
            annotationCount = annotationCount-[[self.dataController.masterTravelDayList objectAtIndex:i] count];
            if(annotationCount<=0)
            {
                section = i;
                row = annotationCount + [[self.dataController.masterTravelDayList objectAtIndex:i] count] - 1;
                break;
            }
        }
    }
    return [NSIndexPath indexPathForRow:row inSection:section];
}

- (NSIndexPath *) indexPathForLocationIndex:(int)locationIndex
{
    int row = 0;
    int section = 0;
    return [NSIndexPath indexPathForRow:row inSection:section];
}

- (NSInteger) oneDimensionCountOfIndexPath:(NSIndexPath *)indexPath
{
    int count = 0;
    for(int i=0;i<indexPath.section;i++)
    {
        count += [self.tableView numberOfRowsInSection:i];
    }
    count = count+ indexPath.row;
    return count;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setEmptyItinerary];
    self.categoryImage = [NSDictionary dictionaryWithObjectsAndKeys:@"sight40", @"景点", @"food40", @"美食", @"hotel40", @"住宿", @"more40", @"其它", @"pin_sight", @"景点m", @"pin_food", @"美食m", @"pin_hotel", @"住宿m", @"pin_more", @"其它m", nil];
    
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 7, 40, 30)];
    [backBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backToPrevious:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = btn;
    
    self.tableView.backgroundColor = [UIColor colorWithRed:244/255.0 green:241/255.0 blue:235/255.0 alpha:1.0];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    if(isEmptyItinerary)
    {
        self.tableView.rowHeight = 80.0f;
    }
    else
    {
        self.tableView.rowHeight = 44.0f;
    }
    self.tableView.sectionHeaderHeight = 44.0f;
    
    oneDimensionLocationList = [self getOneDimensionLocationList];

    self.tableView.frame = self.view.bounds;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableViewRecognizer = [self.tableView enableGestureTableViewWithDelegate:self];
    
    UIView *pullView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, -80.0f, self.view.frame.size.width, 60)];
    UIImageView *pullImgView = [[UIImageView alloc] initWithFrame:CGRectMake(124, 20, 72, 40)];
    pullImgView.image = [UIImage imageNamed:@"pull_bg"];
    [pullView addSubview:pullImgView];
    [self.tableView addSubview:pullView];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 1)];
    headerView.backgroundColor = [UIColor colorWithRed:227/255.0 green:219/255.0 blue:204/255.0 alpha:1.0];
    self.tableView.tableHeaderView = headerView;
    
    [self.view addSubview:self.tableView];
    
    UIButton *modeBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 7, 40, 30)];
    [modeBtn setImage:[UIImage imageNamed:@"map"] forState:UIControlStateNormal];
    [modeBtn addTarget:self action:@selector(toggleMap) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithCustomView:modeBtn];
    self.navigationItem.rightBarButtonItem = rightBtn;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(100,0,120,30)];
    [button setBackgroundColor:[UIColor clearColor]];
    [button setTitle:@"全部" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithRed:196/255.0 green:230/255.0 blue:184/255.0 alpha:1.0] forState:UIControlStateNormal];
    [button setTitleShadowColor:[UIColor colorWithWhite:0.0 alpha:0.5] forState:UIControlStateNormal];
    button.titleLabel.shadowOffset = CGSizeMake(0, 1.0);
    button.titleLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:DAY_FILTER_FONT_SIZE];
    [button addTarget:self action:@selector(selectClicked:) forControlEvents:UIControlEventTouchDown];
    
    CGSize stringsize = [button.titleLabel.text sizeWithFont:[UIFont systemFontOfSize:DAY_FILTER_FONT_SIZE]];
    UIImageView *arrowView = [[UIImageView alloc] initWithFrame:CGRectMake(button.titleLabel.frame.origin.x + stringsize.width + 3, 12, 10, 6)];
    arrowView.image = [UIImage imageNamed:@"arrow"];
    arrowView.tag = TAG_DAY_FILTER_ARROW;
    [button addSubview:arrowView];
    self.navigationItem.titleView = button;
    
    NSInteger scrollSection = [self daySequence:[NSDate date]];
    if(scrollSection >= 0)
    {
        [self.tableView reloadData];
        if([self.tableView numberOfRowsInSection:scrollSection] > 0)
        {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:scrollSection] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }
        else
        {
            //[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:NSNotFound inSection:scrollSection] atScrollPosition:UITableViewScrollPositionTop animated:NO];
            CGRect sectionRect = [self.tableView rectForSection:scrollSection];
            sectionRect.origin.y = sectionRect.origin.y;
            sectionRect.size.height = self.tableView.frame.size.height;
            [self.tableView scrollRectToVisible:sectionRect animated:YES];
        }
    }
    
    if([[self.dataController.masterTravelDayList lastObject] count] > 0)
    {
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 1)];
        footerView.backgroundColor = [UIColor whiteColor];
        self.tableView.tableFooterView = footerView;
    }
    
    if(isEmptyItinerary)
    {
        UIImageView *implyImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"t"]];
        implyImage.frame = CGRectMake(205,42,94,58);
        implyImage.tag = TAG_IMPLY_IMAGE;
        [self.view addSubview:implyImage];
        [self.view bringSubviewToFront:implyImage];
        
        UILabel *implyLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 70, 220, 30)];
        implyLabel.tag = TAG_IMPLY_LABEL;
        implyLabel.backgroundColor = [UIColor clearColor];
        implyLabel.text = @"第一步总是让人兴奋不已!";
        implyLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:16];
        implyLabel.textColor = [UIColor colorWithRed:72/255.0 green:70/255.0 blue:66/255.0 alpha:1.0];
        [self.view addSubview:implyLabel];
    }
    
    //sync,edit,share menu part
//    if (pullDownMenuView == nil) {
//		PullDownMenuView *view = [[PullDownMenuView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
//		view.delegate = self;
//		[self.tableView addSubview:view];
//		pullDownMenuView = view;
//	}
}

- (IBAction)backToPrevious:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)previousMapLocation:(id)sender
{
    [(UIButton *)[self.mapView viewWithTag:23] setEnabled:YES];
    if([self.mapView.selectedAnnotations count] == 1)
    {
        LocationAnnotation *selectedAnnotation = [self.mapView.selectedAnnotations objectAtIndex:0];
        NSInteger indexOfCurSelected = [self.annotations indexOfObject:selectedAnnotation];
        
        Location *previousLocation;
        NSInteger curSelectedInAll;
        if(singleDayMode)
        {
            curSelectedInAll = [[self.dataController.masterTravelDayList objectAtIndex:0] indexOfObject:selectedAnnotation.location];
            for(int i=1; i<[[self.dataController.masterTravelDayList objectAtIndex:0] count]; i++)
            {
                previousLocation = [[self.dataController.masterTravelDayList objectAtIndex:0] objectAtIndex:curSelectedInAll-i];
                if(!([previousLocation.latitude doubleValue] == 0 && [previousLocation.longitude doubleValue] == 0))
                {
                    break;
                }
            }
        }
        else
        {
            curSelectedInAll = [oneDimensionLocationList indexOfObject:selectedAnnotation.location];
            for(int i=1; i<[oneDimensionLocationList count]; i++)
            {
                previousLocation = [oneDimensionLocationList objectAtIndex:curSelectedInAll-i];
                if(!([previousLocation.latitude doubleValue] == 0 && [previousLocation.longitude doubleValue] == 0))
                {
                    break;
                }
            }
        }
        CLLocationCoordinate2D selectedLocationCoordinate = CLLocationCoordinate2DMake([previousLocation.latitude doubleValue], [previousLocation.longitude doubleValue]);
        
        [self.mapView setCenterCoordinate:selectedLocationCoordinate animated:YES];
        [self.mapView selectAnnotation:[self.annotations objectAtIndex:indexOfCurSelected-1] animated:YES];
    }
}

- (IBAction)nextMapLocation:(id)sender
{
    [(UIButton *)[self.mapView viewWithTag:22] setEnabled:YES];
    if([self.mapView.selectedAnnotations count] == 1)
    {
        LocationAnnotation *selectedAnnotation = [self.mapView.selectedAnnotations objectAtIndex:0];
        NSInteger indexOfCurSelected = [self.annotations indexOfObject:selectedAnnotation];
        
        Location *nextLocation;
        NSInteger curSelectedInAll;
        if(singleDayMode)
        {
            curSelectedInAll = [[self.dataController.masterTravelDayList objectAtIndex:0] indexOfObject:selectedAnnotation.location];
            for(int i=1; i<[[self.dataController.masterTravelDayList objectAtIndex:0] count]; i++)
            {
                nextLocation = [[self.dataController.masterTravelDayList objectAtIndex:0] objectAtIndex:curSelectedInAll+i];
                if(!([nextLocation.latitude doubleValue] == 0 && [nextLocation.longitude doubleValue] == 0))
                {
                    break;
                } 
            }
        }
        else
        {
            curSelectedInAll = [oneDimensionLocationList indexOfObject:selectedAnnotation.location];
            for(int i=1; i<[oneDimensionLocationList count]; i++)
            {
                nextLocation = [oneDimensionLocationList objectAtIndex:curSelectedInAll+i];
                if(!([nextLocation.latitude doubleValue] == 0 && [nextLocation.longitude doubleValue] == 0))
                {
                    break;
                }
            }
        }
        CLLocationCoordinate2D selectedLocationCoordinate = CLLocationCoordinate2DMake([nextLocation.latitude doubleValue], [nextLocation.longitude doubleValue]);
        [self.mapView setCenterCoordinate:selectedLocationCoordinate animated:YES];
        [self.mapView selectAnnotation:[self.annotations objectAtIndex:indexOfCurSelected+1] animated:YES];
    }
}


- (IBAction)positionMe:(id)sender
{
    [self.mapView setCenterCoordinate:self.mapView.userLocation.coordinate animated:YES];
    [self.mapView selectAnnotation:self.mapView.userLocation animated:YES];
}

- (void)toggleMap
{
	if(!self.mapView)
    {
        self.mapView = [[MKMapView alloc] init];
        self.mapView.frame = self.view.bounds;
        self.mapView.hidden = YES;
        self.mapView.delegate = self;
        UIView* mapNavView = [[UIView alloc] initWithFrame:CGRectMake(230, self.mapView.frame.size.height-40, 80, 30)];
        mapNavView.backgroundColor = [UIColor clearColor];
        mapNavView.tag = 21;
        
        UIButton *mapPreviousButton = [[UIButton alloc] initWithFrame:CGRectMake(0,0,40,30)];
        mapPreviousButton.tag = 22;
        [mapPreviousButton setImage:[UIImage imageNamed:@"prevmap"] forState:UIControlStateNormal];
        [mapPreviousButton addTarget:self action:@selector(previousMapLocation:) forControlEvents:UIControlEventTouchDown];
        
        UIButton *mapNextButton = [[UIButton alloc] initWithFrame:CGRectMake(40,0,40,30)];
        mapNextButton.tag = 23;
        [mapNextButton setImage:[UIImage imageNamed:@"nextmap"] forState:UIControlStateNormal];
        [mapNextButton addTarget:self action:@selector(nextMapLocation:) forControlEvents:UIControlEventTouchDown];
        
        UIView* mapPositionView = [[UIView alloc] initWithFrame:CGRectMake(10, self.mapView.frame.size.height-40, 40, 30)];
        mapPositionView.backgroundColor = [UIColor clearColor];
        mapPositionView.tag = 24;
        
        UIButton *positionButton = [[UIButton alloc] initWithFrame:CGRectMake(0,0,40,30)];
        [positionButton setImage:[UIImage imageNamed:@"position"] forState:UIControlStateNormal];
        [positionButton addTarget:self action:@selector(positionMe:) forControlEvents:UIControlEventTouchDown];
        
        [mapNavView addSubview:mapPreviousButton];
        [mapNavView addSubview:mapNextButton];
        [mapPositionView addSubview:positionButton];
        [self.mapView addSubview:mapNavView];
        [self.mapView addSubview:mapPositionView];
        
        [self.view addSubview:self.mapView];
    }
    if (self.mapView.isHidden)
    {
        self.annotations = [self mapAnnotations];
        if(self.mapView.showsUserLocation == NO)
        {
            self.mapView.showsUserLocation = YES;
        }
        
        if(!self.locationManager)
        {
            self.locationManager = [[CLLocationManager alloc] init];
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            self.locationManager.delegate = self;
            self.curLocation = nil;
            [self.locationManager startUpdatingLocation];
        }
        
        if(dropDown)
        {
            [dropDown hideDropDownWithoutAnimation:(UIButton *)self.navigationItem.titleView];
            dropDown = nil;
            [[self.view viewWithTag:55] removeFromSuperview];
        }
        [(UIButton *)[self.mapView viewWithTag:22] setEnabled:NO];
        if([self hasOneLocation])
        {
            Location *firstLocation = [[self.dataController.masterTravelDayList objectAtIndex:0] objectAtIndex:0];
            if ([firstLocation hasCoordinate]) {
                CLLocationCoordinate2D customLoc2D_5 = CLLocationCoordinate2DMake([firstLocation.latitude doubleValue], [firstLocation.longitude doubleValue]);
                [self.mapView setCenterCoordinate:customLoc2D_5 animated:YES];
                
                MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(customLoc2D_5, 1500, 1500);
                MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:region];
                
                [self.mapView setRegion:adjustedRegion animated:TRUE];
                [self.mapView selectAnnotation:[self.annotations objectAtIndex:0] animated:YES];
            }
        }
        
        [UIView transitionWithView:self.view
                          duration:.8
                           options:UIViewAnimationOptionTransitionFlipFromRight
                        animations:^{ self.tableView.hidden = YES; self.mapView.hidden = NO; }
                        completion:NULL];
        
		//self.navigationItem.rightBarButtonItem.title = LIST_BUTTON_TITLE;
        UIButton *modeBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 7, 40, 30)];
        [modeBtn setImage:[UIImage imageNamed:@"list"] forState:UIControlStateNormal];
        [modeBtn addTarget:self action:@selector(toggleMap) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithCustomView:modeBtn];
        self.navigationItem.rightBarButtonItem = rightBtn;
	}
    else
    {
		self.tableView.contentInset = UIEdgeInsetsZero;
        
        [UIView transitionWithView:self.view
                          duration:.8
                           options:UIViewAnimationOptionTransitionFlipFromLeft
                        animations:^{ self.mapView.hidden = YES; self.tableView.hidden = NO; }
                        completion:NULL];
        
		//self.navigationItem.rightBarButtonItem.title = MAP_BUTTON_TITLE;
        
        UIButton *modeBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 7, 40, 30)];
        [modeBtn setImage:[UIImage imageNamed:@"map"] forState:UIControlStateNormal];
        [modeBtn addTarget:self action:@selector(toggleMap) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithCustomView:modeBtn];
        self.navigationItem.rightBarButtonItem = rightBtn;
	}
}

#pragma mark JTTableViewGestureMoveRowDelegate

- (BOOL)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer needsCreatePlaceholderForRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.grabbedObject = [[self.dataController.masterTravelDayList objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    [[self.dataController.masterTravelDayList objectAtIndex:indexPath.section] replaceObjectAtIndex:indexPath.row withObject:DUMMY_CELL];
}

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer needsMoveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    id object = [[self.dataController.masterTravelDayList objectAtIndex:sourceIndexPath.section] objectAtIndex:sourceIndexPath.row];
    [[self.dataController.masterTravelDayList objectAtIndex:sourceIndexPath.section] removeObjectAtIndex:sourceIndexPath.row];
    [[self.dataController.masterTravelDayList objectAtIndex:destinationIndexPath.section] insertObject:object atIndex:destinationIndexPath.row];
    
    Location *locationToMove = (Location *)self.grabbedObject;
    int idOfLocationToMove = [locationToMove.locationId intValue];
    
    for (NSObject *object in [self.dataController objectInListAtIndex:sourceIndexPath.section])
    {
        if ([object isEqual:DUMMY_CELL])
        {
            continue;
        }
        else
        {
            Location *location = (Location *)object;
            if([location.seqofday intValue] > [locationToMove.seqofday intValue])
            {
                location.seqofday = [NSNumber numberWithInt:[location.seqofday intValue] -1];
            }
        }
    }
    
    locationToMove.whichday = [NSNumber numberWithInt:destinationIndexPath.section+1];
    locationToMove.seqofday = [NSNumber numberWithInt:destinationIndexPath.row+1];
    
    for (NSObject *object in [self.dataController objectInListAtIndex:destinationIndexPath.section])
    {
        if ([object isEqual:DUMMY_CELL])
        {
            continue;
        }
        else
        {
            Location *location = (Location *)object;
            if([location.seqofday intValue] >= [locationToMove.seqofday intValue])
            {
                location.seqofday = [NSNumber numberWithInt:[location.seqofday intValue]+1];
            }
        }
    }
    
    FMDatabase *db = [FMDatabase databaseWithPath:[Utility getDatabasePath]];
    [db open];
    
    [db executeUpdate:[NSString stringWithFormat:@"UPDATE location SET seqofday = seqofday-1 where seqofday > %d and whichday = %d",sourceIndexPath.row+1, sourceIndexPath.section+1]];
    
    [db executeUpdate:[NSString stringWithFormat:@"UPDATE location SET whichday = %d, seqofday = %d where id = %d",sourceIndexPath.section+1, 0, idOfLocationToMove]];
    
    [db executeUpdate:[NSString stringWithFormat:@"UPDATE location SET seqofday = seqofday+1 where seqofday > %d and whichday = %d",destinationIndexPath.row, destinationIndexPath.section+1]];
    
    [db executeUpdate:[NSString stringWithFormat:@"UPDATE location SET whichday = %d, seqofday = %d where id = %d",destinationIndexPath.section+1, destinationIndexPath.row+1, idOfLocationToMove]];
    
    [db close];
}

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer needsReplacePlaceholderForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[self.dataController.masterTravelDayList objectAtIndex:indexPath.section] replaceObjectAtIndex:indexPath.row withObject:self.grabbedObject];
    ((Location *)[[self.dataController.masterTravelDayList objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]).whichday = [NSNumber numberWithInt:indexPath.section+1];
    
    self.itineraryListBackup = [self.dataController.masterTravelDayList mutableCopy];
    oneDimensionLocationList = [self getOneDimensionLocationList];
    
    self.grabbedObject = nil;
}

//Implement NavigationLocation delegate
-(Location *) getPreviousLocation:(Location *)curLocation;
{
    int index = [oneDimensionLocationList indexOfObject:curLocation];
    return [oneDimensionLocationList objectAtIndex:index-1];
}

-(Location *) getNextLocation:(Location *)curLocation
{
    int index = [oneDimensionLocationList indexOfObject:curLocation];
    return [oneDimensionLocationList objectAtIndex:index+1];
}

//Implement MKMapView delegate methods
#define LOCATION_ANNOTATION_VIEWS @"LocationAnnotationViews"

- (MKAnnotationView *)mapView:(MKMapView *)sender viewForAnnotation:(id <MKAnnotation>)annotation
{
	if ([annotation isKindOfClass:[MKUserLocation class]])
    {
        ((MKUserLocation *)annotation).title = @"我在这";
        return nil;
    }
    
    MKAnnotationView *aView = [sender dequeueReusableAnnotationViewWithIdentifier:LOCATION_ANNOTATION_VIEWS];
    
	if (!aView) {
        aView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:LOCATION_ANNOTATION_VIEWS];
        
		aView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        aView.leftCalloutAccessoryView = [[UILabel alloc] initWithFrame:CGRectMake(0,0,30,30)];
        UILabel *label = ((UILabel *)aView.leftCalloutAccessoryView);
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor colorWithRed:196/255.0 green:230/255.0 blue:184/255.0 alpha:1];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:16];
		aView.canShowCallout = YES;
	}

    LocationAnnotation *locationAnnotation = (LocationAnnotation *)annotation;
    aView.image = [UIImage imageNamed:[self.categoryImage objectForKey:[locationAnnotation.location.category stringByAppendingString:@"m"]]];
    NSUInteger index = [oneDimensionLocationList indexOfObject:locationAnnotation.location];
    ((UILabel *)aView.leftCalloutAccessoryView).text = [NSString stringWithFormat:@"%d", index+1];
	aView.annotation = annotation;
    
	return aView;
}

- (void)mapView:(MKMapView *)sender didSelectAnnotationView:(MKAnnotationView *)aView
{
    LocationAnnotation *selectedAnnotation = [self.mapView.selectedAnnotations objectAtIndex:0];
    if ([selectedAnnotation isKindOfClass:[MKUserLocation class]])
    {
        [(UIButton *)[self.mapView viewWithTag:22] setEnabled:NO];
        [(UIButton *)[self.mapView viewWithTag:23] setEnabled:NO];
    }
    else
    {
        [(UIButton *)[self.mapView viewWithTag:22] setEnabled:YES];
        [(UIButton *)[self.mapView viewWithTag:23] setEnabled:YES];
        
        NSInteger indexOfCurSelected = [self.annotations indexOfObject:selectedAnnotation];
        if(indexOfCurSelected == 0)
        {
            [(UIButton *)[self.mapView viewWithTag:22] setEnabled:NO];
            if([self.annotations count] == 1)
            {
                [(UIButton *)[self.mapView viewWithTag:23] setEnabled:NO];
            }
        }
        else if(indexOfCurSelected == [self.annotations count]-1)
        {
            [(UIButton *)[self.mapView viewWithTag:23] setEnabled:NO];
        }
    }
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    if([self.mapView.selectedAnnotations count] == 0)
    {
        [(UIButton *)[self.mapView viewWithTag:22] setEnabled:NO];
        [(UIButton *)[self.mapView viewWithTag:23] setEnabled:NO];
    }
}

- (void)mapView:(MKMapView *)sender annotationView:(MKAnnotationView *)aView calloutAccessoryControlTapped:(UIControl *)control
{
    tappedAnnotation = aView.annotation;
    
    LocationViewController *locationViewController = [[LocationViewController alloc] init];
    locationViewController.delegate = self;
    locationViewController.location = ((LocationAnnotation *)tappedAnnotation).location;
    locationViewController.locationIndex = [oneDimensionLocationList indexOfObject:locationViewController.location];
    locationViewController.totalLocationCount = [oneDimensionLocationList count];
    locationViewController.navDelegate = self;
    [self.navigationController pushViewController:locationViewController animated:YES];
}

//CLLocationManagerDelegate part
- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
//    CLLocationCoordinate2D customLoc2D_5 = CLLocationCoordinate2DMake(31.27006030476515, 120.70549774169922);
//    [self.mapView setCenterCoordinate:customLoc2D_5 animated:YES];
}


//Add 4 methods to make UIViewCtroller behave like UITableViewController
- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
	[super setEditing:editing animated:animated];
	[self.tableView setEditing:editing animated:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	//	The scrollbars won't flash unless the tableview is long enough.
	[self.tableView flashScrollIndicators];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[self.tableView flashScrollIndicators];
}

- (IBAction)selectClicked:(id)sender {
    NSMutableArray * arr = [[NSMutableArray alloc] init];
    [arr addObject:@"全部"];
    for(int i=0; i<[self.dataController.itineraryDuration intValue]; i++)
    {
        [arr addObject:[NSString stringWithFormat:@"第%d天", i+1]];
    }
    if(dropDown == nil) {
        //add the dark view part
        UIView *darkView = [[UIView alloc] initWithFrame:self.view.bounds];
        darkView.backgroundColor = [UIColor clearColor];
        darkView.tag = 55;
        UITapGestureRecognizer *singleFingerTap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickDarkView:)];
        [darkView addGestureRecognizer:singleFingerTap];
        UIPanGestureRecognizer *panGesture =[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(clickDarkView:)];
        [darkView addGestureRecognizer:panGesture];
        [self.view addSubview:darkView];
        
        CGFloat f = ([self.dataController.itineraryDuration intValue]+1)*40;
        dropDown = [[NIDropDown alloc] showDropDown:sender withHeight:&f withDays:arr];
        dropDown.delegate = self;
    }
    else {
        [dropDown hideDropDown:sender];
        dropDown = nil;
        [[self.view viewWithTag:55] removeFromSuperview];
        //[self.view viewWithTag:22] = nil;
    }
}

- (IBAction)clickDarkView:(id)sender
{
    [dropDown hideDropDownWithoutAnimation:(UIButton *)self.navigationItem.titleView];
    dropDown = nil;
    [[self.view viewWithTag:55] removeFromSuperview];
}

//Implement UIActionSheetDeleg
-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    self.tableView.contentInset = UIEdgeInsetsZero;
    if(buttonIndex == 0)
    {        
        ShareViewController *shareController = [[ShareViewController alloc] init];
        shareController.accountManager.delegate = shareController;
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:shareController];
        [self presentViewController:navigationController animated:YES completion: nil];
    }
    else if(buttonIndex == 1)
    {

    }
    else if(buttonIndex == 2)
    {

    }
}

//DropDownDelegate
- (void) niDropDownDelegateMethod: (NIDropDown *) sender selectRow:(NSInteger)rowIndex
{
    UIButton *dayFilterBtn = (UIButton *)self.navigationItem.titleView;
    CGSize stringsize = [dayFilterBtn.titleLabel.text sizeWithFont:[UIFont systemFontOfSize:DAY_FILTER_FONT_SIZE]];
    UIImageView *dayFilterImg = (UIImageView *)[dayFilterBtn viewWithTag:TAG_DAY_FILTER_ARROW];
    dayFilterImg.frame = CGRectMake(dayFilterBtn.titleLabel.frame.origin.x + stringsize.width + 3, dayFilterImg.frame.origin.y, dayFilterImg.frame.size.width, dayFilterImg.frame.size.height );
    dropDown = nil;
    //self.tableView.contentInset = UIEdgeInsetsZero;
    [[self.view viewWithTag:55] removeFromSuperview];
    self.daySelected = [NSNumber numberWithInt:rowIndex];
    if(rowIndex == 0){
        self.dataController.masterTravelDayList = self.itineraryListBackup;
        singleDayMode = false;
    }
    else{
        singleDayMode = true;
        NSMutableArray *dayList = [self.itineraryListBackup objectAtIndex:rowIndex-1];
        [self.dataController.masterTravelDayList removeAllObjects];
        [self.dataController.masterTravelDayList addObject:dayList];
    }
    [self.tableView reloadData];
    self.annotations = [self mapAnnotations];
    
    if(!self.mapView.isHidden && [self hasOneLocation])
    {
        Location *firstLocation = [[self.dataController.masterTravelDayList objectAtIndex:0] objectAtIndex:0];
        if ([firstLocation hasCoordinate]) {
            CLLocationCoordinate2D firstLocationCoordinate = CLLocationCoordinate2DMake([firstLocation.latitude doubleValue], [firstLocation.longitude doubleValue]);
            [self.mapView setCenterCoordinate:firstLocationCoordinate animated:YES];
            
            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(firstLocationCoordinate, 1500, 1500);
            MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:region];
            
            [self.mapView setRegion:adjustedRegion animated:TRUE];
            [self.mapView selectAnnotation:[self.annotations objectAtIndex:0] animated:YES];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void) didChangeLocation:(Location *)location
{
    [[self.dataController objectInListAtIndex:[location.whichday intValue]-1] replaceObjectAtIndex:[location.seqofday intValue]-1 withObject:location];
    [self.tableView reloadData];
    
    FMDatabase *db = [FMDatabase databaseWithPath:[Utility getDatabasePath]];
    [db open];
    [db executeUpdate:@"UPDATE location set name = ?, visit_begin = ?, detail = ?, latitude = ?, longitude = ? WHERE id = ?", location.name, location.visitBegin, location.detail, location.latitude, location.longitude, location.locationId];
    [db close];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.dataController countOfList];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(isEmptyItinerary && section == 0)
    {
        return  1;
    }
    return [[self.dataController objectInListAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(isEmptyItinerary && indexPath.section ==0 && indexPath.row == 0)
    {
        static NSString *CellIdentifier = @"EmptyCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        return cell;
    }
    else
    {
        static NSString *CellIdentifier = @"TravelLocationCell";
        
        ItineraryViewTableViewCell *cell = (ItineraryViewTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell)
        {
            cell = [[ItineraryViewTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        }
        
        NSObject *object = [[self.dataController objectInListAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        
        if ([object isEqual:DUMMY_CELL])
        {
            cell.textLabel.text = @"";
            cell.contentView.backgroundColor = [UIColor clearColor];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        else
        {
            Location *locationAtIndex = (Location *)object;
            
            cell.textLabel.text = locationAtIndex.name;
            if (locationAtIndex.visitBegin)
            {
                cell.detailTextLabel.text = locationAtIndex.visitBegin;
            }
            else
            {
                cell.detailTextLabel.text = @"";
            }
            cell.imageView.image = [UIImage imageNamed:[self.categoryImage objectForKey: locationAtIndex.category]];
        }
        //    cell.layer.opaque = YES;
        //    cell.layer.shouldRasterize = YES;
        //    cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
        return cell;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSInteger dayValue = singleDayMode ? [self.daySelected intValue]-1 : section;
    
    NSDateComponents *dayComponents = [self.gregorian components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:self.dataController.date];
    NSInteger theDay = [dayComponents day];
    NSInteger theMonth = [dayComponents month];
    NSInteger theYear = [dayComponents year];
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:theDay];
    [components setMonth:theMonth];
    [components setYear:theYear];
    NSDate *thisDate = [self.gregorian dateFromComponents:components];
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setDay:dayValue];
    NSDate *sectionDate = [self.gregorian dateByAddingComponents:offsetComponents toDate:thisDate options:0];
    
    //Headerview
    UIView *myView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)];
    
    //HeaderLabel
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 6.0, 250.0, 20.0)] ;
    label.textColor = [UIColor colorWithRed:72/255.0 green:70/255.0 blue:66/255.0 alpha:1.0];
    label.shadowColor = [UIColor whiteColor];
    label.shadowOffset = CGSizeMake(0, 1);
    label.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:16];
    label.backgroundColor = [UIColor clearColor];
    
    UILabel *wLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 24.0, 250.0, 20.0)] ;
    wLabel.textColor = [UIColor colorWithRed:153/255.0 green:150/255.0 blue:145/255.0 alpha:1.0];
    wLabel.shadowColor = [UIColor whiteColor];
    wLabel.shadowOffset = CGSizeMake(0, 1);
    wLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:12];
    wLabel.backgroundColor = [UIColor clearColor];
    wLabel.text = [self.dateFormatter stringFromDate:sectionDate];;
    
    //AddParameterButton
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(275.0, 7.0, 31.0, 31.0)];
    [button setImage:[UIImage imageNamed:@"addLocation"] forState:UIControlStateNormal];
    button.tag = dayValue;
    button.hidden = NO;
    //[button setBackgroundColor:[UIColor clearColor]];
    [button addTarget:self action:@selector(pushSearchViewController:) forControlEvents:UIControlEventTouchDown];
    
    label.text = [NSString stringWithFormat:@"第%d天", dayValue+1];
    myView.backgroundColor = [UIColor colorWithRed:223/255.0 green:215/255.0 blue:198/255.0 alpha:1.0];
    
    CAGradientLayer *viewShadow = [[CAGradientLayer alloc] init];
    CGRect viewShadowFrame = CGRectMake(0, 0, 320, myView.frame.size.height);
    viewShadow.frame = viewShadowFrame;
    viewShadow.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithRed:230/255.0 green:223/255.0 blue:209/255.0 alpha:1.0].CGColor,(id)[UIColor colorWithRed:227/255.0 green:219/255.0 blue:204/255.0 alpha:1.0].CGColor,nil];
    [myView.layer addSublayer:viewShadow];
    
    myView.layer.masksToBounds = NO;
    myView.layer.shadowOffset = CGSizeMake(0, 1);
    myView.layer.shadowRadius = 0.8;
    myView.layer.shadowColor = [[UIColor colorWithRed:189/255.0 green:176/255.0 blue:153/255.0 alpha:1.0] CGColor];
    myView.layer.shadowOpacity = 1;
    
    [myView addSubview:label];
    [myView addSubview:wLabel];
    [myView addSubview:button];
    //[myView bringSubviewToFront:button];
    return myView;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LocationViewController *locationViewController = [[LocationViewController alloc] init];
    locationViewController.delegate = self;
    locationViewController.location = [[self.dataController objectInListAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    locationViewController.locationIndex = [oneDimensionLocationList indexOfObject:locationViewController.location];
    locationViewController.totalLocationCount = [oneDimensionLocationList count];
    locationViewController.navDelegate = self;
    [self.navigationController pushViewController:locationViewController animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    dropDown = nil;
    self.tableView.contentInset = UIEdgeInsetsZero;
//    if ([[segue identifier] isEqualToString:@"SelectCategory"])
//    {
//        UIButton *button = (UIButton*)sender;
//        self.dayToAdd = [NSNumber numberWithInt:button.tag+1];
//        if(singleDayMode){
//            self.seqToAdd = [NSNumber numberWithInt:[[self.dataController objectInListAtIndex:0] count]+1];
//        }
//        else{
//            self.seqToAdd = [NSNumber numberWithInt:[[self.dataController objectInListAtIndex:button.tag] count]+1];
//        }
//        
//        SelectCategoryViewController *selectController = segue.destinationViewController;
//        selectController.delegate = self;
//        if(lastLatitude){
//            selectController.lastLatitude = lastLatitude;
//        }
//        if(lastLongitude){
//            selectController.lastLongitude = lastLongitude;
//        }
//    }
    
    if ([[segue identifier] isEqualToString:@"ShowSearch"])
    {
        UIButton *button = (UIButton*)sender;
        
        UINavigationController *navigationController = segue.destinationViewController;
        SearchViewController *searchController = [[navigationController viewControllers] objectAtIndex:0];
        [searchController setTitle:@"添加旅行地点"];
        
        searchController.searchDelegate = self;
        searchController.planId = self.plan.planId;
        searchController.dayToAdd = [NSNumber numberWithInt:button.tag+1];
        searchController.locationKeyword = self.plan.destination;
        self.dayToAdd = searchController.dayToAdd;
        
        NSMutableArray *array = [[NSMutableArray alloc] init];
        if(singleDayMode)
        {
            searchController.seqToAdd = [NSNumber numberWithInt:[[self.dataController objectInListAtIndex:0] count]+1];
            self.seqToAdd = searchController.seqToAdd;
            
            for (Location *location in [self.dataController objectInListAtIndex:0])
            {
                if(location.poiId)
                {
                    [array addObject:location.poiId];
                }
            }
        }
        else
        {
            searchController.seqToAdd = [NSNumber numberWithInt:[[self.dataController objectInListAtIndex:button.tag] count]+1];
            self.seqToAdd = searchController.seqToAdd;
            
            for (Location *location in [self.dataController objectInListAtIndex:[self.dayToAdd intValue]-1])
            {
                if(location.poiId)
                {
                    [array addObject:location.poiId];
                }
            }
        }
        searchController.poiArray = [array mutableCopy];
    }
//    else if ([[segue identifier] isEqualToString:@"EditPlan"])
//    {
//        UINavigationController *navigationController = segue.destinationViewController;
//        AddPlanViewController *addPlanViewController = [[navigationController viewControllers] objectAtIndex:0];
//        addPlanViewController.navigationItem.title = @"编辑旅行计划";
//        addPlanViewController.delegate = self;
//        addPlanViewController.plan = [[Plan alloc] initWithName:self.plan.name duration:self.plan.duration date:self.plan.date image:self.plan.image];
//        addPlanViewController.plan.planId = self.plan.planId;
//    }
}

- (IBAction)pushSearchViewController:(id)sender
{
    [self performSegueWithIdentifier:@"ShowSearch" sender:sender];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{

}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{

}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    [dropDown hideDropDownWithoutAnimation:(UIButton *)self.navigationItem.titleView];
    dropDown = nil;
}

//Implement SocialAccountManager delegate
-(void) socialAccountManager:(SocialAccountManager *) manager dismissLoginView:(BOOL) show
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) socialAccountManager:(SocialAccountManager *) manager openShareMenu:(NSInteger) loginType
{
    if(loginForShare)
    {
        self.tableView.contentInset = UIEdgeInsetsZero;
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"分享到社交网络", @"分享给微信好友", @"分享到微信朋友圈", nil];
        actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
        [actionSheet showInView:self.view];
    }
}

-(NSInteger) daySequence:(NSDate *) date
{
    if([date compare: self.plan.date] != NSOrderedAscending)
    {
        NSInteger daysBetween = [Utility daysBetweenDate:self.plan.date andDate:date];
        if(daysBetween < [self.plan.duration intValue])
        {
            return daysBetween;
        }
        else
        {
            return -1;
        }
    }
    else
    {
        return -1;
    }
    
}

//method to delete location
- (void)tableView:(UITableView *)tableView didSwipeCellAtIndexPath:(NSIndexPath *)indexPath
{
    self.indexPathOfLocationToDelete = indexPath;
}

- (void) deleteLocation
{
    NSInteger deleteIndex = [self oneDimensionCountOfIndexPath:self.indexPathOfLocationToDelete];
    Location *locationToDelete = [[self.dataController objectInListAtIndex:self.indexPathOfLocationToDelete.section] objectAtIndex:self.indexPathOfLocationToDelete.row];
    
    [[self.dataController objectInListAtIndex:self.indexPathOfLocationToDelete.section] removeObjectAtIndex:self.indexPathOfLocationToDelete.row];
    for (Location *location in [self.dataController objectInListAtIndex:self.indexPathOfLocationToDelete.section])
    {
        if([location.seqofday intValue] > [locationToDelete.seqofday intValue])
        {
            location.seqofday = [NSNumber numberWithInt:[location.seqofday intValue] -1];
        }
    }
    
    [self.tableView deleteRowsAtIndexPaths:@[self.indexPathOfLocationToDelete] withRowAnimation:UITableViewRowAnimationFade];
    [oneDimensionLocationList removeObjectAtIndex:deleteIndex];
    
    if([[self.dataController objectInListAtIndex:self.indexPathOfLocationToDelete.section] count] == 0 && [self.dataController.masterTravelDayList count]-1 == self.indexPathOfLocationToDelete.section)
    {
        self.tableView.tableFooterView = NULL;
    }
    
    //add this to resolve the issue that map annotations doesn't update
    //self.annotations = [self mapAnnotations];
    
    //delete travel location in database and update seqofday of the location after the deleted location
    FMDatabase *db = [FMDatabase databaseWithPath:[Utility getDatabasePath]];
    [db open];
    [db executeUpdate:@"DELETE FROM location WHERE id = ?", locationToDelete.locationId];
    [db executeUpdate:[NSString stringWithFormat:@"UPDATE location SET seqofday = seqofday-1 where seqofday > %d and whichday = %d",[locationToDelete.seqofday intValue], [locationToDelete.whichday intValue]]];
    [db close];
    [self.itineraryDelegate didDeleteLocationFromPlan];
}

//SearchViewControllerDelegate implementation
-(void) notifyItinerayToReload
{
    if([self.view viewWithTag:TAG_IMPLY_IMAGE])
    {
        [[self.view viewWithTag:TAG_IMPLY_IMAGE] removeFromSuperview];
        [[self.view viewWithTag:TAG_IMPLY_LABEL] removeFromSuperview];
        isEmptyItinerary = FALSE;
        self.tableView.rowHeight = 44.0f;
    }
    [self reloadDataController];
    [self.tableView reloadData];
}

@end
