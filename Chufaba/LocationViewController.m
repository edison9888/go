//
//  itineraryDetailViewController.m
//  出发吧
//
//  Created by kenzo on 13-1-16.
//  Copyright (c) 2013年 出发吧APP团队. All rights reserved.
//

#import "LocationViewController.h"
#import "Location.h"
#import "LocationAnnotation.h"
#import "EditTransportViewController.h"
#import "EditCostViewController.h"
#import "EditDetailViewController.h"
#import "EditScheduleViewController.h"
#import "EditCategoryViewController.h"
#import "LocationMapViewController.h"
#import "LocationTableViewCell.h"

@interface LocationViewController ()
{
    BOOL showMap;
}

- (void)configureView;

@end

@implementation LocationViewController


#define TAG_MAPVIEW 1
#define TAG_NAMESCROLL 2
#define TAG_NAMELABEL 3
#define TAG_ADDRESSLABEL 4
#define TAG_TABLEVIEW 5
#define TAG_DAYLABEL 6

#define MAP_VIEW_HEIGHT 75
#define DAY_LABEL_HEIGHT 20
#define NAME_SCROLL_HEIGHT 60
#define NAME_LABEL_HEIGHT 25
#define ADDRESS_LABEL_HEIGHT 25
#define TABLEVIEW_SCROLL_OFFSET 64

#pragma mark - Managing the detail item

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:
                                            [NSArray arrayWithObjects:
                                             [UIImage imageNamed:@"arrow_up.png"],
                                             [UIImage imageNamed:@"arrow_down.png"],
                                             nil]];
    [segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    segmentedControl.frame = CGRectMake(0, 0, 90, 30);
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    segmentedControl.momentary = YES;
    
    //defaultTintColor = [segmentedControl.tintColor retain];
    
    UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
    
    self.navigationItem.rightBarButtonItem = segmentBarItem;
    self.navigationItem.title = [NSString stringWithFormat:@"%@/%@", [[NSNumber numberWithInt:[self.locationIndex intValue]+1] stringValue], [self.totalLocationCount stringValue]];
    
    if ([self.location.latitude intValue] != 10000 && self.location.latitude != nil && [self.location.latitude intValue] != 0)  
    {
        showMap = YES;
        MKMapView *mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, MAP_VIEW_HEIGHT)];
        mapView.tag = TAG_MAPVIEW;
        mapView.delegate = self;
        [self.view addSubview:mapView];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:mapView.frame];
        [self.view addSubview:button];
        [button addTarget:self action:@selector(showLargeMap) forControlEvents:UIControlEventTouchUpInside];
    }
    
    UIScrollView *nameScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, showMap? MAP_VIEW_HEIGHT : 0, self.view.frame.size.width, NAME_SCROLL_HEIGHT)];
    nameScroll.tag = TAG_NAMESCROLL;
    nameScroll.showsHorizontalScrollIndicator = FALSE;
    nameScroll.showsVerticalScrollIndicator = FALSE;
    nameScroll.backgroundColor = [UIColor lightGrayColor];
    
    if(!showMap)
    {
        UIButton *editLocationBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-60,0,60,60)];
        editLocationBtn.tag = 22;
        [editLocationBtn setImage:[UIImage imageNamed:@"edit.png"] forState:UIControlStateNormal];
        [editLocationBtn addTarget:self action:@selector(editLocationCoordinate:) forControlEvents:UIControlEventTouchDown];
        [nameScroll addSubview:editLocationBtn];
    }
    [self.view addSubview:nameScroll];
    
    UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 5, self.view.frame.size.width, NAME_LABEL_HEIGHT)];
    nameLabel.tag = TAG_NAMELABEL;
    nameLabel.backgroundColor = [UIColor lightGrayColor];
    nameLabel.font = [UIFont systemFontOfSize:15];
    [nameScroll addSubview:nameLabel];
    
    UILabel *addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 35, self.view.frame.size.width, ADDRESS_LABEL_HEIGHT)];
    addressLabel.tag = TAG_ADDRESSLABEL;
    addressLabel.backgroundColor = [UIColor lightGrayColor];
    addressLabel.font = [UIFont systemFontOfSize:14];
    [nameScroll addSubview:addressLabel];
   
    NSInteger tableviewHeight = showMap ? self.view.frame.size.height-TABLEVIEW_SCROLL_OFFSET-MAP_VIEW_HEIGHT-NAME_SCROLL_HEIGHT:self.view.frame.size.height-TABLEVIEW_SCROLL_OFFSET-NAME_SCROLL_HEIGHT;
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, showMap? MAP_VIEW_HEIGHT+NAME_SCROLL_HEIGHT : NAME_SCROLL_HEIGHT, self.view.frame.size.width, tableviewHeight) style:UITableViewStyleGrouped];
    tableView.tag = TAG_TABLEVIEW;
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    
    //NSLog(@"height:%f", self.navigationController.navigationBar.frame.size.height);
    UILabel *dayLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - DAY_LABEL_HEIGHT - self.navigationController.navigationBar.frame.size.height, self.view.frame.size.width, 20)];
    dayLabel.tag = TAG_DAYLABEL;
    dayLabel.backgroundColor = [UIColor colorWithRed:0.239 green:0.239 blue:0.239 alpha:0.9];
    dayLabel.textColor = [UIColor whiteColor];
    dayLabel.font = [UIFont systemFontOfSize:14];
    dayLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:dayLabel];
    
    [self configureView];
}

