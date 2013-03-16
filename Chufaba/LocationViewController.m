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
#define TAG_ENAMELABEL 4
#define TAG_ADDRESSLABEL 5
#define TAG_TABLEVIEW 6
#define TAG_INFOVIEW 7
#define TAG_DAYLABEL 8
#define TAG_SEQLABEL 9

#define MAP_VIEW_HEIGHT 75
#define INFO_VIEW_HEIGHT 20
#define DAY_LABEL_HEIGHT 20
#define NAME_SCROLL_HEIGHT 55
#define NAME_LABEL_HEIGHT 24
#define ENAME_LABEL_HEIGHT 12
#define ADDRESS_LABEL_HEIGHT 12
#define TABLEVIEW_SCROLL_OFFSET 64

#pragma mark - Managing the detail item

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    //self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
    
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
    //self.navigationController.navigationBar.title = @"地点详情";
    self.navigationItem.title = @"地点详情";
    
    if ([self.location.latitude intValue] != 10000 && self.location.latitude != nil && [self.location.latitude intValue] != 0)  
    {
        showMap = YES;
        MKMapView *mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, MAP_VIEW_HEIGHT)];
        mapView.tag = TAG_MAPVIEW;
        mapView.delegate = self;
        [self.view addSubview:mapView];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:mapView.frame];
        [self.view addSubview:button];
        [button addTarget:self action:@selector(showLargeMap) forControlEvents:UIControlEventTouchUpInside];
    }
    
    UIScrollView *nameScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, showMap? MAP_VIEW_HEIGHT+INFO_VIEW_HEIGHT : INFO_VIEW_HEIGHT, self.view.frame.size.width, NAME_SCROLL_HEIGHT)];
    nameScroll.tag = TAG_NAMESCROLL;
    nameScroll.showsHorizontalScrollIndicator = FALSE;
    nameScroll.showsVerticalScrollIndicator = FALSE;
    //nameScroll.backgroundColor = [UIColor colorWithRed:222/255.0 green:214/255.0 blue:195/255.0 alpha:1.0];
    nameScroll.backgroundColor = [UIColor colorWithRed:244/255.0 green:241/255.0 blue:235/255.0 alpha:1.0];
    
    if(!showMap)
    {
        UIButton *editLocationBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-60,0,60,60)];
        editLocationBtn.tag = 22;
        [editLocationBtn setImage:[UIImage imageNamed:@"edit.png"] forState:UIControlStateNormal];
        [editLocationBtn addTarget:self action:@selector(editLocationCoordinate:) forControlEvents:UIControlEventTouchDown];
        [nameScroll addSubview:editLocationBtn];
    }
    [self.view addSubview:nameScroll];
    
    UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 5, self.view.frame.size.width, NAME_LABEL_HEIGHT)];
    nameLabel.tag = TAG_NAMELABEL;
    nameLabel.textColor = [UIColor colorWithRed:72/255.0 green:70/255.0 blue:66/255.0 alpha:1.0];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.font = [UIFont fontWithName:@"Heiti SC" size:16];
    [nameScroll addSubview:nameLabel];
    
    UILabel *eNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 25, self.view.frame.size.width, ENAME_LABEL_HEIGHT)];
    eNameLabel.tag = TAG_ENAMELABEL;
    eNameLabel.textColor = [UIColor colorWithRed:153/255.0 green:150/255.0 blue:145/255.0 alpha:1.0];
    eNameLabel.backgroundColor = [UIColor clearColor];
    eNameLabel.font = [UIFont fontWithName:@"Heiti SC" size:12];
    [nameScroll addSubview:eNameLabel];
    
    UILabel *addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 40, self.view.frame.size.width, ADDRESS_LABEL_HEIGHT)];
    addressLabel.tag = TAG_ADDRESSLABEL;
    addressLabel.textColor = [UIColor colorWithRed:153/255.0 green:150/255.0 blue:145/255.0 alpha:1.0];
    addressLabel.backgroundColor = [UIColor clearColor];
    addressLabel.font = [UIFont fontWithName:@"Heiti SC" size:12];
    [nameScroll addSubview:addressLabel];
   
    NSLog(@"height1:%f", self.view.frame.size.height);
    NSInteger tableviewHeight = showMap ? self.view.frame.size.height-TABLEVIEW_SCROLL_OFFSET-MAP_VIEW_HEIGHT-NAME_SCROLL_HEIGHT-INFO_VIEW_HEIGHT:self.view.frame.size.height-TABLEVIEW_SCROLL_OFFSET-NAME_SCROLL_HEIGHT-INFO_VIEW_HEIGHT;
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, showMap? MAP_VIEW_HEIGHT+NAME_SCROLL_HEIGHT+INFO_VIEW_HEIGHT : NAME_SCROLL_HEIGHT+INFO_VIEW_HEIGHT, self.view.frame.size.width, tableviewHeight) style:UITableViewStyleGrouped];
    tableView.tag = TAG_TABLEVIEW;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.backgroundView = nil;
    tableView.backgroundColor = [UIColor colorWithRed:244/255.0 green:241/255.0 blue:235/255.0 alpha:1.0];
    [self.view addSubview:tableView];
    
    UIView *infoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, INFO_VIEW_HEIGHT)];
    infoView.tag = TAG_INFOVIEW;
    infoView.backgroundColor = [UIColor colorWithRed:222/255.0 green:214/255.0 blue:195/255.0 alpha:1.0];
    
    UILabel *dayLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 2, 60, 16)];
    dayLabel.tag = TAG_DAYLABEL;
    dayLabel.backgroundColor = [UIColor clearColor];
    dayLabel.textColor = [UIColor colorWithRed:72/255.0 green:70/255.0 blue:66/255.0 alpha:1.0];
    dayLabel.font = [UIFont fontWithName:@"Heiti SC" size:12];
    [infoView addSubview:dayLabel];
    
    UILabel *seqLabel = [[UILabel alloc] initWithFrame:CGRectMake(260, 2, 50, 16)];
    seqLabel.tag = TAG_SEQLABEL;
    seqLabel.backgroundColor = [UIColor clearColor];
    seqLabel.textColor = [UIColor colorWithRed:153/255.0 green:150/255.0 blue:145/255.0 alpha:1.0];
    seqLabel.font = [UIFont fontWithName:@"Heiti SC" size:12];
    seqLabel.textAlignment = NSTextAlignmentRight;
    [infoView addSubview:seqLabel];
    
    seqLabel.text = [NSString stringWithFormat:@"%@/%@", [[NSNumber numberWithInt:[self.locationIndex intValue]+1] stringValue], [self.totalLocationCount stringValue]];
    
    [self.view addSubview:infoView];
    
    [self configureView];
}

