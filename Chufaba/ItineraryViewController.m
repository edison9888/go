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
}
- (NSMutableArray *) getOneDimensionLocationList;
@end

@implementation ItineraryViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.dataController = [[ItineraryDataController alloc] init];
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
            [annotations addObject:[LocationAnnotation annotationForLocation:location]];
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
    int row;
    int section;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    oneDimensionLocationList = [self getOneDimensionLocationList];
    
    self.mapView = [[MKMapView alloc] init];

    self.tableView.frame = self.view.bounds;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableViewRecognizer = [self.tableView enableGestureTableViewWithDelegate:self];
    [self.view addSubview:self.tableView];

    self.mapView.frame = self.view.bounds;
    self.mapView.hidden = YES;
    self.mapView.delegate = self;
    
    self.annotations = [self mapAnnotations];
    self.mapView.showsUserLocation = YES;
    
    UIView* mapNavView = [[UIView alloc] initWithFrame:CGRectMake(230, 370, 80, 40)];
    mapNavView.backgroundColor = [UIColor colorWithRed:0.239 green:0.239 blue:0.239 alpha:0.5];
    mapNavView.tag = 21;
    
    UIButton *mapPreviousButton = [[UIButton alloc] initWithFrame:CGRectMake(0,0,40,40)];
    mapPreviousButton.tag = 22;
    [mapPreviousButton setImage:[UIImage imageNamed:@"previous.png"] forState:UIControlStateNormal];
    [mapPreviousButton addTarget:self action:@selector(previousMapLocation:) forControlEvents:UIControlEventTouchDown];
    
    UIButton *mapNextButton = [[UIButton alloc] initWithFrame:CGRectMake(40,0,40,40)];
    mapNextButton.tag = 23;
    [mapNextButton setImage:[UIImage imageNamed:@"next.png"] forState:UIControlStateNormal];
    [mapNextButton addTarget:self action:@selector(nextMapLocation:) forControlEvents:UIControlEventTouchDown];
    
    UIView* mapPositionView = [[UIView alloc] initWithFrame:CGRectMake(10, 370, 40, 40)];
    mapPositionView.backgroundColor = [UIColor colorWithRed:0.239 green:0.239 blue:0.239 alpha:0.5];
    mapPositionView.tag = 24;
    
    UIButton *positionButton = [[UIButton alloc] initWithFrame:CGRectMake(0,0,40,40)];
    [positionButton setImage:[UIImage imageNamed:@"position.png"] forState:UIControlStateNormal];
    [positionButton addTarget:self action:@selector(positionMe:) forControlEvents:UIControlEventTouchDown];
    
    [mapNavView addSubview:mapPreviousButton];
    [mapNavView addSubview:mapNextButton];
    [mapPositionView addSubview:positionButton];
    [self.mapView addSubview:mapNavView];
    [self.mapView addSubview:mapPositionView];
    //[self.mapView bringSubviewToFront:mapNavView];
    
    [self.view addSubview:self.mapView];
    
    
    //location manager part
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;    
    self.locationManager.delegate = self;
    self.curLocation = nil;
    [self.locationManager startUpdatingLocation];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:MAP_BUTTON_TITLE style:UIBarButtonItemStyleBordered target:self action:@selector(toggleMap)];
    
    
    //CGFloat width = self.view.frame.size.width;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(100,22,120,44)];
    [button setTitle:@"全部" forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor colorWithRed:0.239 green:0.239 blue:0.239 alpha:1]];
    //[button setBackgroundColor:[UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1]];
    button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [button addTarget:self action:@selector(selectClicked:) forControlEvents:UIControlEventTouchDown];
    self.navigationItem.titleView = button;
    
    //sync,edit,share menu part
    if (pullDownMenuView == nil) {
		PullDownMenuView *view = [[PullDownMenuView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
		view.delegate = self;
		[self.tableView addSubview:view];
		pullDownMenuView = view;
	}
}

- (IBAction)previousMapLocation:(id)sender
{
    [(UIButton *)[self.mapView viewWithTag:23] setEnabled:YES];
    LocationAnnotation *selectedAnnotation = [self.mapView.selectedAnnotations objectAtIndex:0];
    NSInteger indexOfCurSelected = [self.annotations indexOfObject:selectedAnnotation];
    
    Location *previousLocation;
    if(singleDayMode)
    {
        previousLocation = [[self.dataController.masterTravelDayList objectAtIndex:0] objectAtIndex:indexOfCurSelected-1];
    }
    else
    {
        previousLocation = [oneDimensionLocationList objectAtIndex:indexOfCurSelected-1];
    }
    CLLocationCoordinate2D selectedLocationCoordinate = CLLocationCoordinate2DMake([previousLocation.latitude doubleValue], [previousLocation.longitude doubleValue]);

    [self.mapView setCenterCoordinate:selectedLocationCoordinate animated:YES];
    [self.mapView selectAnnotation:[self.annotations objectAtIndex:indexOfCurSelected-1] animated:YES];
}

- (IBAction)nextMapLocation:(id)sender
{
    [(UIButton *)[self.mapView viewWithTag:22] setEnabled:YES];
    LocationAnnotation *selectedAnnotation = [self.mapView.selectedAnnotations objectAtIndex:0];
    NSInteger indexOfCurSelected = [self.annotations indexOfObject:selectedAnnotation];
    
    Location *nextLocation;
    if(singleDayMode)
    {
        nextLocation = [[self.dataController.masterTravelDayList objectAtIndex:0] objectAtIndex:indexOfCurSelected+1];
    }
    else
    {
        nextLocation = [oneDimensionLocationList objectAtIndex:indexOfCurSelected+1];
    }
    CLLocationCoordinate2D selectedLocationCoordinate = CLLocationCoordinate2DMake([nextLocation.latitude doubleValue], [nextLocation.longitude doubleValue]);
    [self.mapView setCenterCoordinate:selectedLocationCoordinate animated:YES];
    [self.mapView selectAnnotation:[self.annotations objectAtIndex:indexOfCurSelected+1] animated:YES];
}

- (IBAction)positionMe:(id)sender
{
    [self.mapView setCenterCoordinate:self.mapView.userLocation.coordinate animated:YES];
    [self.mapView selectAnnotation:self.mapView.userLocation animated:YES];
}

- (void)toggleMap
{
	if (self.mapView.isHidden)
    {
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
            CLLocationCoordinate2D customLoc2D_5 = CLLocationCoordinate2DMake([firstLocation.latitude doubleValue], [firstLocation.longitude doubleValue]);
            [self.mapView setCenterCoordinate:customLoc2D_5 animated:YES];
            MKCoordinateRegion region;
            region.center = customLoc2D_5;
            MKCoordinateSpan span;
            span.latitudeDelta = 0.4;
            span.longitudeDelta = 0.4;
            region.span=span;
            [self.mapView setRegion:region animated:TRUE];
            //self.annotations = [self mapAnnotations];
            [self.mapView selectAnnotation:[self.annotations objectAtIndex:0] animated:YES];
        }
        
        [UIView transitionWithView:self.view
                          duration:.8
                           options:UIViewAnimationOptionTransitionFlipFromRight
                        animations:^{ self.tableView.hidden = YES; self.mapView.hidden = NO; }
                        completion:NULL];
        
		self.navigationItem.rightBarButtonItem.title = LIST_BUTTON_TITLE;
	}
    else
    {
		self.tableView.contentInset = UIEdgeInsetsZero;
        
        [UIView transitionWithView:self.view
                          duration:.8
                           options:UIViewAnimationOptionTransitionFlipFromLeft
                        animations:^{ self.mapView.hidden = YES; self.tableView.hidden = NO; }
                        completion:NULL];
        
		self.navigationItem.rightBarButtonItem.title = MAP_BUTTON_TITLE;
	}
}

