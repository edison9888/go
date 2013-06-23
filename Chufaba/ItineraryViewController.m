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
    NSMutableArray *tempList = [[NSMutableArray alloc] init];
    for (int i = 0; i < [self.plan.duration intValue]; i++)
    {
        NSMutableArray *dayList = [[NSMutableArray alloc] init];
        [tempList addObject:dayList];
    }
    
    FMDatabase *db = [FMDatabase databaseWithPath:[Utility getDatabasePath]];
    
    [db open];
    
    NSNumber *planID = self.plan.planId;
    FMResultSet *results = [db executeQuery:@"SELECT * FROM location,plan WHERE plan_id=? AND plan_id=plan.id order by whichday,seqofday",planID];

    while([results next])
    {
        int dayID = [results intForColumn:@"whichday"]-1;
        Location *location = [[Location alloc] init];
        location.locationId = [NSNumber numberWithInt:[results intForColumnIndex:0]];
        location.planId = self.plan.planId;
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
        [[tempList objectAtIndex:dayID] addObject:location];
    }
    self.dataController.masterTravelDayList = [tempList mutableCopy];
    self.itineraryListBackup = [tempList mutableCopy];
    
    [db close];
    
    oneDimensionLocationList = [self getOneDimensionLocationList];
    [self.itineraryDelegate didAddLocationToPlan];
}

//- (void)reloadDataController
//{
//    FMDatabase *db = [FMDatabase databaseWithPath:[Utility getDatabasePath]];
//    
//    [db open];
//    
//    NSNumber *planID = self.plan.planId;
//    FMResultSet *results = [db executeQuery:@"SELECT * FROM location,plan WHERE plan_id=? AND plan_id=plan.id AND whichday=? order by seqofday",planID, self.dayToAdd];
//
//    NSMutableArray *array = [[NSMutableArray alloc] init];
//    while([results next])
//    {
//        Location *location = [[Location alloc] init];
//        location.locationId = [NSNumber numberWithInt:[results intForColumnIndex:0]];
//        location.planId = self.plan.planId;
//        location.whichday = [NSNumber numberWithInt:[results intForColumn:@"whichday"]];
//        location.seqofday = [NSNumber numberWithInt:[results intForColumn:@"seqofday"]];
//        location.name = [results stringForColumn:@"name"];
//        location.nameEn = [results stringForColumn:@"name_en"];
//        location.country = [results stringForColumn:@"country"];
//        location.city = [results stringForColumn:@"city"];
//        location.address = [results stringForColumn:@"address"];
//        location.transportation = [results stringForColumn:@"transportation"];
//        location.cost = [NSNumber numberWithInt:[results intForColumn:@"cost"]];
//        location.currency = [results stringForColumn:@"currency"];
//        location.visitBegin = [results stringForColumn:@"visit_begin"];
//        location.detail = [results stringForColumn:@"detail"];
//        location.category = [results stringForColumn:@"category"];
//        location.latitude = [NSNumber numberWithDouble:[results doubleForColumn:@"latitude"]];
//        location.longitude = [NSNumber numberWithDouble:[results doubleForColumn:@"longitude"]];
//        location.useradd = [results boolForColumn:@"useradd"];
//        location.poiId = [NSNumber numberWithInt:[results intForColumn:@"poi_id"]];
//        location.opening = [results stringForColumn:@"opening"];
//        location.fee = [results stringForColumn:@"fee"];
//        location.website = [results stringForColumn:@"website"];
//        [array addObject:location];
//    }
//    if(singleDayMode)
//    {
//        [self.dataController.masterTravelDayList replaceObjectAtIndex:0 withObject:array];
//        [self.itineraryListBackup replaceObjectAtIndex:[self.dayToAdd intValue]-1 withObject:array];
//    }
//    else
//    {
//        [self.dataController.masterTravelDayList replaceObjectAtIndex:[self.dayToAdd intValue]-1 withObject:array];
//        [self.itineraryListBackup replaceObjectAtIndex:[self.dayToAdd intValue]-1 withObject:array];
//    }
//    
//    [db close];
//    
//    oneDimensionLocationList = [self getOneDimensionLocationList];
//    [self.itineraryDelegate didAddLocationToPlan];
//}

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

