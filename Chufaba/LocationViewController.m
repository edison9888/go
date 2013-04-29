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
#import "QuartzCore/QuartzCore.h"

@interface LocationViewController ()
{
    BOOL showMap;
    UIView *tableHeaderView;
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
#define TAG_PREVBTN 18
#define TAG_NEXTBTN 19
#define TAG_TABLEHEADER 20

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
    self.categoryImage = [NSDictionary dictionaryWithObjectsAndKeys:@"sight", @"景点", @"food", @"美食", @"hotel", @"住宿", @"more", @"其它", @"pin_sight", @"景点m", @"pin_food", @"美食m", @"pin_hotel", @"住宿m", @"pin_more", @"其它m", nil];
    
    self.view.backgroundColor = [UIColor colorWithRed:244/255.0 green:241/255.0 blue:235/255.0 alpha:1.0];
    
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 7, 40, 30)];
    [backBtn setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backToPrevious:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = btn;
    
    [self configureView];
    
    UIView *pullView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, -MAP_VIEW_HEIGHT * 3-60, 320, 60)];
    UIImageView *pullImgView = [[UIImageView alloc] initWithFrame:CGRectMake(124, 10, 72, 40)];
    pullImgView.image = [UIImage imageNamed:@"pull_bg.png"];
    [pullView addSubview:pullImgView];
    UITableView *tableView = (UITableView *)[self.view viewWithTag:TAG_TABLEVIEW];
    [tableView addSubview:pullView];
}

- (IBAction)backToPrevious:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)configureView
{
    if (self.location) {
        self.navigationItem.title = self.location.name;
        [self configureSegment];
        [self configureTable];
        [self configureDate];
        
        tableHeaderView = [self.view viewWithTag:TAG_TABLEHEADER];
        if (!tableHeaderView) {
            tableHeaderView = [[UIView alloc] init];
            tableHeaderView.tag = TAG_TABLEHEADER;
        }
        [self configureMap];
        [self configureNameScroll];
        CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, NAME_SCROLL_HEIGHT + 5);
        if (showMap) {
            frame.size.height += MAP_VIEW_HEIGHT;
        }
        tableHeaderView.frame = frame;
        UITableView *tableView = (UITableView *)[self.view viewWithTag:TAG_TABLEVIEW];
        [tableView setTableHeaderView: tableHeaderView];
    }
}

- (void)configureSegment
{
    UIView *segmentedControl = (UIView *)[self.view viewWithTag:TAG_SEGMENT];
    if (!segmentedControl) {
        segmentedControl = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 30)];
        UIButton *prevBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 30)];
        [prevBtn setImage:[UIImage imageNamed:@"prevLoc.png"] forState:UIControlStateNormal];
        [prevBtn setImage:[UIImage imageNamed:@"prevLocDis.png"] forState:UIControlStateDisabled];
        [prevBtn setImage:[UIImage imageNamed:@"prevLocClick.png"] forState:UIControlStateHighlighted];
        UIButton *nextBtn = [[UIButton alloc] initWithFrame:CGRectMake(40, 0, 40, 30)];
        [nextBtn setImage:[UIImage imageNamed:@"nextLoc.png"] forState:UIControlStateNormal];
        [nextBtn setImage:[UIImage imageNamed:@"nextLocDis.png"] forState:UIControlStateDisabled];
        [nextBtn setImage:[UIImage imageNamed:@"nextLocClick.png"] forState:UIControlStateHighlighted];
        
        [prevBtn addTarget:self action:@selector(prevLocation:) forControlEvents:UIControlEventTouchUpInside];
        [nextBtn addTarget:self action:@selector(nextLocation:) forControlEvents:UIControlEventTouchUpInside];

        prevBtn.tag = TAG_PREVBTN;
        [segmentedControl addSubview:prevBtn];
        nextBtn.tag = TAG_NEXTBTN;
        [segmentedControl addSubview:nextBtn];
        
        UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
        self.navigationItem.rightBarButtonItem = segmentBarItem;
    }
    if(self.locationIndex == 0){
        [(UIButton *)[segmentedControl viewWithTag:TAG_PREVBTN] setEnabled:NO];
    }else{
        [(UIButton *)[segmentedControl viewWithTag:TAG_PREVBTN] setEnabled:YES];
    }
    if (self.locationIndex == self.totalLocationCount-1) {
        [(UIButton *)[segmentedControl viewWithTag:TAG_NEXTBTN] setEnabled:NO];
    }else{
        [(UIButton *)[segmentedControl viewWithTag:TAG_NEXTBTN] setEnabled:YES];
    }
}

