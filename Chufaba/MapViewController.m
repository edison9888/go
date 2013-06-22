//
//  MapViewController.m
//  Chufaba
//
//  Created by 张辛欣 on 13-6-22.
//  Copyright (c) 2013年 ChufabaAPP团队. All rights reserved.
//

#import "MapViewController.h"
#import "LocationAnnotation.h"

@interface MapViewController ()
{
    NIDropDown *dropDown;
    BOOL singleDayMode;
    id <MKAnnotation> tappedAnnotation;
    NSMutableArray *oneDimensionLocationList;
    
    BOOL changeSelect;
    BOOL ios6OrAbove;
    NSInteger btnOffset;
    int firstLocationSection;
    
    int itineraryDaySelected;
}

@end

@implementation MapViewController

#define DAY_FILTER_FONT_SIZE 20
#define TAG_DAY_FILTER_ARROW 1

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    firstLocationSection = 0;
    singleDayMode = FALSE;
    
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 7, 40, 30)];
    [backBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backBtn setImage:[UIImage imageNamed:@"back_click"] forState:UIControlStateHighlighted];
    [backBtn addTarget:self action:@selector(backToPrevious:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = btn;
    
    self.categoryImage = [NSDictionary dictionaryWithObjectsAndKeys:@"pin_sight", @"景点", @"pin_food", @"美食", @"pin_hotel", @"住宿", @"pin_more", @"其它", nil];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(100,0,120,30)];
    itineraryDaySelected = [self.daySelected intValue];
    if(itineraryDaySelected != 0)
    {
        singleDayMode = TRUE;
    }
    if(!singleDayMode)
    {
        [button setTitle:@"全部" forState:UIControlStateNormal];
    }
    else
    {
        [button setTitle:[NSString stringWithFormat:@"第%d天", [self.daySelected intValue]] forState:UIControlStateNormal];
    }
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
    
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    if ([currSysVer compare:@"6.0" options:NSNumericSearch] != NSOrderedAscending)
    {
        ios6OrAbove = TRUE;
        btnOffset = 90;
    }
    else
    {
        ios6OrAbove = FALSE;
        btnOffset = 96;
    }
    
    oneDimensionLocationList = [self getOneDimensionLocationList];
    
    //start init map
    if(!self.mapView)
    {
        self.mapView = [[MKMapView alloc] init];
        self.mapView.frame = self.view.bounds;
        self.mapView.delegate = self;
        
        if (!ios6OrAbove)
        {
            for (UIGestureRecognizer *gesture in self.mapView.gestureRecognizers)
            {
                if([gesture isKindOfClass:[UITapGestureRecognizer class]])
                {
                    gesture.delegate = self;
                    break;
                }
            }
        }
        
        UIView* mapNavView = [[UIView alloc] initWithFrame:CGRectMake(230, self.mapView.frame.size.height-btnOffset, 80, 30)];
        mapNavView.backgroundColor = [UIColor clearColor];
        mapNavView.tag = 21;
        
        UIButton *mapPreviousButton = [[UIButton alloc] initWithFrame:CGRectMake(0,0,40,30)];
        mapPreviousButton.tag = 22;
        [mapPreviousButton setImage:[UIImage imageNamed:@"prevmap"] forState:UIControlStateNormal];
        [mapPreviousButton setImage:[UIImage imageNamed:@"prevmap_click"] forState:UIControlStateHighlighted];
        [mapPreviousButton setImage:[UIImage imageNamed:@"prevmapDis"] forState:UIControlStateDisabled];
        [mapPreviousButton addTarget:self action:@selector(previousMapLocation:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *mapNextButton = [[UIButton alloc] initWithFrame:CGRectMake(40,0,40,30)];
        mapNextButton.tag = 23;
        [mapNextButton setImage:[UIImage imageNamed:@"nextmap"] forState:UIControlStateNormal];
        [mapNextButton setImage:[UIImage imageNamed:@"nextmap_click"] forState:UIControlStateHighlighted];
        [mapNextButton setImage:[UIImage imageNamed:@"nextmapDis"] forState:UIControlStateDisabled];
        [mapNextButton addTarget:self action:@selector(nextMapLocation:) forControlEvents:UIControlEventTouchUpInside];
        
        UIView* mapPositionView = [[UIView alloc] initWithFrame:CGRectMake(10, self.mapView.frame.size.height-btnOffset, 40, 30)];
        mapPositionView.backgroundColor = [UIColor clearColor];
        mapPositionView.tag = 24;
        
        UIButton *positionButton = [[UIButton alloc] initWithFrame:CGRectMake(0,0,40,30)];
        [positionButton setImage:[UIImage imageNamed:@"position"] forState:UIControlStateNormal];
        [positionButton setImage:[UIImage imageNamed:@"position_click"] forState:UIControlStateHighlighted];
        [positionButton addTarget:self action:@selector(positionMe:) forControlEvents:UIControlEventTouchUpInside];
        
        [mapNavView addSubview:mapPreviousButton];
        [mapNavView addSubview:mapNextButton];
        [mapPositionView addSubview:positionButton];
        [self.mapView addSubview:mapNavView];
        [self.mapView addSubview:mapPositionView];
        
        [self.view addSubview:self.mapView];
        
        self.annotations = [self mapAnnotations];
        
        if(!self.locationManager)
        {
            self.locationManager = [[CLLocationManager alloc] init];
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            self.locationManager.delegate = self;
            self.curLocation = nil;
            [self.locationManager startUpdatingLocation];
        }
        
        if(self.mapView.showsUserLocation == NO)
        {
            self.mapView.showsUserLocation = YES;
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
            Location *firstLocation = [[self.currentItineraryList objectAtIndex:firstLocationSection] objectAtIndex:0];
            if ([firstLocation hasCoordinate]) {
                CLLocationCoordinate2D customLoc2D_5 = CLLocationCoordinate2DMake([firstLocation.latitude doubleValue], [firstLocation.longitude doubleValue]);
                [self.mapView setCenterCoordinate:customLoc2D_5 animated:YES];
                
                MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(customLoc2D_5, 2000, 2000);
                MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:region];
                
                [self.mapView setRegion:adjustedRegion animated:TRUE];
                
                if (ios6OrAbove)
                {
                    [self.mapView selectAnnotation:[self.annotations objectAtIndex:0] animated:YES];
                }
                else
                {
                    [self.mapView selectAnnotation:[self.annotations objectAtIndex:0] animated:NO];
                }
            }
        }
    }
}

- (IBAction)previousMapLocation:(id)sender
{
    if([self.mapView.selectedAnnotations count] == 1)
    {
        LocationAnnotation *selectedAnnotation = [self.mapView.selectedAnnotations objectAtIndex:0];
        NSNumber *latitude = selectedAnnotation.location.latitude;
        NSNumber *longitude = selectedAnnotation.location.longitude;
        self.indexOfCurSelected = [self.annotations indexOfObject:selectedAnnotation];
        
        Location *previousLocation;
        NSInteger curSelectedInAll;
        if(singleDayMode)
        {
            curSelectedInAll = [[self.currentItineraryList objectAtIndex:0] indexOfObject:selectedAnnotation.location];
            for(int i=1; i<[[self.currentItineraryList objectAtIndex:0] count]; i++)
            {
                previousLocation = [[self.currentItineraryList objectAtIndex:0] objectAtIndex:curSelectedInAll-i];
                if(!([previousLocation.latitude doubleValue] == 0 && [previousLocation.longitude doubleValue] == 0))
                {
                    if([previousLocation.latitude compare:latitude] == NSOrderedSame && [previousLocation.longitude compare:longitude] == NSOrderedSame)
                    {
                        [self.mapView selectAnnotation:[self.annotations objectAtIndex:self.indexOfCurSelected-1] animated:YES];
                    }
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
                    if([previousLocation.latitude compare:latitude] == NSOrderedSame && [previousLocation.longitude compare:longitude] == NSOrderedSame)
                    {
                        [self.mapView selectAnnotation:[self.annotations objectAtIndex:self.indexOfCurSelected-1] animated:YES];
                    }
                    break;
                }
            }
        }
        CLLocationCoordinate2D selectedLocationCoordinate = CLLocationCoordinate2DMake([previousLocation.latitude doubleValue], [previousLocation.longitude doubleValue]);
        
        [self.mapView setCenterCoordinate:selectedLocationCoordinate animated:YES];
        self.indexOfCurSelected -=1;
        changeSelect = TRUE;
    }
}

- (IBAction)nextMapLocation:(id)sender
{
    if([self.mapView.selectedAnnotations count] == 1)
    {
        LocationAnnotation *selectedAnnotation = [self.mapView.selectedAnnotations objectAtIndex:0];
        NSNumber *latitude = selectedAnnotation.location.latitude;
        NSNumber *longitude = selectedAnnotation.location.longitude;
        self.indexOfCurSelected = [self.annotations indexOfObject:selectedAnnotation];
        
        Location *nextLocation;
        NSInteger curSelectedInAll;
        if(singleDayMode)
        {
            curSelectedInAll = [[self.currentItineraryList objectAtIndex:0] indexOfObject:selectedAnnotation.location];
            for(int i=1; i<[[self.currentItineraryList objectAtIndex:0] count]; i++)
            {
                nextLocation = [[self.currentItineraryList objectAtIndex:0] objectAtIndex:curSelectedInAll+i];
                if(!([nextLocation.latitude doubleValue] == 0 && [nextLocation.longitude doubleValue] == 0))
                {
                    if([nextLocation.latitude compare:latitude] == NSOrderedSame && [nextLocation.longitude compare:longitude] == NSOrderedSame)
                    {
                        [self.mapView selectAnnotation:[self.annotations objectAtIndex:self.indexOfCurSelected+1] animated:YES];
                    }
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
                    if([nextLocation.latitude compare:latitude] == NSOrderedSame && [nextLocation.longitude compare:longitude] == NSOrderedSame)
                    {
                        [self.mapView selectAnnotation:[self.annotations objectAtIndex:self.indexOfCurSelected+1] animated:YES];
                    }
                    break;
                }
            }
        }
        CLLocationCoordinate2D selectedLocationCoordinate = CLLocationCoordinate2DMake([nextLocation.latitude doubleValue], [nextLocation.longitude doubleValue]);
        [self.mapView setCenterCoordinate:selectedLocationCoordinate animated:YES];
        self.indexOfCurSelected +=1;
        changeSelect = TRUE;
    }
}

- (IBAction)backToPrevious:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    //如果行程和地图页面选天模式不一样，从地图返回行程列表时需要做特殊处理
    if(itineraryDaySelected != [self.daySelected intValue])
    {
        [self.delegate notifyItinerayRoloadToThisDay:self.daySelected];
    }
}

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
    NSMutableArray *annotations = [[NSMutableArray alloc] init];
    for(int i=0;i<[self.currentItineraryList count];i++)
    {
        for (Location *location in [self.currentItineraryList objectAtIndex:i]) {
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
        if([[self.currentItineraryList objectAtIndex:0] count])
        {
            flag = TRUE;
        }
    }
    else
    {
        for(int i=0;i<[self.currentItineraryList count];i++)
        {
            if([[self.currentItineraryList objectAtIndex:i] count])
            {
                flag = TRUE;
                firstLocationSection = i;
                break;
            }
        }
    }
    return flag;
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

//DropDownDelegate
- (void) niDropDownDelegateMethod: (NIDropDown *) sender selectRow:(NSInteger)rowIndex
{
    UIButton *dayFilterBtn = (UIButton *)self.navigationItem.titleView;
    CGSize stringsize = [dayFilterBtn.titleLabel.text sizeWithFont:[UIFont systemFontOfSize:DAY_FILTER_FONT_SIZE]];
    UIImageView *dayFilterImg = (UIImageView *)[dayFilterBtn viewWithTag:TAG_DAY_FILTER_ARROW];
    dayFilterImg.frame = CGRectMake(dayFilterBtn.titleLabel.frame.origin.x + stringsize.width + 3, dayFilterImg.frame.origin.y, dayFilterImg.frame.size.width, dayFilterImg.frame.size.height );
    dropDown = nil;

    [[self.view viewWithTag:55] removeFromSuperview];
    self.daySelected = [NSNumber numberWithInt:rowIndex];
    if(rowIndex == 0){
        self.currentItineraryList = [self.itineraryListBackup mutableCopy];
        singleDayMode = false;
    }
    else{
        singleDayMode = true;
        NSMutableArray *dayList = [self.itineraryListBackup objectAtIndex:rowIndex-1];
        [self.currentItineraryList removeAllObjects];
        [self.currentItineraryList addObject:dayList];
    }
    //[self.tableView reloadData];
    self.annotations = [self mapAnnotations];
    
    if([self hasOneLocation])
    {
        Location *firstLocation = [[self.currentItineraryList objectAtIndex:firstLocationSection] objectAtIndex:0];
        if ([firstLocation hasCoordinate]) {
            CLLocationCoordinate2D firstLocationCoordinate = CLLocationCoordinate2DMake([firstLocation.latitude doubleValue], [firstLocation.longitude doubleValue]);
            [self.mapView setCenterCoordinate:firstLocationCoordinate animated:YES];
            
            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(firstLocationCoordinate, 2000, 2000);
            MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:region];
            
            [self.mapView setRegion:adjustedRegion animated:TRUE];
            
            if (ios6OrAbove)
            {
                [self.mapView selectAnnotation:[self.annotations objectAtIndex:0] animated:YES];
            }
            else
            {
                [self.mapView selectAnnotation:[self.annotations objectAtIndex:0] animated:NO];
            }
        }
    }
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
    aView.image = [UIImage imageNamed:[self.categoryImage objectForKey:locationAnnotation.location.category]];
    NSUInteger index = [oneDimensionLocationList indexOfObject:locationAnnotation.location];
    ((UILabel *)aView.leftCalloutAccessoryView).text = [NSString stringWithFormat:@"%d", index+1];
	aView.annotation = annotation;
    
	return aView;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if(changeSelect)
    {
        [self.mapView selectAnnotation:[self.annotations objectAtIndex:self.indexOfCurSelected] animated:YES];
        changeSelect = FALSE;
    }
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

- (IBAction)selectClicked:(id)sender {
    NSMutableArray * arr = [[NSMutableArray alloc] init];
    [arr addObject:@"全部"];
    for(int i=0; i<[self.itineraryDuration intValue]; i++)
    {
        [arr addObject:[NSString stringWithFormat:@"第%d天", i+1]];
    }
    if(dropDown == nil)
    {
        UIView *darkView = [[UIView alloc] initWithFrame:self.view.bounds];
        darkView.backgroundColor = [UIColor clearColor];
        darkView.tag = 55;
        UITapGestureRecognizer *singleFingerTap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickDarkView:)];
        [darkView addGestureRecognizer:singleFingerTap];
        UIPanGestureRecognizer *panGesture =[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(clickDarkView:)];
        [darkView addGestureRecognizer:panGesture];
        [self.view addSubview:darkView];
        
        CGFloat f = ([self.itineraryDuration intValue]+1)*40;
        dropDown = [[NIDropDown alloc] showDropDown:sender withHeight:&f withDays:arr];
        dropDown.delegate = self;
    }
    else
    {
        [dropDown hideDropDown:sender];
        dropDown = nil;
        [[self.view viewWithTag:55] removeFromSuperview];
    }
}

