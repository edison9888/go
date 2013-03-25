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
#import "EditDetailViewController.h"
#import "EditScheduleViewController.h"
#import "LocationMapViewController.h"
#import "LocationTableViewCell.h"
#import "FadeScrollView.h"

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
#define TAG_CATEGORY_IMAGE 10
#define TAG_OPENINGLABEL 11
#define TAG_FEELABEL 12
#define TAG_DURATIONLABEL 13
#define TAG_WEBSITELABEL 14
#define TAG_EDITBUTTON 15
#define TAG_MAPBTN 16
#define TAG_SEGMENT 17

#define MAP_VIEW_HEIGHT 75
#define INFO_VIEW_HEIGHT 20
#define DAY_LABEL_HEIGHT 20
#define NAME_SCROLL_HEIGHT 55
#define NAME_LABEL_HEIGHT 24
#define ENAME_LABEL_HEIGHT 12
#define ADDRESS_LABEL_HEIGHT 12

#define FONT_SIZE 13

#pragma mark - Managing the detail item

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:244/255.0 green:241/255.0 blue:235/255.0 alpha:1.0];
    [self configureView];
}

- (void)configureView
{
    if (self.location) {
        self.navigationItem.title = self.location.name;
        
        UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 7, 40, 30)];
        [backBtn setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
        [backBtn addTarget:self action:@selector(backToPrevious:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
        self.navigationItem.leftBarButtonItem = btn;
        
        [self configureSegment];
        [self configureDate];
        [self configureMap];
        [self configureNameScroll];
        [self configureTable];
    }
}

- (IBAction)backToPrevious:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)configureSegment
{
    UISegmentedControl *segmentedControl = (UISegmentedControl *)[self.view viewWithTag:TAG_SEGMENT];
    if (!segmentedControl) {
        segmentedControl = [[UISegmentedControl alloc] initWithItems:
         [NSArray arrayWithObjects:
          [UIImage imageNamed:@"arrow_up.png"],
          [UIImage imageNamed:@"arrow_down.png"],
          nil]];
        [segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
        segmentedControl.frame = CGRectMake(0, 0, 90, 30);
        segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
        segmentedControl.momentary = YES;
        
        UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
        self.navigationItem.rightBarButtonItem = segmentBarItem;
    }
    if(self.locationIndex == 0){
        [segmentedControl setEnabled:NO forSegmentAtIndex:0];
    }else{
        [segmentedControl setEnabled:YES forSegmentAtIndex:0];
    }
    if (self.locationIndex == self.totalLocationCount-1) {
        [segmentedControl setEnabled:NO forSegmentAtIndex:1];
    }else{
        [segmentedControl setEnabled:YES forSegmentAtIndex:1];
    }
}

- (IBAction) segmentAction:(id)sender
{
    int clickedSegmentIndex = [(UISegmentedControl *)sender selectedSegmentIndex];
    if(clickedSegmentIndex == 0 && self.locationIndex > 0) {
        self.locationIndex--;
        self.location = [self.navDelegate getPreviousLocation:self.location];
        [self configureView];
    }else if(clickedSegmentIndex == 1 && self.locationIndex < self.totalLocationCount - 1) {
        self.locationIndex++;
        self.location = [self.navDelegate getNextLocation:self.location];
        [self configureView];
    }
}

- (void)configureDate
{
    UIView *infoView = [self.view viewWithTag:TAG_INFOVIEW];
    if (!infoView) {
        infoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, INFO_VIEW_HEIGHT)];
        infoView.tag = TAG_INFOVIEW;
        [self.view addSubview:infoView];
    }
    
    UILabel *dayLabel = (UILabel *)[self.view viewWithTag:TAG_DAYLABEL];
    if (!dayLabel) {
        dayLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 2, 60, 16)];
        dayLabel.tag = TAG_DAYLABEL;
        dayLabel.backgroundColor = [UIColor clearColor];
        dayLabel.textColor = [UIColor colorWithRed:72/255.0 green:70/255.0 blue:66/255.0 alpha:1.0];
        dayLabel.font = [UIFont fontWithName:@"Heiti SC" size:12];
        [infoView addSubview:dayLabel];
    }
    dayLabel.text = [NSString stringWithFormat:@"第 %d 天", [self.location.whichday intValue]];
    
    UILabel *seqLabel = (UILabel *)[self.view viewWithTag:TAG_SEQLABEL];
    if (!seqLabel) {
        seqLabel = [[UILabel alloc] initWithFrame:CGRectMake(260, 2, 50, 16)];
        seqLabel.tag = TAG_SEQLABEL;
        seqLabel.backgroundColor = [UIColor clearColor];
        seqLabel.textColor = [UIColor colorWithRed:153/255.0 green:150/255.0 blue:145/255.0 alpha:1.0];
        seqLabel.font = [UIFont fontWithName:@"Heiti SC" size:12];
        seqLabel.textAlignment = NSTextAlignmentRight;
        [infoView addSubview:seqLabel];
    }
    seqLabel.text = [NSString stringWithFormat:@"%d/%d", self.locationIndex + 1, self.totalLocationCount];
}