- (IBAction) prevLocation:(id)sender
{
    if(self.locationIndex > 0)
    {
        self.locationIndex--;
        self.location = [self.navDelegate getPreviousLocation:self.location];
        [self configureView];
    }
}

- (IBAction) nextLocation:(id)sender
{
    if(self.locationIndex < self.totalLocationCount - 1)
    {
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
        infoView.backgroundColor = [UIColor colorWithRed:223/255.0 green:215/255.0 blue:198/255.0 alpha:1.0];
        infoView.tag = TAG_INFOVIEW;
        [self.view addSubview:infoView];
        
        CAGradientLayer *viewShadow = [[CAGradientLayer alloc] init];
        CGRect viewShadowFrame = CGRectMake(-5, 0, infoView.frame.size.width + 10, infoView.frame.size.height);
        viewShadow.frame = viewShadowFrame;
        viewShadow.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithRed:230/255.0 green:223/255.0 blue:209/255.0 alpha:1.0].CGColor,(id)[UIColor colorWithRed:227/255.0 green:219/255.0 blue:204/255.0 alpha:1.0].CGColor,nil];
        [infoView.layer addSublayer:viewShadow];
        
        infoView.layer.shadowPath = [UIBezierPath bezierPathWithRect:infoView.bounds].CGPath;
        infoView.layer.masksToBounds = NO;
        infoView.layer.shadowColor = [UIColor blackColor].CGColor;
        infoView.layer.shadowOffset = CGSizeMake(0, 1);
        infoView.layer.shadowOpacity = 0.3;
        infoView.layer.shouldRasterize = YES;
        infoView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    }
    [self.view bringSubviewToFront:infoView];
    
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