- (IBAction) editLocationCoordinate:(id)sender
{
    AddLocationViewController *addLocationViewController = [[AddLocationViewController alloc] init];
    addLocationViewController.addLocationName = self.location.name;
    if(self.location.latitude != 0 && self.location.latitude != nil)
    {
        addLocationViewController.lastLatitude = self.location.latitude;
        addLocationViewController.lastLongitude = self.location.longitude;
    }
    addLocationViewController.editLocationDelegate = self;
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:addLocationViewController];
    [self presentViewController:navController animated:YES completion:NULL];
}

- (IBAction) segmentAction:(id)sender
{
    int clickedSegmentIndex = [(UISegmentedControl *)sender selectedSegmentIndex];
    if(clickedSegmentIndex == 0)
    {
        [(UISegmentedControl *)(self.navigationItem.rightBarButtonItem.customView) setEnabled:YES forSegmentAtIndex:1];
        self.location = [self.navDelegate getPreviousLocation:self.location];
        [self configureView];
        if([self.locationIndex intValue] == 1)
        {
            [(UISegmentedControl *)(self.navigationItem.rightBarButtonItem.customView) setEnabled:NO forSegmentAtIndex:0];
        }
        self.locationIndex = [NSNumber numberWithInt:[self.locationIndex intValue]-1];
        self.navigationItem.title = [NSString stringWithFormat:@"%@/%@", [[NSNumber numberWithInt:[self.locationIndex intValue]+1] stringValue], [self.totalLocationCount stringValue]];
    }
    else
    {
        [(UISegmentedControl *)(self.navigationItem.rightBarButtonItem.customView) setEnabled:YES forSegmentAtIndex:0];
        self.location = [self.navDelegate getNextLocation:self.location];
        [self configureView];
        if([self.locationIndex intValue] == [self.totalLocationCount intValue]-2)
        {
            [(UISegmentedControl *)(self.navigationItem.rightBarButtonItem.customView) setEnabled:NO forSegmentAtIndex:1];
        }
        self.locationIndex = [NSNumber numberWithInt:[self.locationIndex intValue]+1];
        self.navigationItem.title = [NSString stringWithFormat:@"%@/%@", [[NSNumber numberWithInt:[self.locationIndex intValue]+1] stringValue], [self.totalLocationCount stringValue]];
    }
}

