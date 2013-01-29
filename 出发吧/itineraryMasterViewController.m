//
//  itineraryMasterViewController.m
//  出发吧
//
//  Created by kenzo on 13-1-16.
//  Copyright (c) 2013年 出发吧APP团队. All rights reserved.
//

#import "itineraryMasterViewController.h"

#import "itineraryDetailViewController.h"
#import "TravelLocation.h"
#import "itineraryDataController.h"
#import "SearchLocationViewController.h"
#import "SearchLocation.h"

/*
@interface itineraryMasterViewController () {
    NSMutableArray *_objects;
}
@end
*/

@implementation itineraryMasterViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.dataController = [[itineraryDataController alloc] init];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
		//view.delegate = self;
		[self.tableView addSubview:view];
		pullDownMenuView = view;
	}
}

- (IBAction)selectClicked:(id)sender {
    NSMutableArray * arr = [[NSMutableArray alloc] init];
    [arr addObject:@"全部"];
    for(int i=0; i<[self.itineraryDuration intValue]; i++)
    {
        [arr addObject:[@"Day " stringByAppendingString:[NSString stringWithFormat:@"%d",i+1]]];
    }
    if(dropDown == nil) {
        CGFloat f = ([self.itineraryDuration intValue]+1)*40;
        dropDown = [[NIDropDown alloc]showDropDown:sender :&f :arr];
        dropDown.delegate = self;
    }
    else {
        [dropDown hideDropDown:sender];
        dropDown = nil;
    }
}

- (void) niDropDownDelegateMethod: (NIDropDown *) sender selectRow:(NSInteger)rowIndex
{
    dropDown = nil;
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

-(void) searchLocationViewController:(SearchLocationViewController *) controller didAddSearchLocation:(SearchLocation *) locationSelected
{
    TravelLocation *locationToAdd = [[TravelLocation alloc] init];
    locationToAdd.name = locationSelected.name;
    locationToAdd.address = locationSelected.address;
    locationToAdd.category = locationSelected.category;
    if(singleDayMode){
        [[self.dataController objectInListAtIndex:0] addObject:locationToAdd];
    }
    else{
        [[self.dataController objectInListAtIndex:[self.dayToAdd intValue]-1] addObject:locationToAdd];
    }
    
    //NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.seqToAdd intValue] inSection:[self.dayToAdd intValue]];
    //[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView reloadData];
    
    //add search location to database
    FMDatabase *db = [FMDatabase databaseWithPath:[Utility getDatabasePath]];
    [db open];
    [db executeUpdate:@"INSERT INTO location (plan_id,whichday,seqofday,name,address,category) VALUES (?,?,?,?,?,?);",self.planID,self.dayToAdd,self.seqToAdd,locationToAdd.name,locationToAdd.address,locationToAdd.category];
    [db close];
    
    [self dismissViewControllerAnimated:YES completion:nil];
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
    
    TravelLocation *locationAtIndex = [[self.dataController objectInListAtIndex:indexPath.section] objectAtIndex:indexPath.row];
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
    if ([[segue identifier] isEqualToString:@"ShowLocationDetails"]) {
        itineraryDetailViewController *detailViewController = [segue destinationViewController];
        detailViewController.location = [[self.dataController objectInListAtIndex:[self.tableView indexPathForSelectedRow].section] objectAtIndex:[self.tableView indexPathForSelectedRow].row];
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
}

- (IBAction)pushSearchLocationViewController:(id)sender
{
    [self performSegueWithIdentifier:@"SearchLocation" sender:sender];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        TravelLocation *locationToDelete = [[self.dataController objectInListAtIndex:indexPath.section] objectAtIndex:indexPath.row];
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
    TravelLocation *locationToMove = [[self.dataController objectInListAtIndex:fromIndexPath.section] objectAtIndex:fromIndexPath.row];
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

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	
	[pullDownMenuView pdmScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	[pullDownMenuView pdmScrollViewDidEndDragging:scrollView];
	
}

@end