-(void) configureTable
{
    UITableView *tableView = (UITableView *)[self.view viewWithTag:TAG_TABLEVIEW];
    NSInteger tableviewHeight;
    if (!tableView) {
        tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        tableView.tag = TAG_TABLEVIEW;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.backgroundView = nil;
        tableView.separatorColor = [UIColor colorWithRed:227/255.0 green:219/255.0 blue:204/255.0 alpha:1.0];
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        [self.view addSubview:tableView];
        tableviewHeight = self.view.frame.size.height-INFO_VIEW_HEIGHT-self.navigationController.navigationBar.frame.size.height;
    } else {
        tableviewHeight = self.view.frame.size.height-INFO_VIEW_HEIGHT;
    }
    tableView.frame = CGRectMake(0, INFO_VIEW_HEIGHT, self.view.frame.size.width, tableviewHeight);
    [tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.location numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.location numberOfSections] == 2 && section == 0) {
        return [self.location numberOfRowsInInfoSection];
    } else {
        return 2;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LocationTableViewCell *cell;
    UIImageView *bgColorView;
    if ([self.location numberOfSections] == 2 && indexPath.section == 0) {
        NSString *CellIdentifier = @"LocationInfoCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[LocationTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            //cell.textLabel.font = [UIFont systemFontOfSize:FONT_SIZE];
            cell.textLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:13];
            cell.textLabel.textColor = [UIColor colorWithRed:72/255.0 green:70/255.0 blue:66/255.0 alpha:1.0];
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
    }
    else
    {
        if (indexPath.row == 0) {
            NSString *CellIdentifier = @"ArriveTimeCell";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[LocationTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.textLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:13];
                cell.imageView.image = [UIImage imageNamed:@"time.png"];
            }
            if(self.location.visitBegin){
                cell.textLabel.text = [NSString stringWithFormat:@"到达时间：%@", self.location.visitBegin];
                cell.textLabel.textColor = [UIColor colorWithRed:72/255.0 green:70/255.0 blue:66/255.0 alpha:1.0];
                cell.textLabel.highlightedTextColor = [UIColor colorWithRed:72/255.0 green:70/255.0 blue:66/255.0 alpha:1.0];
            }else{
                cell.textLabel.text = @"设定到达时间";
                cell.textLabel.textColor = [UIColor colorWithRed:153/255.0 green:150/255.0 blue:145/255.0 alpha:1.0];
                cell.textLabel.highlightedTextColor = [UIColor colorWithRed:153/255.0 green:150/255.0 blue:145/255.0 alpha:1.0];
            }
            bgColorView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"cell_bg.png"] stretchableImageWithLeftCapWidth:8 topCapHeight:8]];
        } else if (indexPath.row == 1) {
            NSString *CellIdentifier = @"NoteCell";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[LocationTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.textLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:13];
                cell.textLabel.numberOfLines = 4;
                cell.imageView.image = [UIImage imageNamed:@"remark.png"];
            }
            if (self.location.detail.length > 0) {
                cell.textLabel.text = self.location.detail;
                cell.textLabel.textColor = [UIColor colorWithRed:72/255.0 green:70/255.0 blue:66/255.0 alpha:1.0];
                cell.textLabel.highlightedTextColor = [UIColor colorWithRed:72/255.0 green:70/255.0 blue:66/255.0 alpha:1.0];
            }else{
                cell.textLabel.text = @"添加备注";
                cell.textLabel.textColor = [UIColor colorWithRed:153/255.0 green:150/255.0 blue:145/255.0 alpha:1.0];
                cell.textLabel.highlightedTextColor = [UIColor colorWithRed:153/255.0 green:150/255.0 blue:145/255.0 alpha:1.0];
            }
            bgColorView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"cell_bgb.png"] stretchableImageWithLeftCapWidth:8 topCapHeight:8]];
        }
        cell.accessoryView = [[ UIImageView alloc] initWithImage:[UIImage imageNamed:@"detailsmall.png"]];
    }
    [cell setSelectedBackgroundView:bgColorView];
    cell.backgroundColor = [UIColor whiteColor];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.location numberOfSections] == 2 && indexPath.section == 0) {
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
            CGFloat height = MIN(MAX(size.height + 10, 44.0f), 74.0f);
            return height;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.location numberOfSections] == 1 || indexPath.section == 1) {
        if (indexPath.row == 0) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle: nil];
            EditScheduleViewController *scheduleViewController = [storyboard instantiateViewControllerWithIdentifier:@"EditScheduleStoryBoard"];
            scheduleViewController.start = [self.location getArrivalTime];
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

-(void) didEditScheduleWithStart:(NSDate *)start
{
    [self.location setArrivalTime:start];
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
            [tableHeaderView addSubview:mapView];
            
            button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.tag = TAG_MAPBTN;
            [tableHeaderView addSubview:button];
            [button addTarget:self action:@selector(showLargeMap) forControlEvents:UIControlEventTouchUpInside];
        }
        mapView.frame = CGRectMake(0, -MAP_VIEW_HEIGHT * 3, self.view.frame.size.width, MAP_VIEW_HEIGHT*4);
        if (!button) {
            button = (UIButton *)[self.view viewWithTag:TAG_MAPBTN];
        }
        [button setFrame:mapView.frame];
        
        //中心偏上，好让标记能显示在可视区域中间
        CLLocationCoordinate2D customLoc2D_5 = CLLocationCoordinate2DMake([self.location.latitude doubleValue] + 0.0035, [self.location.longitude doubleValue]);
        [mapView setCenterCoordinate:customLoc2D_5 animated:false];
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(customLoc2D_5, 1000, 1000);
        MKCoordinateRegion adjustedRegion = [mapView regionThatFits:region];
        [mapView setRegion:adjustedRegion animated:false];
        [mapView removeAnnotations:mapView.annotations];
        [mapView addAnnotation:[LocationAnnotation annotationForLocation:self.location ShowTitle:true]];
        //[mapView selectAnnotation:[LocationAnnotation annotationForLocation:self.location ShowTitle:false] animated:false];
        
        CALayer *bottomBorder = [CALayer layer];
        bottomBorder.frame = CGRectMake(0, MAP_VIEW_HEIGHT * 4 - 1, self.view.frame.size.width, 2);
        bottomBorder.backgroundColor = [UIColor whiteColor].CGColor;
        [mapView.layer addSublayer:bottomBorder];
    }else{
        showMap = NO;
        MKMapView *mapView = (MKMapView *)[self.view viewWithTag:TAG_MAPVIEW];
        if (mapView) {
            mapView.frame = CGRectZero;
        }
    }
}

