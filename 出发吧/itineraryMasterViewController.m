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

    /*self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
    */
}

/*- (IBAction)cancel:(UIStoryboardSegue *)segue
{
    if ([[segue identifier] isEqualToString:@"CancelSearch"]) {
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}*/

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*- (void)insertNewObject:(id)sender
{
    if (!_objects) {
        _objects = [[NSMutableArray alloc] init];
    }
    [_objects insertObject:[NSDate date] atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}*/

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    int i = [self.dataController countOfList];
    NSLog(@"%d", i );
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
    [offsetComponents setDay:section];
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
    button.tag = section;
    button.hidden = NO;
    [button setBackgroundColor:[UIColor clearColor]];
    [button addTarget:self action:@selector(pushSearchLocationViewController:) forControlEvents:UIControlEventTouchDown];
    
    label.text = [[myString stringByAppendingString:[NSString stringWithFormat:@"%d", section+1]] stringByAppendingString:dateOfDay];
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
}

/*- (IBAction)pushSearchLocationViewController
{
    SearchLocationViewController *locationVC = [[SearchLocationViewController alloc] init];
    [self presentViewController:locationVC animated:YES completion:NULL];
}*/

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
    [db executeUpdate:[NSString stringWithFormat:@"UPDATE location SET whichday = %d, seqofday = %d where id = %d",toIndexPath.section+1, toIndexPath.row+1, [locationToMove.locationId intValue]]];
    [db executeUpdate:[NSString stringWithFormat:@"UPDATE location SET seqofday = seqofday+1 where seqofday > %d and whichday = %d",toIndexPath.row, toIndexPath.section+1]];
    [db close];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

@end