- (void)configureMap
{
    if ([self.location hasCoordinate])
    {
        showMap = YES;
        MKMapView *mapView = (MKMapView *)[self.view viewWithTag:TAG_MAPVIEW];
        UIButton *button;
        if (!mapView) {
            mapView = [[MKMapView alloc] init];
            mapView.tag = TAG_MAPVIEW;
            mapView.delegate = self;
            [self.view addSubview:mapView];
            
            button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.tag = TAG_MAPBTN;
            [self.view addSubview:button];
            [button addTarget:self action:@selector(showLargeMap) forControlEvents:UIControlEventTouchUpInside];
        }
        mapView.frame = CGRectMake(0, 20, self.view.frame.size.width, MAP_VIEW_HEIGHT);
        if (!button) {
            button = (UIButton *)[self.view viewWithTag:TAG_MAPBTN];
        }
        [button setFrame:mapView.frame];
        
        CLLocationCoordinate2D customLoc2D_5 = CLLocationCoordinate2DMake([self.location.latitude doubleValue], [self.location.longitude doubleValue]);
        [mapView setCenterCoordinate:customLoc2D_5 animated:false];
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(customLoc2D_5, 1000, 1000);
        MKCoordinateRegion adjustedRegion = [mapView regionThatFits:region];
        [mapView setRegion:adjustedRegion animated:false];
        [mapView removeAnnotations:mapView.selectedAnnotations];
        [mapView selectAnnotation:[LocationAnnotation annotationForLocation:self.location ShowTitle:false] animated:false];
    }else{
        showMap = NO;
        MKMapView *mapView = (MKMapView *)[self.view viewWithTag:TAG_MAPVIEW];
        if (mapView) {
            mapView.frame = CGRectZero;
        }
    }
}

- (void)showLargeMap
{
    LocationMapViewController *mapViewController = [[LocationMapViewController alloc] init];
    mapViewController.location = self.location;
    mapViewController.index = self.locationIndex;
    [self.navigationController pushViewController:mapViewController animated:YES];
}

