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

@interface ItineraryViewController () {
    NSNumber *lastLatitude;
    NSNumber *lastLongitude;
    BOOL isEmptyItinerary;
}

@end

@implementation ItineraryViewController

- (NSDateFormatter *)dateFormatter {
    if (! _dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = @"YYYY.MM.d/EEE";
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

#define ADDING_CELL @"Continue..."
#define DONE_CELL @"Done"
#define DUMMY_CELL @"Dummy"
#define COMMITING_CREATE_CELL_HEIGHT 60
#define NORMAL_CELL_FINISHING_HEIGHT 60
#define DAY_FILTER_FONT_SIZE 20
#define TAG_DAY_FILTER_ARROW 1
#define TAG_LINE_VIEW 10000
#define TAG_DETAIL_INDICATOR 10001

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    isEmptyItinerary = [_plan locationCount] == 0;
    
    self.categoryImage = [NSDictionary dictionaryWithObjectsAndKeys:@"sight40", @"景点", @"food40", @"美食", @"hotel40", @"住宿", @"more40", @"其它", nil];
    
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 7, 40, 30)];
    [backBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backBtn setImage:[UIImage imageNamed:@"back_click"] forState:UIControlStateHighlighted];
    [backBtn addTarget:self action:@selector(backToPrevious:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = btn;
    
    UIButton *addBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 7, 40, 30)];
    [addBtn setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
    [addBtn setImage:[UIImage imageNamed:@"add_click"] forState:UIControlStateHighlighted];
    [addBtn addTarget:self action:@selector(pushSearchViewController:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rBtn = [[UIBarButtonItem alloc] initWithCustomView:addBtn];
    self.navigationItem.rightBarButtonItem = rBtn;
    
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
    self.tableView.sectionHeaderHeight = 30.0f;


    self.tableView.frame = CGRectMake(0, 0, 320, self.view.bounds.size.height-44);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableViewRecognizer = [self.tableView enableGestureTableViewWithDelegate:self];
    
    if (pullDownMenuView == nil)
    {
        PullDownMenuView *view = [[PullDownMenuView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
        view.delegate = self;
        [self.tableView addSubview:view];
        pullDownMenuView = view;
    }
    
    [self.view addSubview:self.tableView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(100,0,120,30)];
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
    
//    NSInteger scrollSection = [self daySequence:[NSDate date]];
//    if(scrollSection >= 0)
//    {
//        [self.tableView reloadData];
//        if([self.tableView numberOfRowsInSection:scrollSection] > 0)
//        {
//            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:scrollSection] atScrollPosition:UITableViewScrollPositionTop animated:NO];
//        }
//        else
//        {
//            CGRect sectionRect = [self.tableView rectForSection:scrollSection];
//            sectionRect.origin.y = sectionRect.origin.y;
//            sectionRect.size.height = self.tableView.frame.size.height;
//            [self.tableView scrollRectToVisible:sectionRect animated:YES];
//        }
//    }
    
    [self updateFooterView];
}

- (IBAction)backToPrevious:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [pullDownMenuView pdmScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [pullDownMenuView pdmScrollViewDidEndDragging:scrollView];
}

#pragma mark JTTableViewGestureMoveRowDelegate

- (BOOL)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer needsCreatePlaceholderForRowAtIndexPath:(NSIndexPath *)indexPath
{
    _grabbingFrom = indexPath;
    _grabbingLocation = [self getLocationAtIndexPath:indexPath];
}

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer needsMoveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    [_plan moveThisLocation:[self getLocationAtIndexPath:sourceIndexPath] ToThatLocation:[self getLocationAtIndexPath:destinationIndexPath]];
}

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer needsReplacePlaceholderForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_plan persistentReorderFromThisLocation:[self getLocationAtIndexPath:_grabbingFrom] ToThatLocation:[self getLocationAtIndexPath:indexPath]];
    _grabbingFrom = nil;
    _grabbingLocation = nil;
    [self updateFooterView];
}

//Implement PullDownMenuView delegate
- (void) switchToMapMode:(PullDownMenuView *)view
{
    //self.tableView.contentInset = UIEdgeInsetsZero;
    MapViewController *mapViewController = [[MapViewController alloc] init];
    mapViewController.delegate = self;
    mapViewController.plan = _plan;
    mapViewController.daySelected = self.daySelected.integerValue;
    mapViewController.singleDayMode = singleDayMode;
    
    [self.navigationController pushViewController:mapViewController animated:YES];
}

- (void)editLocationsSequence:(PullDownMenuView *)view
{
    EditItineraryViewController *editViewController = [[EditItineraryViewController alloc] init];
    if(singleDayMode)
    {
        editViewController.singleDayMode = TRUE;
    }
    else
    {
        editViewController.singleDayMode = FALSE;
    }
    editViewController.delegate = self;
    editViewController.plan = self.plan;
    editViewController.daySelected = self.daySelected;
    [self.navigationController pushViewController:editViewController animated:YES];
}

- (void) startSynchronize:(PullDownMenuView *)view
{
    [self.plan sync];
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
    for(int i=0; i<[_plan.duration intValue]; i++)
    {
        [arr addObject:[NSString stringWithFormat:@"Day%d", i+1]];
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
        
        CGFloat f = ([_plan.duration intValue]+1)*40;
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

//Implement UIActionSheetDeleg
//-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
//    self.tableView.contentInset = UIEdgeInsetsZero;
//    if(buttonIndex == 0)
//    {        
//        ShareViewController *shareController = [[ShareViewController alloc] init];
//        shareController.accountManager.delegate = shareController;
//        
//        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:shareController];
//        [self presentViewController:navigationController animated:YES completion: nil];
//    }
//    else if(buttonIndex == 1)
//    {
//
//    }
//    else if(buttonIndex == 2)
//    {
//
//    }
//}

//DropDownDelegate
- (void) niDropDownDelegateMethod: (NIDropDown *) sender selectRow:(NSInteger)rowIndex
{
    UIButton *dayFilterBtn = (UIButton *)self.navigationItem.titleView;
    CGSize stringsize = [dayFilterBtn.titleLabel.text sizeWithFont:[UIFont systemFontOfSize:DAY_FILTER_FONT_SIZE]];
    UIImageView *dayFilterImg = (UIImageView *)[dayFilterBtn viewWithTag:TAG_DAY_FILTER_ARROW];
    dayFilterImg.frame = CGRectMake(dayFilterBtn.titleLabel.frame.origin.x + stringsize.width + 3, dayFilterImg.frame.origin.y, dayFilterImg.frame.size.width, dayFilterImg.frame.size.height );
    dropDown = nil;

    [[self.view viewWithTag:55] removeFromSuperview];
    singleDayMode = rowIndex > 0;
    self.daySelected = [NSNumber numberWithInt:rowIndex - 1];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void) didChangeLocation:(Location *)location
{
    [location save];
    [self.tableView reloadData];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return singleDayMode ? 1 : [_plan.duration integerValue];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(isEmptyItinerary && section == 0)
    {
        return  1;
    }
    return [_plan getLocationCountFromDay:[self getDayBySection:section]];
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
            UIImageView *implyImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"t"]];
            implyImage.frame = CGRectMake(60,4,238,50);
            [cell.contentView addSubview:implyImage];
            cell.userInteractionEnabled = NO;
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
        
        Location *locationAtIndex = [self getLocationAtIndexPath:indexPath];
        if (locationAtIndex == _grabbingLocation)
        {
            cell.textLabel.text = @"";
            cell.detailTextLabel.text = @"";
            cell.imageView.image = NULL;
            cell.accessoryView = NULL;
            cell.contentView.backgroundColor = [UIColor clearColor];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        else
        {
            cell.textLabel.text = [locationAtIndex getTitle];
            if (locationAtIndex.visitBegin)
            {
                cell.detailTextLabel.text = locationAtIndex.visitBegin;
            }
            else
            {
                cell.detailTextLabel.text = @"";
            }
            cell.imageView.image = [UIImage imageNamed:[self.categoryImage objectForKey: locationAtIndex.category]];
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"detailsmall"]];
            
            if([cell.contentView viewWithTag:TAG_DETAIL_INDICATOR])
            {
                [[cell.contentView viewWithTag:TAG_DETAIL_INDICATOR] removeFromSuperview];
            }
            
            if(locationAtIndex.detail.length)
            {
                CGSize expectedLabelSize = [cell.textLabel.text sizeWithFont:cell.textLabel.font constrainedToSize:CGSizeMake(200,18) lineBreakMode:cell.textLabel.lineBreakMode];
                
                UIImageView *detailIndicator = [[UIImageView alloc] initWithFrame:CGRectMake(expectedLabelSize.width+44, 8, 12, 12)];
                detailIndicator.image = [UIImage imageNamed:@"detail_indi"];
                detailIndicator.tag = TAG_DETAIL_INDICATOR;
                [cell.contentView addSubview:detailIndicator];
            }
            
            if([cell.contentView viewWithTag:TAG_LINE_VIEW])
            {
                [[cell.contentView viewWithTag:TAG_LINE_VIEW] removeFromSuperview];
            }
            
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
            lineView.backgroundColor = [UIColor whiteColor];
            lineView.opaque = YES;
            [cell.contentView addSubview:lineView];
            if(locationAtIndex.whichday.integerValue == ([_plan.duration integerValue] - 1) || [_plan hasNextLocation:locationAtIndex FomeSameDay:singleDayMode NeedCoordinate:NO])
            {
                lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 43, 320, 1)];
                lineView.opaque = YES;
                lineView.tag = TAG_LINE_VIEW;
                lineView.backgroundColor = [UIColor colorWithRed:227/255.0 green:219/255.0 blue:204/255.0 alpha:1.0];
                [cell.contentView addSubview:lineView];
            }
        }