#pragma mark JTTableViewGestureMoveRowDelegate

- (BOOL)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer needsCreatePlaceholderForRowAtIndexPath:(NSIndexPath *)indexPath {
    self.grabbedObject = [[self.dataController.masterTravelDayList objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    [[self.dataController.masterTravelDayList objectAtIndex:indexPath.section] replaceObjectAtIndex:indexPath.row withObject:DUMMY_CELL];
    
    FMDatabase *db = [FMDatabase databaseWithPath:[Utility getDatabasePath]];
    [db open];
    [db executeUpdate:[NSString stringWithFormat:@"UPDATE location SET seqofday = seqofday-1 where seqofday > %d and whichday = %d",indexPath.row+1, indexPath.section+1]];
    [db close];
}

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer needsMoveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    id object = [[self.dataController.masterTravelDayList objectAtIndex:sourceIndexPath.section] objectAtIndex:sourceIndexPath.row];
    [[self.dataController.masterTravelDayList objectAtIndex:sourceIndexPath.section] removeObjectAtIndex:sourceIndexPath.row];
    [[self.dataController.masterTravelDayList objectAtIndex:destinationIndexPath.section] insertObject:object atIndex:destinationIndexPath.row];
    
//    FMDatabase *db = [FMDatabase databaseWithPath:[Utility getDatabasePath]];
//    [db open];
//    [db executeUpdate:[NSString stringWithFormat:@"UPDATE location SET seqofday = seqofday-1 where seqofday > %d and whichday = %d",sourceIndexPath.row+1, sourceIndexPath.section+1]];
//    [db executeUpdate:[NSString stringWithFormat:@"UPDATE location SET seqofday = seqofday+1 where seqofday >= %d and whichday = %d",destinationIndexPath.row, destinationIndexPath.section+1]];
//    [db close];
}

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer needsReplacePlaceholderForRowAtIndexPath:(NSIndexPath *)indexPath {
    [[self.dataController.masterTravelDayList objectAtIndex:indexPath.section] replaceObjectAtIndex:indexPath.row withObject:self.grabbedObject];
    
    Location *locationToMove = (Location *)self.grabbedObject;
    int idOfLocationToMove = [locationToMove.locationId intValue];
    FMDatabase *db = [FMDatabase databaseWithPath:[Utility getDatabasePath]];
    [db open];
    [db executeUpdate:[NSString stringWithFormat:@"UPDATE location SET seqofday = seqofday+1 where seqofday >= %d and whichday = %d",indexPath.row, indexPath.section+1]];
    [db executeUpdate:[NSString stringWithFormat:@"UPDATE location SET whichday = %d, seqofday = %d where id = %d",indexPath.section+1, indexPath.row+1, idOfLocationToMove]];
    [db close];
    
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
        MKPinAnnotationView *userLocationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"UserLocation"];
        userLocationView.pinColor = MKPinAnnotationColorGreen;
        userLocationView.canShowCallout = YES;
        return userLocationView;
        //return nil;  //return nil to use default blue dot view
    }
    
    MKAnnotationView *aView = [sender dequeueReusableAnnotationViewWithIdentifier:LOCATION_ANNOTATION_VIEWS];
    
	if (!aView) {
		aView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:LOCATION_ANNOTATION_VIEWS];
		aView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        aView.leftCalloutAccessoryView = [[UILabel alloc] initWithFrame:CGRectMake(0,0,30,30)];
        ((UILabel *)aView.leftCalloutAccessoryView).textAlignment = NSTextAlignmentCenter;
        ((UILabel *)aView.leftCalloutAccessoryView).textColor = [UIColor whiteColor];
        ((UILabel *)aView.leftCalloutAccessoryView).backgroundColor = [UIColor colorWithRed:0.239 green:0.239 blue:0.239 alpha:0.1];
		aView.canShowCallout = YES;
	}

    LocationAnnotation *locationAnnotation = (LocationAnnotation *)annotation;
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
        [(UIButton *)[self.mapView viewWithTag:22] setEnabled:NO];
    }
    else
    {
        [(UIButton *)[self.mapView viewWithTag:22] setEnabled:YES];
        [(UIButton *)[self.mapView viewWithTag:23] setEnabled:YES];
        
        NSInteger indexOfCurSelected = [self.annotations indexOfObject:selectedAnnotation];
        if(indexOfCurSelected == 0)
        {
            [(UIButton *)[self.mapView viewWithTag:22] setEnabled:NO];
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
    [self performSegueWithIdentifier:@"ShowLocationDetails" sender:control];
    //int tapIndex = [self.annotations indexOfObject:tappedAnnotation];
}

//- (void) mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
//{
//    [self.mapView selectAnnotation:[self.mapView.annotations objectAtIndex:0] animated:YES];
//}

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
	// Unselect the selected row if any
	NSIndexPath	*selection = [self.tableView indexPathForSelectedRow];
	if (selection)
		[self.tableView deselectRowAtIndexPath:selection animated:YES];
    
	[self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
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
        [arr addObject:[@"Day " stringByAppendingString:[NSString stringWithFormat:@"%d",i+1]]];
    }
    if(dropDown == nil) {
        //add the dark view part
        UIView *darkView = [[UIView alloc] initWithFrame:self.view.bounds];
        darkView.alpha = 0.5;
        darkView.backgroundColor = [UIColor blackColor];
        darkView.tag = 55;
        UITapGestureRecognizer *singleFingerTap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickDarkView:)];
        [darkView addGestureRecognizer:singleFingerTap];
        UIPanGestureRecognizer *panGesture =[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(clickDarkView:)];
        [darkView addGestureRecognizer:panGesture];
        [self.view addSubview:darkView];
        
        CGFloat f = ([self.dataController.itineraryDuration intValue]+1)*40;
        dropDown = [[NIDropDown alloc]showDropDown:sender :&f :arr];
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

