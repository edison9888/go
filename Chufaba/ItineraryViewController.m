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

/*
@interface itineraryMasterViewController () {
    NSMutableArray *_objects;
}
@end
*/

@implementation ItineraryViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.dataController = [[ItineraryDataController alloc] init];
}

#define MAP_BUTTON_TITLE @"地图"
#define LIST_BUTTON_TITLE @"列表"

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.mapView = [[MKMapView alloc] init];

    self.tableView.frame = self.view.bounds;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];

    self.mapView.frame = self.view.bounds;
    self.mapView.hidden = YES;
    self.mapView.delegate = self;
    self.annotations = [self mapAnnotations];
    self.mapView.showsUserLocation = YES;
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

- (void)toggleMap
{
	if (self.mapView.isHidden)
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
        
        [UIView transitionWithView:self.view
                          duration:.8
                           options:UIViewAnimationOptionTransitionFlipFromRight
                        animations:^{ self.tableView.hidden = YES; self.mapView.hidden = NO; }
                        completion:NULL];
        
        [self.mapView selectAnnotation:[self.mapView.annotations objectAtIndex:0] animated:YES];
        
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

//Implement MKMapView delegate methods
#define LOCATION_ANNOTATION_VIEWS @"LocationAnnotationViews"

- (MKAnnotationView *)mapView:(MKMapView *)sender viewForAnnotation:(id <MKAnnotation>)annotation
{
	MKAnnotationView *aView = [sender dequeueReusableAnnotationViewWithIdentifier:LOCATION_ANNOTATION_VIEWS];
    
	if (!aView) {
		aView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:LOCATION_ANNOTATION_VIEWS];
		aView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
		//aView.leftCalloutAccessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,30,30)];
        aView.leftCalloutAccessoryView = [[UILabel alloc] initWithFrame:CGRectMake(0,0,30,30)];
        NSUInteger index = [self.annotations indexOfObject:annotation];
        ((UILabel *)aView.leftCalloutAccessoryView).text = [NSString stringWithFormat:@"%d", index+1];
        ((UILabel *)aView.leftCalloutAccessoryView).textAlignment = NSTextAlignmentCenter;
		aView.canShowCallout = YES;
	}
	
	// might be a reuse, so re(set) everything
	//((UIImageView *)aView.leftCalloutAccessoryView).image = nil;
    //((UIImageView *)aView.leftCalloutAccessoryView).image = [UIImage imageNamed:@"photo_add.png"];
	aView.annotation = annotation;
    
	return aView;
}

- (void)mapView:(MKMapView *)sender didSelectAnnotationView:(MKAnnotationView *)aView
{
//	Photographer *photographer = nil;
//	UIImageView *imageView = nil;
//	
//	if ([aView.annotation isKindOfClass:[Photographer class]]) {
//		photographer = (Photographer *)aView.annotation;
//	}
//	if ([aView.leftCalloutAccessoryView isKindOfClass:[UIImageView class]]) {
//		imageView = (UIImageView *)aView.leftCalloutAccessoryView;
//	}
//	
//	if (photographer && imageView)
//	{
//		NSString *thumbnailURL = photographer.representativePhoto.thumbnailURL;
//		if (thumbnailURL) {
//			dispatch_queue_t downloader = dispatch_queue_create("map view downloader", NULL);
//			dispatch_async(downloader, ^{
//				UIImage *image = [UIImage imageWithData:[FlickrFetcher imageDataForPhotoWithURLString:thumbnailURL]];
//				dispatch_async(dispatch_get_main_queue(), ^{
//					imageView.image = image;
//				});
//			});
//			dispatch_release(downloader);
//		}
//	}
}

- (void)mapView:(MKMapView *)sender annotationView:(MKAnnotationView *)aView calloutAccessoryControlTapped:(UIControl *)control
{
	
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
        darkView.tag = 22;
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
        [[self.view viewWithTag:22] removeFromSuperview];
        //[self.view viewWithTag:22] = nil;
    }
}

- (IBAction)clickDarkView:(id)sender
{
    [dropDown hideDropDownWithoutAnimation:(UIButton *)self.navigationItem.titleView];
    dropDown = nil;
    [[self.view viewWithTag:22] removeFromSuperview];
}

//Implement PullDownMenuDelegate method
- (void) showEditTravelPlan:(PullDownMenuView *)view
{
    [self performSegueWithIdentifier:@"EditPlan" sender:nil];
}

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
    [[self.view viewWithTag:22] removeFromSuperview];
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
}

-(void) didChangeLocation:(Location *)location
{
    [[self.dataController objectInListAtIndex:[self.tableView indexPathForSelectedRow].section] replaceObjectAtIndex:[self.tableView indexPathForSelectedRow].row withObject:location];
    [self.tableView reloadData];
    
    FMDatabase *db = [FMDatabase databaseWithPath:[Utility getDatabasePath]];
    [db open];
    //[db executeUpdate:@"INSERT INTO location (plan_id,whichday,seqofday,name,address,category) VALUES (?,?,?,?,?,?);",self.plan.planId,self.dayToAdd,self.seqToAdd,locationToAdd.name,locationToAdd.address,locationToAdd.category];
    BOOL success = [db executeUpdate:@"UPDATE location set transportation = ?, cost = ?, currency = ?, visit_begin = ?, visit_end = ?, detail = ?, category = ? WHERE id = ?", location.transportation, location.cost, location.currency, location.visitBegin, location.visitEnd, location.detail, location.category, location.locationId];
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
    
    Location *locationAtIndex = [[self.dataController objectInListAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    [[cell textLabel] setText:locationAtIndex.name];
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
    myView.backgroundColor = [UIColor grayColor];
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
        detailViewController.location = [[self.dataController objectInListAtIndex:[self.tableView indexPathForSelectedRow].section] objectAtIndex:[self.tableView indexPathForSelectedRow].row];
        detailViewController.delegate = self;
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
    Location *locationToMove = [[self.dataController objectInListAtIndex:fromIndexPath.section] objectAtIndex:fromIndexPath.row];
    [[self.dataController objectInListAtIndex:fromIndexPath.section] removeObjectAtIndex:fromIndexPath.row];
    [[self.dataController objectInListAtIndex:toIndexPath.section] insertObject:locationToMove atIndex:toIndexPath.row];
    
    //adjust the day and sequence of location
    FMDatabase *db = [FMDatabase databaseWithPath:[Utility getDatabasePath]];
    [db open];
    [db executeUpdate:[NSString stringWithFormat:@"UPDATE location SET seqofday = seqofday-1 where seqofday > %d and whichday = %d",fromIndexPath.row+1, fromIndexPath.section+1]];
    [db executeUpdate:[NSString stringWithFormat:@"UPDATE location SET seqofday = seqofday+1 where seqofday > %d and whichday = %d",toIndexPath.row, toIndexPath.section+1]];
    [db executeUpdate:[NSString stringWithFormat:@"UPDATE location SET whichday = %d, seqofday = %d where id = %d",toIndexPath.section+1, toIndexPath.row+1, [locationToMove.locationId intValue]]];
    [db close];
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
