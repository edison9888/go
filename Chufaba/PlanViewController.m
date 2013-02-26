//
//  TravelPlanMasterViewController.m
//  出发吧
//
//  Created by kenzo on 13-1-16.
//  Copyright (c) 2013年 出发吧APP团队. All rights reserved.
//

#import "PlanViewController.h"
#import "Plan.h"
#import "ItineraryViewController.h"
#import "ItineraryDataController.h"

@interface PlanViewController ()

@end

@implementation PlanViewController

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

-(void) travelPlanDidChange:(ItineraryViewController *) controller
{
    [self populateTravelPlans];
    [self.tableView reloadData];
}

- (void)addPlanViewControllerDidCancel:(AddPlanViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) addPlanViewController:(AddPlanViewController *)controller didAddTravelPlan:(Plan *)plan
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

- (IBAction)showLogin:(id)sender
{
    [self performSegueWithIdentifier:@"ShowSettings" sender:self];
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
    self.navigationItem.title = @"出发吧";
    [self populateTravelPlans];
    
    self.accountManager = [[SocialAccountManager alloc] init];
    self.accountManager.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //[self setReorderingEnabled:([self.dataController countOfList] > 1 )];
    return [self.travelPlans count];
}

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
    Plan *planAtIndex = [self.travelPlans objectAtIndex:indexPath.row];
    
    NSString *dateStr = [formatter stringFromDate:planAtIndex.date];
    NSString *detailStr = [dateStr stringByAppendingString:[NSString stringWithFormat:@"%d", [planAtIndex.duration intValue]]];
    
    [[cell textLabel] setText:planAtIndex.name];
    [[cell detailTextLabel] setText:detailStr];
    cell.imageView.image = planAtIndex.image;
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"ShowItinerary"]) {
        ItineraryViewController *itineraryViewController = [segue destinationViewController];
        Plan *selectedPlan = [self.travelPlans objectAtIndex:[self.tableView indexPathForSelectedRow].row];
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
        FMResultSet *results = [db executeQuery:@"SELECT * FROM location,plan WHERE plan_id=? AND plan_id=plan.id order by seqofday",planID];
        while([results next])
        {
            int dayID = [results intForColumn:@"whichday"]-1;
            
            Location *location = [[Location alloc] init];
            //location.locationId = [NSNumber numberWithInt:[results intForColumn:@"id"]];
            location.locationId = [NSNumber numberWithInt:[results intForColumnIndex:0]];
            location.whichday = [NSNumber numberWithInt:[results intForColumn:@"whichday"]];
            location.seqofday = [NSNumber numberWithInt:[results intForColumn:@"seqofday"]];
            location.name = [results stringForColumn:@"name"];
            location.address = [results stringForColumn:@"address"];
            location.transportation = [results stringForColumn:@"transportation"];
            location.name = [results stringForColumn:@"name"];
            location.cost = [NSNumber numberWithInt:[results intForColumn:@"cost"]];
            location.currency = [results stringForColumn:@"currency"];
            location.visitBegin = [results dateForColumn:@"visit_begin"];
            location.visitEnd = [results dateForColumn:@"visit_end"];
            location.detail = [results stringForColumn:@"detail"];
            location.category = [results stringForColumn:@"category"];
            location.latitude = [NSNumber numberWithDouble:[results doubleForColumn:@"latitude"]];
            location.longitude = [NSNumber numberWithDouble:[results doubleForColumn:@"longitude"]];
            [[tempList objectAtIndex:dayID] addObject:location];
        }
        itineraryViewController.dataController.masterTravelDayList = tempList;
        itineraryViewController.dataController.itineraryDuration = selectedPlan.duration;
        itineraryViewController.itineraryListBackup = tempList;
        itineraryViewController.daySelected = [NSNumber numberWithInt:0];
        itineraryViewController.plan = selectedPlan;
        itineraryViewController.delegate = self;
        
        [db close];
        
    }
    else if ([[segue identifier] isEqualToString:@"AddPlan"])
    {
        UINavigationController *navigationController = segue.destinationViewController;
        AddPlanViewController *addPlanViewController = [[navigationController viewControllers] objectAtIndex:0];
        addPlanViewController.navigationItem.title = @"添加旅行计划";
        addPlanViewController.delegate = self;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        FMDBDataAccess *db = [[FMDBDataAccess alloc] init];
        
        Plan *planToDelete = [self.travelPlans objectAtIndex:indexPath.row];
        
        [db deleteTravelPlan:planToDelete];
        
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