- (void)configureView
{
    if (self.location) {
        [self configureMap];
        
        UILabel *nameLabel = (UILabel *)[self.view viewWithTag:TAG_NAMELABEL];
        nameLabel.text = self.location.name;
        [nameLabel sizeToFit];
                
        UILabel *addressLabel = (UILabel *)[self.view viewWithTag:TAG_ADDRESSLABEL];
        addressLabel.text = self.location.address;
        [addressLabel sizeToFit];
        
        CGFloat nameWidth = nameLabel.frame.size.width;
        CGFloat addressWidth = addressLabel.frame.size.width;
        
        ((UIScrollView *)[self.view viewWithTag:TAG_NAMESCROLL]).contentSize = CGSizeMake((nameWidth > addressWidth) ? nameWidth : addressWidth, 60);
        
        ((UILabel *)[self.view viewWithTag:TAG_DAYLABEL]).text = [NSString stringWithFormat:@"第 %d 天", [self.location.whichday intValue]];
        
        [((UITableView *)[self.view viewWithTag:TAG_TABLEVIEW]) reloadData];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.row == 0) {
        static NSString *CellIdentifier = @"TransportationCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[LocationTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.imageView.image = [UIImage imageNamed:@"location_transport.png"];
            cell.textLabel.numberOfLines = 2;
            cell.textLabel.font = [UIFont systemFontOfSize:13];
        }
        cell.textLabel.text = self.location.transportation;
    } else if (indexPath.row == 1) {
        static NSString *CellIdentifier = @"ScheduleCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.imageView.image = [UIImage imageNamed:@"location_time.png"];
            cell.textLabel.font = [UIFont systemFontOfSize:13];
        }
        if(self.location.visitBegin || self.location.visitEnd){
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateStyle:NSDateFormatterNoStyle];
            [formatter setTimeStyle:NSDateFormatterShortStyle];
            cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@", [formatter stringFromDate:self.location.visitBegin] ?: @"", [formatter stringFromDate:self.location.visitEnd] ?: @""];
        }
    } else if (indexPath.row == 2) {
        static NSString *CellIdentifier = @"CostCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.imageView.image = [UIImage imageNamed:@"location_money.png"];
            cell.textLabel.font = [UIFont systemFontOfSize:13];
        }
        if(!self.location.cost){
            self.location.cost = [NSNumber numberWithInt:0];
        }
        if(!self.location.currency){
            self.location.currency = @"RMB";
        }
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", self.location.currency, [formatter stringFromNumber:self.location.cost]];
    } else if (indexPath.row == 3) {
        static NSString *CellIdentifier = @"CagetoryCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.font = [UIFont systemFontOfSize:13];
        }
        cell.imageView.image = [Location getCategoryIcon:self.location.category];
        cell.textLabel.text = self.location.category;
    } else if (indexPath.row == 4) {
        static NSString *CellIdentifier = @"NoteCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[LocationTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.imageView.image = [UIImage imageNamed:@"location_note.png"];
            cell.textLabel.numberOfLines = 4;
            cell.textLabel.font = [UIFont systemFontOfSize:13];
        }
        cell.textLabel.text = self.location.detail;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 64;
    } else if (indexPath.row == 4) {
        return 88;
    } else {
        return 44;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        EditTransportViewController *transportViewController = [[EditTransportViewController alloc] init];
        transportViewController.transportation = self.location.transportation;
        transportViewController.delegate = self;
        [self.navigationController pushViewController:transportViewController animated:YES];
    } else if (indexPath.row == 1) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle: nil];
        EditScheduleViewController *scheduleViewController = [storyboard instantiateViewControllerWithIdentifier:@"EditScheduleStoryBoard"];
        scheduleViewController.start = self.location.visitBegin;
        scheduleViewController.end = self.location.visitEnd;
        scheduleViewController.delegate = self;
        [self.navigationController pushViewController:scheduleViewController animated:YES];
    } else if (indexPath.row == 2) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle: nil];
        EditCostViewController *costViewController = [storyboard instantiateViewControllerWithIdentifier:@"EditCostStoryBoard"];
        costViewController.amount = self.location.cost;
        costViewController.currency = self.location.currency;
        costViewController.delegate = self;
        [self.navigationController pushViewController:costViewController animated:YES];
    } else if (indexPath.row == 3) {
        EditCategoryViewController *categoryViewController = [[EditCategoryViewController alloc] init];
        categoryViewController.category = self.location.category;
        categoryViewController.delegate = self;
        [self.navigationController pushViewController:categoryViewController animated:YES];
    } else if (indexPath.row == 4) {
        EditDetailViewController *detailViewController = [[EditDetailViewController alloc] init];
        detailViewController.detail = self.location.detail;
        detailViewController.delegate = self;
        [self.navigationController pushViewController:detailViewController animated:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UITableView *tableView = (UITableView *)[self.view viewWithTag:TAG_TABLEVIEW];
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
}


- (void)configureMap
{
    if (showMap) {
        CLLocationCoordinate2D customLoc2D_5 = CLLocationCoordinate2DMake([self.location.latitude doubleValue], [self.location.longitude doubleValue]);
        MKMapView *mapView = (MKMapView *)[self.view viewWithTag:TAG_MAPVIEW];
        [mapView setCenterCoordinate:customLoc2D_5 animated:false];
        MKCoordinateRegion region;
        region.center = customLoc2D_5;
        MKCoordinateSpan span;
        span.latitudeDelta = 0.4;
        span.longitudeDelta = 0.4;
        region.span=span;
        [mapView setRegion:region animated:false];
        [mapView removeAnnotations:mapView.selectedAnnotations];
        [mapView selectAnnotation:[LocationAnnotation annotationForLocation:self.location ShowTitle:false] animated:false];
    }
}

- (void)showLargeMap
{
    LocationMapViewController *mapViewController = [[LocationMapViewController alloc] init];
    mapViewController.location = self.location;
    mapViewController.index = self.locationIndex;
    [self.navigationController pushViewController:mapViewController animated:YES];
}

-(void) didEditTransport:(NSString *)transportation
{
    self.location.transportation = transportation;
    [((UITableView *)[self.view viewWithTag:TAG_TABLEVIEW]) reloadData];
    [self.delegate didChangeLocation:self.location];
}

-(void) didEditCostWithAmount:(NSNumber *)amount AndCurrency:(NSString *)currency
{
    self.location.cost = amount;
    self.location.currency = currency;
    [((UITableView *)[self.view viewWithTag:TAG_TABLEVIEW]) reloadData];
    [self.delegate didChangeLocation:self.location];
}

-(void) didEditScheduleWithStart:(NSDate *)start AndEnd:(NSDate *)end
{
    self.location.visitBegin = start;
    self.location.visitEnd = end;
    [((UITableView *)[self.view viewWithTag:TAG_TABLEVIEW]) reloadData];
    [self.delegate didChangeLocation:self.location];
}

-(void) didEditDetail:(NSString *)detail
{
    self.location.detail = detail;
    [((UITableView *)[self.view viewWithTag:TAG_TABLEVIEW]) reloadData];
    [self.delegate didChangeLocation:self.location];
}

-(void) didEditCategory:(NSString *)category
{
    self.location.category = category;
    [((UITableView *)[self.view viewWithTag:TAG_TABLEVIEW]) reloadData];
    [self.delegate didChangeLocation:self.location];
}

//Implement AddLocationViewControllerDelegate
-(void) AddLocationViewController:(AddLocationViewController *) addLocationViewController didFinishEdit:(Location *) location
{
    self.location = location;
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