- (IBAction) editLocationCoordinate:(id)sender
{
    AddLocationViewController *addLocationViewController = [[AddLocationViewController alloc] init];
    addLocationViewController.addLocationName = self.location.name;
    addLocationViewController.addLocationCategory = self.location.category;
    addLocationViewController.locationID = self.location.locationId;
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
        ((UILabel *)[self.view viewWithTag:TAG_SEQLABEL]).text = [NSString stringWithFormat:@"%@/%@", [[NSNumber numberWithInt:[self.locationIndex intValue]+1] stringValue], [self.totalLocationCount stringValue]];
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
        ((UILabel *)[self.view viewWithTag:TAG_SEQLABEL]).text = [NSString stringWithFormat:@"%@/%@", [[NSNumber numberWithInt:[self.locationIndex intValue]+1] stringValue], [self.totalLocationCount stringValue]];
    }
}

- (void)configureView
{
    if (self.location) {
        [self configureMap];
        
        UILabel *nameLabel = (UILabel *)[self.view viewWithTag:TAG_NAMELABEL];
        nameLabel.text = self.location.name;
        [nameLabel sizeToFit];
        
        UILabel *eNameLabel = (UILabel *)[self.view viewWithTag:TAG_ENAMELABEL];
        //need to replace with actual Engilish Name
        eNameLabel.text = @"Add English name please";
        [eNameLabel sizeToFit];
                
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
-(void) AddLocationViewController:(AddLocationViewController *) addLocationViewController didFinishEdit:(Location *) location name:(BOOL) nameChanged coordinate:(BOOL) coordinateChanged
{
    if(nameChanged)
    {
        [self didEditName:location.name];
    }
    if(coordinateChanged)
    {
        [self didEditCoordinate:location.latitude withLongitude:location.longitude];
        [((UIScrollView *)[self.view viewWithTag:TAG_NAMESCROLL]) setFrame:CGRectMake(0, MAP_VIEW_HEIGHT+INFO_VIEW_HEIGHT, self.view.frame.size.width, NAME_SCROLL_HEIGHT)];
        
        NSLog(@"height2:%f", self.view.frame.size.height);
        NSInteger tableviewHeight = self.view.frame.size.height+self.navigationController.navigationBar.frame.size.height-TABLEVIEW_SCROLL_OFFSET-MAP_VIEW_HEIGHT-NAME_SCROLL_HEIGHT-INFO_VIEW_HEIGHT;
        [((UITableView *)[self.view viewWithTag:TAG_TABLEVIEW]) setFrame:CGRectMake(0, MAP_VIEW_HEIGHT+NAME_SCROLL_HEIGHT+INFO_VIEW_HEIGHT, self.view.frame.size.width, tableviewHeight)];
    }
    [self.delegate didChangeLocation:self.location];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(void) didEditName:(NSString *)name
{
    showMap = YES;
    self.location.name = name;
    ((UILabel *)[self.view viewWithTag:TAG_NAMELABEL]).text = name;
}

-(void) didEditCoordinate:(NSNumber *)latitude withLongitude:(NSNumber *)longitude
{
    self.location.latitude = latitude;
    self.location.longitude = longitude;
    showMap = YES;
    if([self.view viewWithTag:TAG_MAPVIEW])
    {
        [self configureMap];
    }
    else
    {
        //MKMapView *mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, MAP_VIEW_HEIGHT)];
        MKMapView *mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, MAP_VIEW_HEIGHT)];
        mapView.tag = TAG_MAPVIEW;
        mapView.delegate = self;
        [self.view addSubview:mapView];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:mapView.frame];
        [self.view addSubview:button];
        [button addTarget:self action:@selector(showLargeMap) forControlEvents:UIControlEventTouchUpInside];
        
        [self configureMap];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