- (void)configureNameScroll
{
    UIImageView *categoryImage = (UIImageView *)[self.view viewWithTag:TAG_CATEGORY_IMAGE];
    if (!categoryImage) {
        categoryImage = [[UIImageView alloc] init];
        categoryImage.tag = TAG_CATEGORY_IMAGE;
        categoryImage.contentMode = UIViewContentModeCenter;
        [self.view addSubview:categoryImage];
    }
    categoryImage.image = [Location getCategoryIconLarge:self.location.category];
    categoryImage.frame = CGRectMake(10, showMap? MAP_VIEW_HEIGHT+INFO_VIEW_HEIGHT : INFO_VIEW_HEIGHT, NAME_SCROLL_HEIGHT, NAME_SCROLL_HEIGHT);

    FadeScrollView *nameScroll = (FadeScrollView *)[self.view viewWithTag:TAG_NAMESCROLL];
    if (!nameScroll) {
        nameScroll = [[FadeScrollView alloc] init];
        nameScroll.tag = TAG_NAMESCROLL;
        nameScroll.showsHorizontalScrollIndicator = FALSE;
        nameScroll.showsVerticalScrollIndicator = FALSE;
        [self.view addSubview:nameScroll];
    }
    nameScroll.frame = CGRectMake(10+NAME_SCROLL_HEIGHT+5, showMap? MAP_VIEW_HEIGHT+INFO_VIEW_HEIGHT : INFO_VIEW_HEIGHT, self.view.frame.size.width - NAME_SCROLL_HEIGHT - 15, NAME_SCROLL_HEIGHT);
        
    UILabel *nameLabel = (UILabel *)[nameScroll viewWithTag:TAG_NAMELABEL];
    if (!nameLabel) {
        nameLabel = [[UILabel alloc] init];
        nameLabel.tag = TAG_NAMELABEL;
        nameLabel.textColor = [UIColor colorWithRed:72/255.0 green:70/255.0 blue:66/255.0 alpha:1.0];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:16];
        [nameScroll addSubview:nameLabel];
    }
                
    UILabel *eNameLabel = (UILabel *)[nameScroll viewWithTag:TAG_ENAMELABEL];
    if (!eNameLabel) {
        eNameLabel = [[UILabel alloc] init];
        eNameLabel.tag = TAG_ENAMELABEL;
        eNameLabel.textColor = [UIColor colorWithRed:153/255.0 green:150/255.0 blue:145/255.0 alpha:1.0];
        eNameLabel.backgroundColor = [UIColor clearColor];
        eNameLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:12];
        [nameScroll addSubview:eNameLabel];
    }
    
    UILabel *addressLabel = (UILabel *)[nameScroll viewWithTag:TAG_ADDRESSLABEL];
    if (!addressLabel) {
        addressLabel = [[UILabel alloc] init];
        addressLabel.tag = TAG_ADDRESSLABEL;
        addressLabel.textColor = [UIColor colorWithRed:153/255.0 green:150/255.0 blue:145/255.0 alpha:1.0];
        addressLabel.backgroundColor = [UIColor clearColor];
        addressLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:12];
        [nameScroll addSubview:addressLabel];
    }

    CGPoint nameLabelOrigin = CGPointMake(0, 5);
    CGPoint nameEnLabelOrigin = CGPointMake(0, 25);
    CGPoint addressLabelOrigin = CGPointMake(0, 40);
    if (self.location.nameEn.length == 0 && self.location.address.length == 0) {
        nameLabelOrigin = CGPointMake(0, 20);
    } else if (self.location.nameEn.length == 0) {
        nameLabelOrigin = CGPointMake(0, 10);
        addressLabelOrigin = CGPointMake(0, 35);
    } else if (self.location.address.length == 0) {
        nameLabelOrigin = CGPointMake(0, 10);
        nameEnLabelOrigin = CGPointMake(0, 35);
    }
    
    nameLabel.frame = CGRectMake(nameLabelOrigin.x, nameLabelOrigin.y, self.view.frame.size.width, NAME_LABEL_HEIGHT);
    nameLabel.text = [self.location getNameAndCity];
    [nameLabel sizeToFit];
    
    
    eNameLabel.frame = CGRectMake(nameEnLabelOrigin.x, nameEnLabelOrigin.y, self.view.frame.size.width, NAME_LABEL_HEIGHT);
    eNameLabel.text = self.location.nameEn;
    [eNameLabel sizeToFit];
    
    
    addressLabel.frame = CGRectMake(addressLabelOrigin.x, addressLabelOrigin.y, self.view.frame.size.width, ADDRESS_LABEL_HEIGHT);
    addressLabel.text = self.location.address;
    [addressLabel sizeToFit];
    
    CGFloat nameWidth = nameLabel.frame.size.width;
    CGFloat eNameWidth = eNameLabel.frame.size.width;
    CGFloat addressWidth = addressLabel.frame.size.width;
    
    CGFloat contentWidht = MAX(nameWidth, MAX(eNameWidth, addressWidth));
    if (contentWidht > nameScroll.bounds.size.width) {
        contentWidht += nameScroll.bounds.size.width * 0.15; //15%的区域会渐隐，加上这段好让最右边的字也能全部显示出来
    }
    nameScroll.contentSize = CGSizeMake(contentWidht, nameScroll.frame.size.height);
    
    if(self.location.useradd){
        UIButton *editLocationBtn = (UIButton *)[nameScroll viewWithTag:TAG_EDITBUTTON];
        if (!editLocationBtn) {
            editLocationBtn = [[UIButton alloc] init];
            editLocationBtn.tag = TAG_EDITBUTTON;
            [editLocationBtn setImage:[UIImage imageNamed:@"edit.png"] forState:UIControlStateNormal];
            [editLocationBtn setAlpha:1];
            editLocationBtn.backgroundColor = [UIColor colorWithRed:244/255.0 green:241/255.0 blue:235/255.0 alpha:1.0];
            [editLocationBtn addTarget:self action:@selector(editLocationCoordinate:) forControlEvents:UIControlEventTouchDown];
            [nameScroll addSubview:editLocationBtn];
        }
        editLocationBtn.frame = CGRectMake(nameScroll.frame.size.width*0.9-55,0,60,60);
    }else{
        UIButton *editLocationBtn = (UIButton *)[nameScroll viewWithTag:TAG_EDITBUTTON];
        if (editLocationBtn) {
            editLocationBtn.frame = CGRectZero;
        }
    }
}