- (IBAction)clickDarkView:(id)sender
{
    [dropDown hideDropDownWithoutAnimation:(UIButton *)self.navigationItem.titleView];
    dropDown = nil;
    [[self.view viewWithTag:55] removeFromSuperview];
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

//Implement AddLocation delegate
-(void) didChangeLocation:(Location *)location
{
    [self.delegate didChangeLocationFromMap:location];
}

- (BOOL)showPositionAlert
{
    if(![CLLocationManager locationServicesEnabled])
        return TRUE;
    if([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
        return TRUE;
    return FALSE;
}

- (IBAction)positionMe:(id)sender
{
    if([self showPositionAlert])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"请在系统设置中打开“定位服务”来允许“出发吧”确定您的位置"
                                                       delegate:nil
                                              cancelButtonTitle:@"知道了"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    [self.mapView setCenterCoordinate:self.mapView.userLocation.coordinate animated:YES];
    [self.mapView selectAnnotation:self.mapView.userLocation animated:YES];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (self.mapView)
    {
        //if ([touch.view isDescendantOfView:self.mapView])
        if ([touch.view isKindOfClass:[UIButton class]])
        {
            return NO;
        }
    }
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (NSIndexPath *) indexPathForTappedAnnotation
//{
//    int row = 0;
//    int section = 0;
//    if(singleDayMode)
//    {
//        section = 0;
//        row = [self.annotations indexOfObject:tappedAnnotation];
//    }
//    else
//    {
//        int annotationCount = [self.annotations indexOfObject:tappedAnnotation]+1;
//        for(int i=0;i<[self.dataController.masterTravelDayList count];i++)
//        {
//            annotationCount = annotationCount-[[self.dataController.masterTravelDayList objectAtIndex:i] count];
//            if(annotationCount<=0)
//            {
//                section = i;
//                row = annotationCount + [[self.dataController.masterTravelDayList objectAtIndex:i] count] - 1;
//                break;
//            }
//        }
//    }
//    return [NSIndexPath indexPathForRow:row inSection:section];
//}

@end
