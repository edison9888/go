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
#import "AddPlanViewController.h"
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dataController = [[TravelPlanDataController alloc] init];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (IBAction)done:(UIStoryboardSegue *)segue
{
    if ([[segue identifier] isEqualToString:@"ReturnInput"]) {
        
        AddPlanViewController *addController = [segue sourceViewController];
        if (addController.plan) {
            [self.dataController addTravelPlanWithPlan:addController.plan];
            [[self tableView] reloadData];
        }
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}

- (IBAction)cancel:(UIStoryboardSegue *)segue
{
    if ([[segue identifier] isEqualToString:@"CancelInput"]) {
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}

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
    return [self.dataController countOfList];
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
    
    TravelPlan *planAtIndex = [self.dataController objectInListAtIndex:indexPath.row];
    [[cell textLabel] setText:planAtIndex.name];
    [[cell detailTextLabel] setText:[NSString stringWithFormat:@"%d", [planAtIndex.duration intValue]]];
    cell.imageView.image = planAtIndex.image;
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"ShowItinerary"]) {
        itineraryMasterViewController *itineraryViewController = [segue destinationViewController];
        itineraryViewController.dataController.masterTravelDayList = [self.dataController objectInListAtIndex:[self.tableView indexPathForSelectedRow].row].itineraryList;
        itineraryViewController.dataController.date = [self.dataController objectInListAtIndex:[self.tableView indexPathForSelectedRow].row].date;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.dataController.masterTravelPlanList removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }    
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    TravelPlan *planToMove = [self.dataController objectInListAtIndex:fromIndexPath.row];
    [self.dataController.masterTravelPlanList removeObjectAtIndex:fromIndexPath.row];
    [self.dataController.masterTravelPlanList insertObject:planToMove atIndex:toIndexPath.row];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
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