#define LOCATION_ANNOTATION_VIEWS @"LocationAnnotationViews"

- (MKAnnotationView *)mapView:(MKMapView *)sender viewForAnnotation:(id <MKAnnotation>)annotation
{
    MKAnnotationView *aView = [sender dequeueReusableAnnotationViewWithIdentifier:LOCATION_ANNOTATION_VIEWS];
    
	if (!aView)
    {
        aView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:LOCATION_ANNOTATION_VIEWS];
        aView.image = [UIImage imageNamed:[self.categoryImage objectForKey:[self.location.category stringByAppendingString:@"m"]]];
        aView.annotation = annotation;
	}
	return aView;
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
        [tableHeaderView addSubview:categoryImage];
    }
    categoryImage.image = [UIImage imageNamed:[self.categoryImage objectForKey: self.location.category]];
    categoryImage.frame = CGRectMake(3, showMap? MAP_VIEW_HEIGHT + 8 : 8, NAME_SCROLL_HEIGHT, NAME_SCROLL_HEIGHT);

    FadeScrollView *nameScroll = (FadeScrollView *)[self.view viewWithTag:TAG_NAMESCROLL];
    if (!nameScroll) {
        nameScroll = [[FadeScrollView alloc] init];
        nameScroll.tag = TAG_NAMESCROLL;
        nameScroll.showsHorizontalScrollIndicator = FALSE;
        nameScroll.showsVerticalScrollIndicator = FALSE;
        [tableHeaderView addSubview:nameScroll];
    }
    NSInteger nameScrollWidth = self.view.frame.size.width - NAME_SCROLL_HEIGHT;
    if (self.location.useradd) {
        nameScrollWidth -= 31;
    }
    nameScroll.frame = CGRectMake(3 + NAME_SCROLL_HEIGHT, showMap? MAP_VIEW_HEIGHT + 5 : 5, nameScrollWidth, NAME_SCROLL_HEIGHT);
        
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
    CGPoint nameEnLabelOrigin = CGPointMake(0, 26);
    CGPoint addressLabelOrigin = CGPointMake(0, 42);
    if (self.location.nameEn.length == 0 && self.location.address.length == 0) {
        nameLabelOrigin = CGPointMake(0, 22);
    } else if (self.location.nameEn.length == 0) {
        nameLabelOrigin = CGPointMake(0, 13);
        addressLabelOrigin = CGPointMake(0, 37);
    } else if (self.location.address.length == 0) {
        nameLabelOrigin = CGPointMake(0, 13);
        nameEnLabelOrigin = CGPointMake(0, 37);
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
    
    UIButton *editLocationBtn = (UIButton *)[self.view viewWithTag:TAG_EDITBUTTON];
    if(self.location.useradd){
        if (!editLocationBtn) {
            editLocationBtn = [[UIButton alloc] init];
            editLocationBtn.tag = TAG_EDITBUTTON;
            [editLocationBtn setImage:[UIImage imageNamed:@"edit.png"] forState:UIControlStateNormal];
            [editLocationBtn setAlpha:1];
            editLocationBtn.backgroundColor = [UIColor colorWithRed:244/255.0 green:241/255.0 blue:235/255.0 alpha:1.0];
            [editLocationBtn addTarget:self action:@selector(editLocationCoordinate:) forControlEvents:UIControlEventTouchDown];
            [tableHeaderView addSubview:editLocationBtn];
        }
        editLocationBtn.frame = CGRectMake(self.view.frame.size.width - 31,nameScroll.frame.origin.y+17,21,21);
    }else{
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