#define ADDING_CELL @"Continue..."
#define DONE_CELL @"Done"
#define DUMMY_CELL @"Dummy"
#define COMMITING_CREATE_CELL_HEIGHT 60
#define NORMAL_CELL_FINISHING_HEIGHT 60
#define DAY_FILTER_FONT_SIZE 20
#define TAG_DAY_FILTER_ARROW 1
#define TAG_LINE_VIEW 10000
#define TAG_DETAIL_INDICATOR 10001

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
    self.tableView.sectionHeaderHeight = 44.0f;
    
    oneDimensionLocationList = [self getOneDimensionLocationList];

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
    
    if([[self.dataController.masterTravelDayList lastObject] count] > 0)
    {
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 1)];
        footerView.backgroundColor = [UIColor whiteColor];
        self.tableView.tableFooterView = footerView;
    }
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
    
    if(singleDayMode)
    {
        locationToMove.whichday = [NSNumber numberWithInt:[self.daySelected intValue]];
    }
    else
    {
        locationToMove.whichday = [NSNumber numberWithInt:destinationIndexPath.section+1];
    }
    
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
    
    if(singleDayMode)
    {
        [db executeUpdate:[NSString stringWithFormat:@"UPDATE location SET seqofday = seqofday-1 where seqofday > %d and whichday = %d",sourceIndexPath.row+1, [self.daySelected intValue]]];
        
        [db executeUpdate:[NSString stringWithFormat:@"UPDATE location SET whichday = %d, seqofday = %d where id = %d",[self.daySelected intValue], 0, idOfLocationToMove]];
        
        [db executeUpdate:[NSString stringWithFormat:@"UPDATE location SET seqofday = seqofday+1 where seqofday > %d and whichday = %d",destinationIndexPath.row, [self.daySelected intValue]]];
        
        [db executeUpdate:[NSString stringWithFormat:@"UPDATE location SET whichday = %d, seqofday = %d where id = %d",[self.daySelected intValue], destinationIndexPath.row+1, idOfLocationToMove]];
    }
    else
    {
        [db executeUpdate:[NSString stringWithFormat:@"UPDATE location SET seqofday = seqofday-1 where seqofday > %d and whichday = %d",sourceIndexPath.row+1, sourceIndexPath.section+1]];
        
        [db executeUpdate:[NSString stringWithFormat:@"UPDATE location SET whichday = %d, seqofday = %d where id = %d",sourceIndexPath.section+1, 0, idOfLocationToMove]];
        
        [db executeUpdate:[NSString stringWithFormat:@"UPDATE location SET seqofday = seqofday+1 where seqofday > %d and whichday = %d",destinationIndexPath.row, destinationIndexPath.section+1]];
        
        [db executeUpdate:[NSString stringWithFormat:@"UPDATE location SET whichday = %d, seqofday = %d where id = %d",destinationIndexPath.section+1, destinationIndexPath.row+1, idOfLocationToMove]];
    }
    
    [db close];
}

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer needsReplacePlaceholderForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[self.dataController.masterTravelDayList objectAtIndex:indexPath.section] replaceObjectAtIndex:indexPath.row withObject:self.grabbedObject];
    
    if(singleDayMode)
    {
        ((Location *)[[self.dataController.masterTravelDayList objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]).whichday = [NSNumber numberWithInt:[self.daySelected intValue]];
        NSMutableArray *array = [[self.dataController.masterTravelDayList objectAtIndex:0] mutableCopy];
        [self.itineraryListBackup replaceObjectAtIndex:[self.daySelected intValue]-1 withObject:array];
    }
    else
    {
        ((Location *)[[self.dataController.masterTravelDayList objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]).whichday = [NSNumber numberWithInt:indexPath.section+1];
        self.itineraryListBackup = [self.dataController.masterTravelDayList mutableCopy];
    }
    
    oneDimensionLocationList = [self getOneDimensionLocationList];
    
    self.grabbedObject = nil;
    [self updateFooterView];
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

//Implement PullDownMenuView delegate
- (void) switchToMapMode:(PullDownMenuView *)view
{
    //self.tableView.contentInset = UIEdgeInsetsZero;
    MapViewController *mapViewController = [[MapViewController alloc] init];
    mapViewController.delegate = self;
    mapViewController.currentItineraryList = [self.dataController.masterTravelDayList mutableCopy];
    mapViewController.itineraryListBackup = [self.itineraryListBackup mutableCopy];
    mapViewController.itineraryDuration = [NSNumber numberWithInt:[self.dataController.itineraryDuration intValue]];
    
    if(singleDayMode)
    {
        mapViewController.daySelected = [NSNumber numberWithInt:[self.daySelected intValue]];
    }
    else
    {
        mapViewController.daySelected = [NSNumber numberWithInt:0];
    }
    
    [self.navigationController pushViewController:mapViewController animated:YES];
}

- (void)editLocationsSequence:(PullDownMenuView *)view
{

}

- (void) startSynchronize:(PullDownMenuView *)view
{

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
        
        CGFloat f = ([self.dataController.itineraryDuration intValue]+1)*40;
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
    self.daySelected = [NSNumber numberWithInt:rowIndex];
    if(rowIndex == 0){
        self.dataController.masterTravelDayList = [self.itineraryListBackup mutableCopy];
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
}

-(void) didChangeLocation:(Location *)location
{
    if(singleDayMode)
    {
        [[self.dataController objectInListAtIndex:0] replaceObjectAtIndex:[location.seqofday intValue]-1 withObject:location];
    }
    else
    {
        [[self.dataController objectInListAtIndex:[location.whichday intValue]-1] replaceObjectAtIndex:[location.seqofday intValue]-1 withObject:location];
    }
    [self.tableView reloadData];
    [location save];
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
        
        NSObject *object = [[self.dataController objectInListAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        
        if ([object isEqual:DUMMY_CELL])
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
            Location *locationAtIndex = (Location *)object;
            
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
            if(indexPath.section == [self.dataController.masterTravelDayList count] -1 || indexPath.row != [[self.dataController objectInListAtIndex:indexPath.section] count] -1)
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
    if([[self.dataController.masterTravelDayList lastObject] count] > 0)
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

    UIView *myView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)];
    UIColor *background = [[UIColor alloc] initWithPatternImage:[[UIImage imageNamed:@"bar_h"] stretchableImageWithLeftCapWidth:8 topCapHeight:0]];
    myView.backgroundColor = background;

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 6.0, 250.0, 20.0)] ;
    label.textColor = [UIColor colorWithRed:72/255.0 green:70/255.0 blue:66/255.0 alpha:1.0];
    label.shadowColor = [UIColor colorWithRed:244/255.0 green:241/255.0 blue:235/255.0 alpha:1.0];
    label.shadowOffset = CGSizeMake(0, 1);
    label.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:16];
    label.backgroundColor = [UIColor clearColor];
    
    UILabel *wLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 24.0, 250.0, 20.0)] ;
    wLabel.textColor = [UIColor colorWithRed:153/255.0 green:150/255.0 blue:145/255.0 alpha:1.0];
    wLabel.shadowColor = [UIColor colorWithRed:244/255.0 green:241/255.0 blue:235/255.0 alpha:1.0];
    wLabel.shadowOffset = CGSizeMake(0, 1);
    wLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:12];
    wLabel.backgroundColor = [UIColor clearColor];
    wLabel.text = [self.dateFormatter stringFromDate:sectionDate];;
    
