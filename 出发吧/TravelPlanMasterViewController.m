//
//  TravelPlanMasterViewController.m
//  出发吧
//
//  Created by kenzo on 13-1-16.
//  Copyright (c) 2013年 出发吧APP团队. All rights reserved.
//

#import "TravelPlanMasterViewController.h"
#import "TravelPlanDataController.h"
#import "TravelPlan.h"
#import "itineraryMasterViewController.h"
#import "itineraryDataController.h"

@interface TravelPlanMasterViewController ()

@end

@implementation TravelPlanMasterViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

/*- (void)awakeFromNib
{
    [super awakeFromNib];
    self.dataController = [[TravelPlanDataController alloc] init];
}*/

- (void)addPlanViewControllerDidCancel:(AddPlanViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addPlanViewController:(AddPlanViewController *)controller didEditTravelPlan:(TravelPlan *)plan
{
    FMDBDataAccess *db = [[FMDBDataAccess alloc] init];
    
    [db updateTravelPlan:plan];
    
    [self populateTravelPlans];
    
    [self.tableView reloadData];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) addPlanViewController:(AddPlanViewController *)controller didAddTravelPlan:(TravelPlan *)plan
{
    FMDBDataAccess *db = [[FMDBDataAccess alloc] init];
    
    [db insertTravelPlan:plan];
    
    [self populateTravelPlans];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    //NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.travelPlans count] - 1 inSection:0];
    
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    //[self.tableView reloadData];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) populateTravelPlans
{
    self.travelPlans = [[NSMutableArray alloc] init];
    
    FMDBDataAccess *db = [[FMDBDataAccess alloc] init];
    
    self.travelPlans = [db getTravelPlans];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self populateTravelPlans];
    self.dataController = [[TravelPlanDataController alloc] init];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

//- (IBAction)done:(UIStoryboardSegue *)segue
//{
//    if ([[segue identifier] isEqualToString:@"ReturnInput"]) {
//        
//        AddPlanViewController *addController = [segue sourceViewController];
//        if (addController.plan) {
//            [self.dataController addTravelPlanWithPlan:addController.plan];
//            [[self tableView] reloadData];
//        }
//        [self dismissViewControllerAnimated:YES completion:NULL];
//    }
//}
//
//- (IBAction)cancel:(UIStoryboardSegue *)segue
//{
//    if ([[segue identifier] isEqualToString:@"CancelInput"]) {
//        [self dismissViewControllerAnimated:YES completion:NULL];
//    }
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //[self setReorderingEnabled:([self.dataController countOfList] > 1 )];
    //return [self.dataController countOfList];
    return [self.travelPlans count];
}

//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *CellIdentifier = @"TravelPlanCell";
//    
//    static NSDateFormatter *formatter = nil;
//    if (formatter == nil) {
//        formatter = [[NSDateFormatter alloc] init];
//        [formatter setDateStyle:NSDateFormatterMediumStyle];
//    }
//    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    
//    TravelPlan *planAtIndex = [self.dataController objectInListAtIndex:indexPath.row];
//    [[cell textLabel] setText:planAtIndex.name];
//    [[cell detailTextLabel] setText:[NSString stringWithFormat:@"%d", [planAtIndex.duration intValue]]];
//    cell.imageView.image = planAtIndex.image;
//    return cell;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TravelPlanCell";
    
    static NSDateFormatter *formatter = nil;
    if (formatter == nil) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    //NSUInteger planIndex = [self.travelPlans count] - 1 - indexPath.row;
    //TravelPlan *planAtIndex = [self.travelPlans objectAtIndex:planIndex];
    TravelPlan *planAtIndex = [self.travelPlans objectAtIndex:indexPath.row];
    
    NSString *dateStr = [formatter stringFromDate:planAtIndex.date];
    NSString *detailStr = [dateStr stringByAppendingString:[NSString stringWithFormat:@"%d", [planAtIndex.duration intValue]]];
    
    [[cell textLabel] setText:planAtIndex.name];
    //[[cell detailTextLabel] setText:[NSString stringWithFormat:@"%d", [planAtIndex.duration intValue]]];
    [[cell detailTextLabel] setText:detailStr];
    cell.imageView.image = planAtIndex.image;
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"ShowItinerary"]) {
        itineraryMasterViewController *itineraryViewController = [segue destinationViewController];
        TravelPlan *selectedPlan = [self.travelPlans objectAtIndex:[self.tableView indexPathForSelectedRow].row];
        //itineraryViewController.dataController.masterTravelDayList = selectedPlan.itineraryList;
        itineraryViewController.dataController.date = selectedPlan.date;
        NSMutableArray *tempList = [[NSMutableArray alloc] init];
        for (int i = 0; i < [selectedPlan.duration intValue]; i++)
        {
            NSMutableArray *dayList = [[NSMutableArray alloc] init];
            [tempList addObject:dayList];
        }
        
        FMDatabase *db = [FMDatabase databaseWithPath:[Utility getDatabasePath]];
        
        [db open];
        
        NSNumber *planID = selectedPlan.planId;
        FMResultSet *results = [db executeQuery:@"SELECT * FROM location,plan WHERE plan_id=? AND plan_id=plan.id",planID];
        while([results next])
        {
            int dayID = [results intForColumn:@"whichday"]-1;
            
            TravelLocation *location = [[TravelLocation alloc] init];
            //location.locationId = [NSNumber numberWithInt:[results intForColumn:@"id"]];
            location.locationId = [NSNumber numberWithInt:[results intForColumnIndex:0]];
            location.name = [results stringForColumn:@"name"];
            location.address = [results stringForColumn:@"address"];
            location.transportation = [results stringForColumn:@"transportation"];
            location.name = [results stringForColumn:@"name"];
            location.costAmount = [NSNumber numberWithInt:[results intForColumn:@"cost_amount"]];
            location.costUnit = [NSNumber numberWithInt:[results intForColumn:@"cost_unit"]];
            location.visitBegin = [results dateForColumn:@"visit_begin"];
            location.visitEnd = [results dateForColumn:@"visit_end"];
            location.detail = [results stringForColumn:@"detail"];
            [[tempList objectAtIndex:dayID] addObject:location];
        }
        itineraryViewController.dataController.masterTravelDayList = tempList;
        
        [db close];
        
    }
    else if ([[segue identifier] isEqualToString:@"AddPlan"])
    {
        UINavigationController *navigationController = segue.destinationViewController;
        AddPlanViewController *addPlanViewController = [[navigationController viewControllers] objectAtIndex:0];
        addPlanViewController.delegate = self;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        [self.dataController.masterTravelPlanList removeObjectAtIndex:indexPath.row];
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    }    
//}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        FMDBDataAccess *db = [[FMDBDataAccess alloc] init];
        
        //NSUInteger planIndex = [self.travelPlans count] - 1 - indexPath.row;
        //TravelPlan *planToDelete = [self.travelPlans objectAtIndex:planIndex];
        
        TravelPlan *planToDelete = [self.travelPlans objectAtIndex:indexPath.row];
        
        [db deleteTravelPlan:planToDelete];
        
        //[self.travelPlans removeObjectAtIndex:planIndex];
        [self.travelPlans removeObjectAtIndex:indexPath.row];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{

}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