//Implement PullDownMenuDelegate method
- (void) showEditTravelPlan:(PullDownMenuView *)view
{
    [self performSegueWithIdentifier:@"EditPlan" sender:nil];
}

- (void) showShareMenu:(PullDownMenuView *)view
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"分享到新浪微博", @"分享给微信好友", @"分享到微信朋友圈", nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showInView:self.view];
}

//Implement UIActionSheetDeleg
-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    //SinaWeibo *sinaweibo = [self sinaweibo];
    if(buttonIndex == 0)
    {        
        //BOOL sinaEnabled = [sinaweibo isAuthValid];
        ShareViewController *shareController = [[ShareViewController alloc] init];
        shareController.delegate = self;
        //shareController.socialServiceEnabled = [[NSArray alloc] initWithObjects:[NSNumber numberWithBool:sinaEnabled], nil];
        
        // Create the navigation controller and present it.
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

//Implement ShareViewController delegate
//- (void)ShareViewController:(ShareViewController *)ShareViewController didConfirmShare:(NSString *)content
//{
//    //postStatusText = nil;
//    //postStatusText = [[NSString alloc] initWithFormat:@"test post status haha: %@", [NSDate date]];
//    SinaWeibo *sinaweibo = [self sinaweibo];
//    [sinaweibo requestWithURL:@"statuses/update.json"
//                       params:[NSMutableDictionary dictionaryWithObjectsAndKeys:content, @"status", nil]
//                   httpMethod:@"POST"
//                     delegate:self];
//    
//    [self dismissViewControllerAnimated:YES completion: nil];
//    self.tableView.contentInset = UIEdgeInsetsZero;
//}
//
//- (void)ShareViewController:(ShareViewController *)ShareViewController didCancelShare:(NSString *)content
//{
//    [self dismissViewControllerAnimated:YES completion: nil];
//    self.tableView.contentInset = UIEdgeInsetsZero;
//}
//
//- (void)ShareViewController:(ShareViewController *)ShareViewController doWeiboOauth:(NSString *)content
//{
//    SinaWeibo *sinaweibo = [self sinaweibo];
//    if([sinaweibo isAuthValid])
//    {
//        [sinaweibo logOut];
//        //ShareViewController.navigationItem.rightBarButtonItem = nil;
//    }
//    else
//    {
//        userInfo = nil;
//        statuses = nil;
//        [sinaweibo logIn];
//        //ShareViewController.navigationItem.rightBarButtonItem = ShareViewController.confirmBtnBackup;
//    }
//}

//Implement AddPlanViewControllerDelegate
- (void)addPlanViewControllerDidCancel:(AddPlanViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addPlanViewController:(AddPlanViewController *)controller didEditTravelPlan:(Plan *)plan
{
    FMDBDataAccess *dba = [[FMDBDataAccess alloc] init];
    [dba updateTravelPlan:plan];
    
    FMDatabase *db = [FMDatabase databaseWithPath:[Utility getDatabasePath]];
    [db open];
    
    if([plan.date compare: self.dataController.date] == NSOrderedSame)
    {
        int offset = [self.dataController.itineraryDuration intValue] - [plan.duration intValue];
        if([plan.duration intValue] < [self.dataController.itineraryDuration intValue])
        {
            [self.dataController.masterTravelDayList removeObjectsInRange:NSMakeRange([plan.duration intValue], offset)];
            //delete days which are deleted by changing start date.
            [db executeUpdate:@"DELETE FROM location WHERE whichday > ? AND plan_id = ?", plan.duration,plan.planId];
        }
        else
        {
            for(int i=0; i < offset*(-1); i++)
            {
                NSMutableArray *dayList = [[NSMutableArray alloc] init];
                [self.dataController.masterTravelDayList addObject:dayList];
            }
        }
    }
    else if([plan.date compare: self.dataController.date] == NSOrderedDescending)
    {
        NSInteger daysBetween = [Utility daysBetweenDate:self.dataController.date andDate:plan.date];
        if(daysBetween >= [self.dataController.itineraryDuration intValue])
        {
            [self.dataController.masterTravelDayList removeAllObjects];
            //delete all days
            [db executeUpdate:@"DELETE FROM location WHERE plan_id = ?", plan.planId];
            for(int i=0; i < [plan.duration intValue]; i++)
            {
                NSMutableArray *dayList = [[NSMutableArray alloc] init];
                [self.dataController.masterTravelDayList addObject:dayList];
            }
        }
        else
        {
            [self.dataController.masterTravelDayList removeObjectsInRange:NSMakeRange(0, daysBetween)];
            [db executeUpdate:@"DELETE FROM location WHERE whichday <= ? AND plan_id = ?", [NSNumber numberWithInt:daysBetween],plan.planId];
            int offset = daysBetween + [plan.duration intValue] - [self.dataController.itineraryDuration intValue];
            if(daysBetween + [plan.duration intValue] >= [self.dataController.itineraryDuration intValue])
            {
                [db executeUpdate:@"UPDATE location SET whichday = whichday-? WHERE whichday > ? AND plan_id = ?", [NSNumber numberWithInt:daysBetween],[NSNumber numberWithInt:daysBetween],plan.planId];
                for(int i=0; i < offset; i++)
                {
                    NSMutableArray *dayList = [[NSMutableArray alloc] init];
                    [self.dataController.masterTravelDayList addObject:dayList];
                }
            }
            else
            {
                [db executeUpdate:@"DELETE FROM location WHERE whichday > ? AND plan_id = ?", [NSNumber numberWithInt:[self.dataController.itineraryDuration intValue]-offset*(-1)],plan.planId];
                for(int i=0; i < offset*(-1); i++)
                {
                    [self.dataController.masterTravelDayList removeLastObject];
                }
            }
        }
    }
    else
    {
        NSInteger daysBetween = [Utility daysBetweenDate:plan.date andDate:self.dataController.date];
        if(daysBetween >= [plan.duration intValue])
        {
            [self.dataController.masterTravelDayList removeAllObjects];
            [db executeUpdate:@"DELETE FROM location WHERE plan_id = ?", plan.planId];
            for(int i=0; i < [plan.duration intValue]; i++)
            {
                NSMutableArray *dayList = [[NSMutableArray alloc] init];
                [self.dataController.masterTravelDayList addObject:dayList];
            }
        }
        else
        {
            [db executeUpdate:@"UPDATE location SET whichday = whichday+? WHERE plan_id = ?", [NSNumber numberWithInt:daysBetween],plan.planId];
            for(int i=0; i < daysBetween; i++)
            {
                NSMutableArray *dayList = [[NSMutableArray alloc] init];
                [self.dataController.masterTravelDayList insertObject:dayList atIndex:0];
            }
            int offset = [plan.duration intValue] - [self.dataController.itineraryDuration intValue] - daysBetween;
            if(daysBetween + [self.dataController.itineraryDuration intValue] <= [plan.duration intValue])
            {
                for(int i=0; i < offset; i++)
                {
                    NSMutableArray *dayList = [[NSMutableArray alloc] init];
                    [self.dataController.masterTravelDayList addObject:dayList];
                }
            }
            else
            {
                [db executeUpdate:@"DELETE FROM location WHERE whichday > ? AND plan_id = ?", plan.duration,plan.planId];
                for(int i=0; i < offset*(-1); i++)
                {
                    [self.dataController.masterTravelDayList removeLastObject];
                }
            }
        }
    }
    
    self.plan.name = plan.name;
    self.plan.date = plan.date;
    self.plan.duration = plan.duration;
    self.plan.image = plan.image;
    self.itineraryListBackup = [self.dataController.masterTravelDayList mutableCopy];
    oneDimensionLocationList = [self getOneDimensionLocationList];
    
    self.dataController.date = plan.date;
    self.dataController.itineraryDuration = plan.duration;
    [self.delegate travelPlanDidChange:self];
    [self.tableView reloadData];
    [self dismissViewControllerAnimated:YES completion:nil];
}

//DropDownDelegate
- (void) niDropDownDelegateMethod: (NIDropDown *) sender selectRow:(NSInteger)rowIndex
{
    dropDown = nil;
    self.tableView.contentInset = UIEdgeInsetsZero;
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
    
    if([self hasOneLocation])
    {
        Location *firstLocation = [[self.dataController.masterTravelDayList objectAtIndex:0] objectAtIndex:0];
        CLLocationCoordinate2D customLoc2D_5 = CLLocationCoordinate2DMake([firstLocation.latitude doubleValue], [firstLocation.longitude doubleValue]);
        [self.mapView setCenterCoordinate:customLoc2D_5 animated:YES];
        MKCoordinateRegion region;
        region.center = customLoc2D_5;
        MKCoordinateSpan span;
        span.latitudeDelta = 0.4;
        span.longitudeDelta = 0.4;
        region.span=span;
        [self.mapView setRegion:region animated:TRUE];
        [self.mapView selectAnnotation:[self.annotations objectAtIndex:0] animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) didAddLocation:(Location *) location
{
    if(singleDayMode){
        [[self.dataController objectInListAtIndex:0] addObject:location];
    }
    else{
        [[self.dataController objectInListAtIndex:[self.dayToAdd intValue]-1] addObject:location];
    }
    
    //NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.seqToAdd intValue] inSection:[self.dayToAdd intValue]];
    //[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView reloadData];
    
    //add search location to database
    FMDatabase *db = [FMDatabase databaseWithPath:[Utility getDatabasePath]];
    [db open];
    //[db executeUpdate:@"INSERT INTO location (plan_id,whichday,seqofday,name,address,category) VALUES (?,?,?,?,?,?);",self.plan.planId,self.dayToAdd,self.seqToAdd,locationToAdd.name,locationToAdd.address,locationToAdd.category];
    [db executeUpdate:@"INSERT INTO location (plan_id,whichday,seqofday,name,address,category,latitude,longitude) VALUES (?,?,?,?,?,?,?,?);",self.plan.planId,self.dayToAdd,self.seqToAdd,location.name,location.address,location.category,location.latitude,location.longitude];
    [db close];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    lastLatitude = location.latitude;
    lastLongitude = location.longitude;
}

-(void) didChangeLocation:(Location *)location
{
    [[self.dataController objectInListAtIndex:[self.tableView indexPathForSelectedRow].section] replaceObjectAtIndex:[self.tableView indexPathForSelectedRow].row withObject:location];
    [self.tableView reloadData];
    
    FMDatabase *db = [FMDatabase databaseWithPath:[Utility getDatabasePath]];
    [db open];
    //[db executeUpdate:@"INSERT INTO location (plan_id,whichday,seqofday,name,address,category) VALUES (?,?,?,?,?,?);",self.plan.planId,self.dayToAdd,self.seqToAdd,locationToAdd.name,locationToAdd.address,locationToAdd.category];
    [db executeUpdate:@"UPDATE location set transportation = ?, cost = ?, currency = ?, visit_begin = ?, visit_end = ?, detail = ?, category = ? WHERE id = ?", location.transportation, location.cost, location.currency, location.visitBegin, location.visitEnd, location.detail, location.category, location.locationId];
    [db close];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.dataController countOfList];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //[self setReorderingEnabled:([[self.dataController objectInListAtIndex:section] count] > 1 )];
    return [[self.dataController objectInListAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TravelLocationCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    //Location *locationAtIndex = [[self.dataController objectInListAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    NSObject *object = [[self.dataController objectInListAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    if ([object isEqual:DUMMY_CELL])
    {
        cell.textLabel.text = @"";
    }
    else
    {
        Location *locationAtIndex = (Location *)object;
        [[cell textLabel] setText:locationAtIndex.name];
        if (locationAtIndex.visitBegin || locationAtIndex.visitEnd) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateStyle:NSDateFormatterNoStyle];
            [formatter setTimeStyle:NSDateFormatterShortStyle];
            [[cell detailTextLabel] setText:[NSString stringWithFormat:@"%@ - %@", [formatter stringFromDate:locationAtIndex.visitBegin] ?: @"", [formatter stringFromDate:locationAtIndex.visitEnd] ?: @""]];
        }
        [[cell imageView] setImage:[Location getCategoryIcon:locationAtIndex.category]];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSInteger dayValue = singleDayMode ? [self.daySelected intValue]-1 : section;
    NSString *myString = @"Day ";
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dayComponents = [gregorian components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:self.dataController.date];
    NSInteger theDay = [dayComponents day];
    NSInteger theMonth = [dayComponents month];
    NSInteger theYear = [dayComponents year];
    
    // now build a NSDate object for yourDate using these components
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:theDay];
    [components setMonth:theMonth];
    [components setYear:theYear];
    NSDate *thisDate = [gregorian dateFromComponents:components];
    
    // now build a NSDate object for the next day
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setDay:dayValue];
    NSDate *sectionDate = [gregorian dateByAddingComponents:offsetComponents toDate:thisDate options:0];
    
    NSString *dateOfDay = [dateFormatter stringFromDate:sectionDate];
    //return [[myString stringByAppendingString:[NSString stringWithFormat:@"%d", section+1]] stringByAppendingString:dateOfDay];
    
    //Headerview
    UIView *myView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 50.0)];
    //HeaderLabel
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 10.0, 250.0, 30.0)] ;
    label.textColor = [UIColor whiteColor];
    label.shadowColor = [UIColor whiteColor];
    label.shadowOffset = CGSizeMake(0, 1);
    label.font = [UIFont boldSystemFontOfSize:18];
    label.backgroundColor = [UIColor clearColor];
    
    //AddParameterButton
    UIButton *button = [UIButton buttonWithType:UIButtonTypeContactAdd];
    [button setFrame:CGRectMake(275.0, 10.0, 30.0, 30.0)];
    button.tag = dayValue;
    button.hidden = NO;
    [button setBackgroundColor:[UIColor clearColor]];
    [button addTarget:self action:@selector(pushSearchLocationViewController:) forControlEvents:UIControlEventTouchDown];
    
    label.text = [[myString stringByAppendingString:[NSString stringWithFormat:@"%d", dayValue+1]] stringByAppendingString:dateOfDay];
    myView.backgroundColor = [UIColor orangeColor];
    