//    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(275.0, 7.0, 31.0, 31.0)];
//    [button setImage:[UIImage imageNamed:@"addLocation"] forState:UIControlStateNormal];
//    [button setImage:[UIImage imageNamed:@"addLocation_click"] forState:UIControlStateHighlighted];
//    button.tag = dayValue;
//    button.hidden = NO;
//    [button addTarget:self action:@selector(pushSearchViewController:) forControlEvents:UIControlEventTouchUpInside];
    
    label.text = [NSString stringWithFormat:@"第%d天", dayValue+1];
    
    myView.layer.shadowPath = [UIBezierPath bezierPathWithRect:myView.bounds].CGPath;
    myView.layer.shadowOffset = CGSizeMake(0, 1);
    myView.layer.shadowRadius = 0.4;
    myView.layer.shadowColor = [[UIColor colorWithRed:189/255.0 green:176/255.0 blue:153/255.0 alpha:1.0] CGColor];
    myView.layer.shadowOpacity = 1;
    myView.layer.shouldRasterize = YES;
    myView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    [myView addSubview:label];
    [myView addSubview:wLabel];
    //[myView addSubview:button];
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    dropDown = nil;
    self.tableView.contentInset = UIEdgeInsetsZero;
    
    if ([[segue identifier] isEqualToString:@"ShowSearch"])
    {
        UINavigationController *navigationController = segue.destinationViewController;
        SearchViewController *searchController = [[navigationController viewControllers] objectAtIndex:0];
        
        searchController.searchDelegate = self;
        searchController.planId = self.plan.planId;
        searchController.locationKeyword = self.plan.destination;
        NSMutableArray *temp = [[NSMutableArray alloc] init];
        for(NSMutableArray *dayArr in self.itineraryListBackup)
        {
            [temp addObject:[NSNumber numberWithInt:[dayArr count]]];
        }
        searchController.dayLocationCount = [temp mutableCopy];
        
        if(singleDayMode)
        {
            searchController.dayToAdd = [NSNumber numberWithInt:[self.daySelected intValue]];
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
    //NSInteger deleteIndex = [self oneDimensionCountOfIndexPath:self.indexPathOfLocationToDelete];
    Location *locationToDelete = [[self.dataController objectInListAtIndex:self.indexPathOfLocationToDelete.section] objectAtIndex:self.indexPathOfLocationToDelete.row];
    
    BOOL lastSection = [self.dataController.masterTravelDayList count]-1 == self.indexPathOfLocationToDelete.section ? TRUE:FALSE;
    
    if(!lastSection && [[self.dataController objectInListAtIndex:self.indexPathOfLocationToDelete.section] count]-1 == self.indexPathOfLocationToDelete.row)
    {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.indexPathOfLocationToDelete.row-1 inSection:self.indexPathOfLocationToDelete.section]];
        if(cell)
        {
            [[cell.contentView viewWithTag:TAG_LINE_VIEW] removeFromSuperview];
        }
    }
    
    [[self.dataController objectInListAtIndex:self.indexPathOfLocationToDelete.section] removeObjectAtIndex:self.indexPathOfLocationToDelete.row];
    
    for (Location *location in [self.dataController objectInListAtIndex:self.indexPathOfLocationToDelete.section])
    {
        if([location.seqofday intValue] > [locationToDelete.seqofday intValue])
        {
            location.seqofday = [NSNumber numberWithInt:[location.seqofday intValue] -1];
        }
    }
    
    [self.tableView deleteRowsAtIndexPaths:@[self.indexPathOfLocationToDelete] withRowAnimation:UITableViewRowAnimationFade];
    //[oneDimensionLocationList removeObjectAtIndex:deleteIndex];
    
    if(lastSection && [[self.dataController objectInListAtIndex:self.indexPathOfLocationToDelete.section] count] == 0)
    {
        self.tableView.tableFooterView = NULL;
    }
    
    if(singleDayMode)
    {
        NSMutableArray *array = [[self.dataController.masterTravelDayList objectAtIndex:0] mutableCopy];
        [self.itineraryListBackup replaceObjectAtIndex:[self.daySelected intValue]-1 withObject:array];
    }
    else
    {
        NSMutableArray *array = [[self.dataController.masterTravelDayList objectAtIndex:self.indexPathOfLocationToDelete.section] mutableCopy];
        [self.itineraryListBackup replaceObjectAtIndex:self.indexPathOfLocationToDelete.section withObject:array];
    }
    
    oneDimensionLocationList = [self getOneDimensionLocationList];

    FMDatabase *db = [FMDatabase databaseWithPath:[Utility getDatabasePath]];
    [db open];
    [db executeUpdate:@"DELETE FROM location WHERE id = ?", locationToDelete.locationId];
    [db executeUpdate:[NSString stringWithFormat:@"UPDATE location SET seqofday = seqofday-1 where seqofday > %d and whichday = %d",[locationToDelete.seqofday intValue], [locationToDelete.whichday intValue]]];
    [db close];
    [self.itineraryDelegate didDeleteLocationFromPlan];
}