//        cell.layer.opaque = YES;
//        cell.layer.shouldRasterize = YES;
//        cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
        return cell;
    }
}

-(void) updateFooterView
{
    if([_plan getLocationCountFromDay:([_plan.duration integerValue] - 1)] > 0)
    {
        if(!self.tableView.tableFooterView)
        {
            UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 1)];
            footerView.backgroundColor = [UIColor whiteColor];
            self.tableView.tableFooterView = footerView;
        }
    }
    else
    {
        if(self.tableView.tableFooterView)
        {
            self.tableView.tableFooterView = NULL;
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSInteger dayValue = singleDayMode ? [self.daySelected intValue] : section;
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setDay:dayValue];
    NSDate *sectionDate = [self.gregorian dateByAddingComponents:offsetComponents toDate:_plan.date options:0];

    UIView *myView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 30.0)];
    UIColor *background = [[UIColor alloc] initWithPatternImage:[[UIImage imageNamed:@"bar_h"] stretchableImageWithLeftCapWidth:8 topCapHeight:0]];
    myView.backgroundColor = background;

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 9.0, 100.0, 16.0)] ;
    label.textColor = [UIColor colorWithRed:128/255.0 green:108/255.0 blue:77/255.0 alpha:1.0];
    label.shadowColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.3];
    label.shadowOffset = CGSizeMake(0, 1);
    label.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:16];
    label.backgroundColor = [UIColor clearColor];
    label.text = [NSString stringWithFormat:@"Day%d", dayValue+1];
    
    UILabel *wLabel = [[UILabel alloc] initWithFrame:CGRectMake(220.0, 9.0, 120.0, 16.0)];
    wLabel.textColor = [UIColor colorWithRed:189/255.0 green:176/255.0 blue:153/255.0 alpha:1.0];
    wLabel.shadowColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.3];
    wLabel.shadowOffset = CGSizeMake(0, 1);
    wLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:12];
    wLabel.backgroundColor = [UIColor clearColor];
    wLabel.text = [self.dateFormatter stringFromDate:sectionDate];
    
    myView.layer.shadowPath = [UIBezierPath bezierPathWithRect:myView.bounds].CGPath;
    myView.layer.shadowOffset = CGSizeMake(0, 1);
    myView.layer.shadowRadius = 0.4;
    myView.layer.shadowColor = [[UIColor colorWithRed:189/255.0 green:176/255.0 blue:153/255.0 alpha:1.0] CGColor];
    myView.layer.shadowOpacity = 1;
    myView.layer.shouldRasterize = YES;
    myView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    [myView addSubview:label];
    [myView addSubview:wLabel];

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
    
    Location *location = [self getLocationAtIndexPath:indexPath];
    locationViewController.location = location;
    locationViewController.plan = _plan;
    locationViewController.navDelegate = self;
    [self.navigationController pushViewController:locationViewController animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    dropDown = nil;
    self.tableView.contentInset = UIEdgeInsetsZero;
    
    if ([[segue identifier] isEqualToString:@"ShowSearch"])
    {
        UINavigationController *navigationController = segue.destinationViewController;
        SearchViewController *searchController = [[navigationController viewControllers] objectAtIndex:0];
        searchController.plan = _plan;
        searchController.searchDelegate = self;
        searchController.locationKeyword = self.plan.destination;
        
        if(singleDayMode)
        {
            searchController.dayToAdd = self.daySelected;
        }
    }
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
//-(void) socialAccountManager:(SocialAccountManager *) manager dismissLoginView:(BOOL) show
//{
//    [self.navigationController popViewControllerAnimated:YES];
//}
//
//-(void) socialAccountManager:(SocialAccountManager *) manager openShareMenu:(NSInteger) loginType
//{
//    if(loginForShare)
//    {
//        self.tableView.contentInset = UIEdgeInsetsZero;
//        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"分享到社交网络", @"分享给微信好友", @"分享到微信朋友圈", nil];
//        actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
//        [actionSheet showInView:self.view];
//    }
//}

//-(NSInteger) daySequence:(NSDate *) date
//{
//    if([date compare: self.plan.date] != NSOrderedAscending)
//    {
//        NSInteger daysBetween = [Utility daysBetweenDate:self.plan.date andDate:date];
//        if(daysBetween < [self.plan.duration intValue])
//        {
//            return daysBetween;
//        }
//        else
//        {
//            return -1;
//        }
//    }
//    else
//    {
//        return -1;
//    }
//    
//}

- (void)tableView:(UITableView *)tableView didSwipeCellAtIndexPath:(NSIndexPath *)indexPath
{
    self.indexPathOfLocationToDelete = indexPath;
}

- (void) deleteLocation
{
    Location *locationToDelete = [self getLocationAtIndexPath:self.indexPathOfLocationToDelete];
    BOOL islastLocation = [_plan hasNextLocation:locationToDelete FomeSameDay:singleDayMode NeedCoordinate:NO];
    [_plan removeLocation:locationToDelete];
    
    //最后一个地点被删除后删除前一个景点的底部横线
    if(islastLocation)
    {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.indexPathOfLocationToDelete.row-1 inSection:self.indexPathOfLocationToDelete.section]];
        if(cell)
        {
            [[cell.contentView viewWithTag:TAG_LINE_VIEW] removeFromSuperview];
        }
        self.tableView.tableFooterView = NULL;
    }
    
    [self.tableView deleteRowsAtIndexPaths:@[self.indexPathOfLocationToDelete] withRowAnimation:UITableViewRowAnimationFade];
    
    [self.itineraryDelegate didDeleteLocationFromPlan];
}