//    CALayer *bottomBorder = [CALayer layer];
//    bottomBorder.frame = CGRectMake(0.0, 50.0, 320.0, 1.0);
//    bottomBorder.backgroundColor = [UIColor whiteColor].CGColor;
//    [myView.layer addSublayer:bottomBorder];
    
    [myView addSubview:label];
    [myView addSubview:button];
    [myView bringSubviewToFront:button];
    return myView;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    dropDown = nil;
    self.tableView.contentInset = UIEdgeInsetsZero;
    if ([[segue identifier] isEqualToString:@"ShowLocationDetails"]) {
        LocationViewController *detailViewController = [segue destinationViewController];
        if (self.mapView.isHidden)
        {
            detailViewController.location = [[self.dataController objectInListAtIndex:[self.tableView indexPathForSelectedRow].section] objectAtIndex:[self.tableView indexPathForSelectedRow].row];
            detailViewController.delegate = self;
        }
        else
        {
            NSIndexPath *indexPath = [self indexPathForTappedAnnotation];
            detailViewController.location = [[self.dataController objectInListAtIndex:indexPath.section] objectAtIndex:indexPath.row];
            
        }
        detailViewController.locationIndex = [NSNumber numberWithInt:[oneDimensionLocationList indexOfObject:detailViewController.location]];
        detailViewController.totalLocationCount = [NSNumber numberWithInt:[oneDimensionLocationList count]];
        detailViewController.navDelegate = self;
    }
    else if ([[segue identifier] isEqualToString:@"SearchLocation"])
    {
        UIButton *button = (UIButton*)sender;
        self.dayToAdd = [NSNumber numberWithInt:button.tag+1];
        if(singleDayMode){
            self.seqToAdd = [NSNumber numberWithInt:[[self.dataController objectInListAtIndex:0] count]+1];
        }
        else{
            self.seqToAdd = [NSNumber numberWithInt:[[self.dataController objectInListAtIndex:button.tag] count]+1];
        }
        SearchLocationViewController *searchLocationViewController = segue.destinationViewController;
        searchLocationViewController.delegate = self;
        if(lastLatitude){
            searchLocationViewController.lastLatitude = lastLatitude;
        }
        if(lastLongitude){
            searchLocationViewController.lastLongitude = lastLongitude;
        }
    }
    else if ([[segue identifier] isEqualToString:@"EditPlan"])
    {
        UINavigationController *navigationController = segue.destinationViewController;
        AddPlanViewController *addPlanViewController = [[navigationController viewControllers] objectAtIndex:0];
        addPlanViewController.navigationItem.title = @"编辑旅行计划";
        addPlanViewController.delegate = self;
        addPlanViewController.plan = [[Plan alloc] initWithName:self.plan.name duration:self.plan.duration date:self.plan.date image:self.plan.image];
        addPlanViewController.plan.planId = self.plan.planId;
        //addPlanViewController.plan = self.plan;
    }
}

- (IBAction)pushSearchLocationViewController:(id)sender
{
    [self performSegueWithIdentifier:@"SearchLocation" sender:sender];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Location *locationToDelete = [[self.dataController objectInListAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        [[self.dataController objectInListAtIndex:indexPath.section] removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        //delete travel location in database
        FMDatabase *db = [FMDatabase databaseWithPath:[Utility getDatabasePath]];
        [db open];
        [db executeUpdate:@"DELETE FROM location WHERE id = ?", locationToDelete.locationId];
        [db close];
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
//    Location *locationToMove = [[self.dataController objectInListAtIndex:fromIndexPath.section] objectAtIndex:fromIndexPath.row];
//    [[self.dataController objectInListAtIndex:fromIndexPath.section] removeObjectAtIndex:fromIndexPath.row];
//    [[self.dataController objectInListAtIndex:toIndexPath.section] insertObject:locationToMove atIndex:toIndexPath.row];
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


#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	
	[pullDownMenuView pdmScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	[pullDownMenuView pdmScrollViewDidEndDragging:scrollView];
	
}

@end