- (IBAction) editLocationCoordinate:(id)sender
{
    AddLocationViewController *addLocationViewController = [[AddLocationViewController alloc] init];
    addLocationViewController.location = [[Location alloc] init];
    addLocationViewController.location.name = self.location.name;
    addLocationViewController.location.category = self.location.category;
    addLocationViewController.location.locationId = self.location.locationId;
    addLocationViewController.addLocation = NO;
    
    if(showMap)
    {
        addLocationViewController.location.latitude = self.location.latitude;
        addLocationViewController.location.longitude = self.location.longitude;
        addLocationViewController.hasCoordinate = YES;
    }
    else
    {
        addLocationViewController.hasCoordinate = NO;
    }
    addLocationViewController.editLocationDelegate = self;
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:addLocationViewController];
    [self presentViewController:navController animated:YES completion:NULL];
}

//Implement AddLocationViewControllerDelegate
-(void) AddLocationViewController:(AddLocationViewController *) addLocationViewController didFinishEdit:(Location *)location name:(BOOL)nameChanged coordinate:(BOOL)coordinateChanged
{
    self.location.name = location.name;
    self.location.latitude = location.latitude;
    self.location.longitude = location.longitude;
    [self configureView];
    
    [self.delegate didChangeLocation:self.location];
}

-(void) configureTable
{
    UITableView *tableView = (UITableView *)[self.view viewWithTag:TAG_TABLEVIEW];
    if (!tableView) {
        tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        tableView.tag = TAG_TABLEVIEW;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.backgroundView = nil;
        [self.view addSubview:tableView];
    }
    NSInteger tableviewHeight = showMap ? self.view.frame.size.height-MAP_VIEW_HEIGHT-NAME_SCROLL_HEIGHT-INFO_VIEW_HEIGHT:self.view.frame.size.height-NAME_SCROLL_HEIGHT-INFO_VIEW_HEIGHT;
    tableView.frame = CGRectMake(0, showMap? MAP_VIEW_HEIGHT+NAME_SCROLL_HEIGHT+INFO_VIEW_HEIGHT : NAME_SCROLL_HEIGHT+INFO_VIEW_HEIGHT, self.view.frame.size.width, tableviewHeight);
    [tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section == 0 ? [self.location numberOfRowsInInfoSection] : 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.section == 0) {
        NSString *CellIdentifier = @"LocationInfoCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[LocationTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.font = [UIFont systemFontOfSize:FONT_SIZE];
            cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
            cell.textLabel.numberOfLines = 0;
        }
        cell.textLabel.text = [self.location contentForRow:indexPath.row];
        cell.imageView.image = [UIImage imageNamed:[self.location imageNameForRow:indexPath.row]];
        if ([[cell.textLabel.text lowercaseString] rangeOfString:@"http"].location == 0) {
            cell.textLabel.userInteractionEnabled = YES;
            
            UITapGestureRecognizer *gestureRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openUrl:)];
            gestureRec.numberOfTouchesRequired = 1;
            gestureRec.numberOfTapsRequired = 1;
            [cell.textLabel addGestureRecognizer:gestureRec];
        }
    } else {
        if (indexPath.row == 0) {
            NSString *CellIdentifier = @"ArriveTimeCell";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.textLabel.font = [UIFont systemFontOfSize:FONT_SIZE];
                cell.imageView.image = [UIImage imageNamed:@"location_time.png"];
            }
            if(self.location.visitBegin){
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateStyle:NSDateFormatterNoStyle];
                [formatter setTimeStyle:NSDateFormatterShortStyle];
                cell.textLabel.text = [NSString stringWithFormat:@"到达时间：%@", [formatter stringFromDate:self.location.visitBegin]];
            }else{
                cell.textLabel.text = @"设定到达时间";
            }
        } else if (indexPath.row == 1) {
            NSString *CellIdentifier = @"NoteCell";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[LocationTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.textLabel.font = [UIFont systemFontOfSize:FONT_SIZE];
                cell.textLabel.numberOfLines = 4;
                cell.imageView.image = [UIImage imageNamed:@"location_note.png"];
            }
            if (self.location.detail.length > 0) {
                cell.textLabel.text = self.location.detail;
            }else{
                cell.textLabel.text = @"添加备注";
            }
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        NSString *content = [self.location contentForRow:indexPath.row];
        CGSize constraint = CGSizeMake(tableView.bounds.size.width - 80, 20000.0f);
        CGSize size = [content sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
        CGFloat height = MAX(size.height + 10, 44.0f);
        return height;
    } else {
        if (indexPath.row == 0) {
            //到达时间
            return 44;
        } else {
            NSString *content = self.location.detail;
            CGSize constraint = CGSizeMake(tableView.bounds.size.width - 80, 20000.0f);
            CGSize size = [content sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
            CGFloat height = MAX(size.height + 10, 44.0f);
            return height;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle: nil];
            EditScheduleViewController *scheduleViewController = [storyboard instantiateViewControllerWithIdentifier:@"EditScheduleStoryBoard"];
            scheduleViewController.start = self.location.visitBegin;
            scheduleViewController.delegate = self;
            [self.navigationController pushViewController:scheduleViewController animated:YES];
        } else if (indexPath.row == 1) {
            EditDetailViewController *detailViewController = [[EditDetailViewController alloc] init];
            detailViewController.detail = self.location.detail;
            detailViewController.delegate = self;
            [self.navigationController pushViewController:detailViewController animated:YES];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UITableView *tableView = (UITableView *)[self.view viewWithTag:TAG_TABLEVIEW];
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
}

-(void) didEditScheduleWithStart:(NSDate *)start AndEnd:(NSDate *)end
{
    self.location.visitBegin = start;
    [((UITableView *)[self.view viewWithTag:TAG_TABLEVIEW]) reloadData];
    [self.delegate didChangeLocation:self.location];
}

-(void) didEditDetail:(NSString *)detail
{
    self.location.detail = detail;
    [((UITableView *)[self.view viewWithTag:TAG_TABLEVIEW]) reloadData];
    [self.delegate didChangeLocation:self.location];
}

- (void)openUrl:(UIGestureRecognizer*)gestureRecognizer
{
    UILabel *urlLabel = (UILabel *)gestureRecognizer.view;
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlLabel.text]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