-(void) notifyItinerayToReload:(NSNumber *)lastDay withSeq:(NSNumber *)lastSeq
{
    if(isEmptyItinerary)
    {
        isEmptyItinerary = FALSE;
        self.tableView.rowHeight = 44.0f;
    }
    singleDayMode = FALSE;
    [(UIButton *)self.navigationItem.titleView setTitle:@"全部" forState:UIControlStateNormal];
    [self.tableView reloadData];
    
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[lastSeq intValue] inSection:[lastDay intValue]] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    
    [self updateFooterView];
}

//Implement MapViewControllerDelegate
-(void) didChangeLocationFromMap:(Location *)location
{
    [self didChangeLocation:location];
}

-(void) notifyItinerayRoloadToThisDay:(NSUInteger)day AndMode:(Boolean)single
{
    NSString *title;
    if (single) {
        title = [NSString stringWithFormat:@"Day%d", day+1];
        day += 1;
    } else {
        title = @"全部";
        day = 0;
    }
    [(UIButton *)self.navigationItem.titleView setTitle:title forState:UIControlStateNormal];
    [self niDropDownDelegateMethod:NULL selectRow:day];
}

-(void) notifyItinerayToReload
{
    [self.tableView reloadData];
}

-(Location *)getLocationAtIndexPath:(NSIndexPath *)indexPath
{
    return [_plan getLocationFromDay:[self getDayBySection:indexPath.section] AtIndex:indexPath.row];
}

-(NSUInteger)getDayBySection:(NSInteger)section
{
    NSUInteger day = 0;
    if (singleDayMode) {
        day = [_daySelected integerValue];
    } else {
        day = section;
    }
    return day;
}

@end