-(void) notifyItinerayToReload
{
    if(isEmptyItinerary)
    {
        isEmptyItinerary = FALSE;
        self.tableView.rowHeight = 44.0f;
    }
    [self reloadDataController];
    singleDayMode = FALSE;
    [(UIButton *)self.navigationItem.titleView setTitle:@"全部" forState:UIControlStateNormal];
    [self.tableView reloadData];
    
    //temporarily commentd
//    NSInteger section;
//    NSInteger row;
//    if(singleDayMode)
//    {
//        section = 0;
//        row = [[self.dataController objectInListAtIndex:0] count]-1;
//    }
//    else
//    {
//        section = [self.dayToAdd integerValue]-1;
//        row = [[self.dataController objectInListAtIndex:section] count]-1;
//    }
//    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    
    [self updateFooterView];
}

//Implement MapViewControllerDelegate
-(void) didChangeLocationFromMap:(Location *)location
{
    [self didChangeLocation:location];
}

-(void) notifyItinerayRoloadToThisDay:(NSNumber *)day
{
    [self niDropDownDelegateMethod:NULL selectRow:[day integerValue]];
    
    if([day intValue] == 0)
    {
        [(UIButton *)self.navigationItem.titleView setTitle:@"全部" forState:UIControlStateNormal];
    }
    else
    {
        [(UIButton *)self.navigationItem.titleView setTitle:[NSString stringWithFormat:@"第%d天", [day intValue]] forState:UIControlStateNormal];
    }
    
    [self.tableView reloadData];
}

@end
