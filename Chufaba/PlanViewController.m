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

@implementation UINavigationBar (CustomImage)
- (void)drawRect:(CGRect)rect {
    UIImage *image = [UIImage imageNamed:@"bar.png"];
    [image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
}
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

//-(void) travelPlanDidChange:(ItineraryViewController *) controller
//{
//    [self populateTravelPlans];
//    [self.tableView reloadData];
//}

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

- (void)addPlanViewController:(AddPlanViewController *)controller didEditTravelPlan:(Plan *)plan
{
    Plan *planToEdit = [self.travelPlans objectAtIndex:self.indexPathOfplanToEditOrDelete.row];
    
    FMDBDataAccess *dba = [[FMDBDataAccess alloc] init];
    [dba updateTravelPlan:plan];
    
    FMDatabase *db = [FMDatabase databaseWithPath:[Utility getDatabasePath]];
    [db open];
    
    if([plan.date compare: planToEdit.date] == NSOrderedSame)
    {
        if([plan.duration intValue] < [planToEdit.duration intValue])
        {
            //delete days which are deleted by changing start date.
            [db executeUpdate:@"DELETE FROM location WHERE whichday > ? AND plan_id = ?", plan.duration,plan.planId];
        }
    }
    else if([plan.date compare: planToEdit.date] == NSOrderedDescending)
    {
        NSInteger daysBetween = [Utility daysBetweenDate:planToEdit.date andDate:plan.date];
        if(daysBetween >= [planToEdit.duration intValue])
        {
            //delete all days
            [db executeUpdate:@"DELETE FROM location WHERE plan_id = ?", plan.planId];
        }
        else
        {
            [db executeUpdate:@"DELETE FROM location WHERE whichday <= ? AND plan_id = ?", [NSNumber numberWithInt:daysBetween],plan.planId];
            int offset = daysBetween + [plan.duration intValue] - [planToEdit.duration intValue];
            if(offset >= 0)
            {
                [db executeUpdate:@"UPDATE location SET whichday = whichday-? WHERE whichday > ? AND plan_id = ?", [NSNumber numberWithInt:daysBetween],[NSNumber numberWithInt:daysBetween],plan.planId];
            }
            else
            {
                [db executeUpdate:@"DELETE FROM location WHERE whichday > ? AND plan_id = ?", [NSNumber numberWithInt:[planToEdit.duration intValue]-offset*(-1)],plan.planId];
            }
        }
    }
    else
    {
        NSInteger daysBetween = [Utility daysBetweenDate:plan.date andDate:planToEdit.date];
        if(daysBetween >= [plan.duration intValue])
        {
            [db executeUpdate:@"DELETE FROM location WHERE plan_id = ?", plan.planId];
        }
        else
        {
            [db executeUpdate:@"UPDATE location SET whichday = whichday+? WHERE plan_id = ?", [NSNumber numberWithInt:daysBetween],plan.planId];
            if(daysBetween + [planToEdit.duration intValue] > [plan.duration intValue])
            {
                [db executeUpdate:@"DELETE FROM location WHERE whichday > ? AND plan_id = ?", plan.duration,plan.planId];
            }
        }
    }
    
    [self populateTravelPlans];
    [self.tableView reloadData];
    
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
    
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)] )
    {
        UIImage *image = [UIImage imageNamed:@"bar.png"];
        [self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    }
    
    self.navigationItem.title = @"出发吧";
    [self populateTravelPlans];
    
    self.view.backgroundColor = [UIColor colorWithRed:244/255.0 green:241/255.0 blue:235/255.0 alpha:1.0];
    
//    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.png"]];
//    [tempImageView setFrame:self.tableView.frame];
//    
//    self.tableView.backgroundView = tempImageView;
    
    //self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
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

- (float)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // This will create a "invisible" footer
    return 0.01f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
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
//    Plan *planAtIndex = [self.travelPlans objectAtIndex:indexPath.row];
//    
//    NSString *dateStr = [formatter stringFromDate:planAtIndex.date];
//    NSString *detailStr = [dateStr stringByAppendingString:[NSString stringWithFormat:@"%d", [planAtIndex.duration intValue]]];
//    
//    [[cell textLabel] setText:planAtIndex.name];
//    [[cell detailTextLabel] setText:detailStr];
//    cell.imageView.image = planAtIndex.image;
//    return cell;
//}

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
//    SwipeableTableViewCell *cell = (SwipeableTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (!cell)
//        cell = [[SwipeableTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
//    
//    Plan *planAtIndex = [self.travelPlans objectAtIndex:indexPath.row];
//    
//    NSString *dateStr = [formatter stringFromDate:planAtIndex.date];
//    NSString *detailStr = [dateStr stringByAppendingString:[NSString stringWithFormat:@"%d", [planAtIndex.duration intValue]]];
//    
//    cell.textLabel.text = planAtIndex.name;
//    cell.detailTextLabel.enabled = YES;
//    cell.detailTextLabel.text = detailStr;
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
    
//    NSArray *familyNames = [[NSArray alloc] initWithArray:[UIFont familyNames]];
//    NSArray *fontNames;
//    NSInteger indFamily, indFont;
//    for(indFamily=0;indFamily<[familyNames count];++indFamily)
//    {
//        NSLog(@"Family name: %@", [familyNames objectAtIndex:indFamily]);
//        fontNames =[[NSArray alloc]initWithArray:[UIFont fontNamesForFamilyName:[familyNames objectAtIndex:indFamily]]];
//        for(indFont=0; indFont<[fontNames count]; ++indFont)
//        {
//            NSLog(@" Font name: %@",[fontNames objectAtIndex:indFont]);
//        }
//    }
    
    SwipeableTableViewCell *cell = (SwipeableTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    Plan *planAtIndex = [self.travelPlans objectAtIndex:indexPath.row];
    
    UIImageView *planCover = (UIImageView *)[cell viewWithTag:1];
    planCover.image = [UIImage imageNamed:@"sydney.png"];
    
    UILabel *label;
    label = (UILabel *)[cell viewWithTag:2];
    label.text = planAtIndex.name;
    label.textColor = [UIColor colorWithRed:72/255.0 green:70/255.0 blue:66/255.0 alpha:1.0];
    label.font = [UIFont fontWithName:@"Heiti SC" size:16];
    
    label = (UILabel *)[cell viewWithTag:3];
    label.text = [formatter stringFromDate:planAtIndex.date];
    label.textColor = [UIColor colorWithRed:153/255.0 green:150/255.0 blue:145/255.0 alpha:1.0];
    label.font = [UIFont fontWithName:@"Heiti SC" size:12];
    
    label = (UILabel *)[cell viewWithTag:4];
    label.text = [planAtIndex.duration stringValue];
    label.textColor = [UIColor colorWithRed:153/255.0 green:150/255.0 blue:145/255.0 alpha:1.0];
    label.font = [UIFont fontWithName:@"Heiti SC" size:12];

    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
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
        
        [db close];
        
    }
    else if ([[segue identifier] isEqualToString:@"AddPlan"])
    {
        UINavigationController *navigationController = segue.destinationViewController;
        AddPlanViewController *addPlanViewController = [[navigationController viewControllers] objectAtIndex:0];
        addPlanViewController.navigationItem.title = @"添加旅行计划";
        addPlanViewController.delegate = self;
    }
    else if ([[segue identifier] isEqualToString:@"EditPlan"])
    {
        UINavigationController *navigationController = segue.destinationViewController;
        AddPlanViewController *addPlanViewController = [[navigationController viewControllers] objectAtIndex:0];
        addPlanViewController.navigationItem.title = @"编辑旅行计划";
        addPlanViewController.delegate = self;
        Plan *tempPlan = [self.travelPlans objectAtIndex:self.indexPathOfplanToEditOrDelete.row];
        addPlanViewController.plan = [[Plan alloc] initWithName:tempPlan.name duration:tempPlan.duration date:tempPlan.date image:tempPlan.image];
        addPlanViewController.plan.planId = tempPlan.planId;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        
//        FMDBDataAccess *db = [[FMDBDataAccess alloc] init];
//        
//        Plan *planToDelete = [self.travelPlans objectAtIndex:indexPath.row];
//        
//        [db deleteTravelPlan:planToDelete];
//        
//        [self.travelPlans removeObjectAtIndex:indexPath.row];
//        
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    }
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
    [self performSegueWithIdentifier:@"ShowItinerary" sender:nil];
}

- (void)tableView:(UITableView *)tableView didSwipeCellAtIndexPath:(NSIndexPath *)indexPath
{
    self.indexPathOfplanToEditOrDelete = indexPath;
}

- (void) didEditPlan
{
    [self performSegueWithIdentifier:@"EditPlan" sender:self];
}

- (void) didDeletePlan;
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"确定删除该计划吗？该操作无法撤销！" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除" otherButtonTitles:nil, nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showInView:self.view];
}

-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 0)
    {
        FMDBDataAccess *db = [[FMDBDataAccess alloc] init];
        
        NSLog(@"section:%d", self.indexPathOfplanToEditOrDelete.row);
        
        Plan *planToDelete = [self.travelPlans objectAtIndex:self.indexPathOfplanToEditOrDelete.row];
        
        [db deleteTravelPlan:planToDelete];
        
        [self.travelPlans removeObjectAtIndex:self.indexPathOfplanToEditOrDelete.row];
        
        [self.tableView deleteRowsAtIndexPaths:@[self.indexPathOfplanToEditOrDelete] withRowAnimation:UITableViewRowAnimationFade];
    }
}

@end
