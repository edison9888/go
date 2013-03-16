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

- (void)addPlanViewControllerDidCancel:(AddPlanViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) addPlanViewController:(AddPlanViewController *)controller didAddTravelPlan:(Plan *)plan
{
    FMDBDataAccess *db = [[FMDBDataAccess alloc] init];
    
    [db insertTravelPlan:plan];
    
    [self populateTravelPlans];
    
    if(controller.coverChanged)
    {
        FMDatabase *db = [FMDatabase databaseWithPath:[Utility getDatabasePath]];
        [db open];
        FMResultSet *results = [db executeQuery:@"SELECT * FROM plan order by id desc limit 1"];
        if([results next])
        {
            plan.planId = [NSNumber numberWithInt:[results intForColumn:@"id"]];
        }
        [self saveImage:plan.image withName:[[plan.planId stringValue] stringByAppendingString:@"planCover"]];
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
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
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)] )
    {
        UIImage *image = [UIImage imageNamed:@"bar.png"];
        UINavigationBar *navBar = self.navigationController.navigationBar;
        [navBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
        
        navBar.layer.masksToBounds = NO;
        navBar.layer.shadowOffset = CGSizeMake(0, 1);
        navBar.layer.shadowRadius = 2;
        navBar.layer.shadowColor = [[UIColor colorWithRed:163/255.0 green:160/255.0 blue:155/255.0 alpha:1.0] CGColor];
        navBar.layer.shadowOpacity = 1;
    }
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_bar.png"]];
    [self populateTravelPlans];
    
    self.view.backgroundColor = [UIColor colorWithRed:244/255.0 green:241/255.0 blue:235/255.0 alpha:1.0];
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
    return [self.travelPlans count];
}

//- (float)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    return 0.01f;
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
//{
//    return [UIView new];
//}


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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PlanCell";
    
    static NSDateFormatter *formatter = nil;
    if (formatter == nil) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
    }
    
    SwipeableTableViewCell *cell = (SwipeableTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
        cell = [[SwipeableTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    Plan *planAtIndex = [self.travelPlans objectAtIndex:indexPath.row];
    
    SwipeableTableViewCellView *contentView = (SwipeableTableViewCellView *)[cell viewWithTag:22];
    
    UIImageView *planCover = (UIImageView *)[contentView viewWithTag:1];
    NSString *coverName = [[planAtIndex.planId stringValue] stringByAppendingString:@"planCover"];
    
    if([self imageExists:coverName])
    {
        planCover.image = [self loadImage: coverName];
    }
    else
    {
        planCover.image = [UIImage imageNamed:@"plan_cover.png"];
    }
    
    UILabel *label;
    label = (UILabel *)[contentView viewWithTag:2];
    label.text = planAtIndex.name;
    label.textColor = [UIColor colorWithRed:72/255.0 green:70/255.0 blue:66/255.0 alpha:1.0];
    label.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:16];
    
    label = (UILabel *)[contentView viewWithTag:3];
    label.text = [formatter stringFromDate:planAtIndex.date];
    label.textColor = [UIColor colorWithRed:153/255.0 green:150/255.0 blue:145/255.0 alpha:1.0];
    label.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:12];
    
    label = (UILabel *)[contentView viewWithTag:4];
    //label.text = [[planAtIndex.duration stringValue] stringByAppendingString:@"天"];
    
    label.text = [NSString stringWithFormat:@"%@天，%d个地点", [planAtIndex.duration stringValue], planAtIndex.locationCount];
    label.textColor = [UIColor colorWithRed:153/255.0 green:150/255.0 blue:145/255.0 alpha:1.0];
    label.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:12];
    
    //add separator line
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 92, self.view.bounds.size.width, 1)];
    lineView.backgroundColor = [UIColor colorWithRed:227/255.0 green:219/255.0 blue:204/255.0 alpha:1.0];
    [cell.contentView addSubview:lineView];

    lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 93, self.view.bounds.size.width, 1)];
    lineView.backgroundColor = [UIColor whiteColor];
    [cell.contentView addSubview:lineView];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 94.0f;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ShowItinerary"]) {
        ItineraryViewController *itineraryViewController = [segue destinationViewController];
        itineraryViewController.itineraryDelegate = self;
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
            location.nameEn = [results stringForColumn:@"name_en"];
            location.country = [results stringForColumn:@"country"];
            location.city = [results stringForColumn:@"city"];
            location.address = [results stringForColumn:@"address"];
            location.transportation = [results stringForColumn:@"transportation"];
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
        
        NSString *coverName = [[tempPlan.planId stringValue] stringByAppendingString:@"planCover"];
        addPlanViewController.plan.image = [self loadImage: coverName];
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
        
        [self removeImage: [[planToDelete.planId stringValue] stringByAppendingString:@"planCover"]];
    }
}

- (void)saveImage:(UIImage *)image withName:(NSString*)imageName
{
    
    NSData *imageData = UIImagePNGRepresentation(image);
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", imageName]];
    
    [fileManager createFileAtPath:fullPath contents:imageData attributes:nil];
    
    NSLog(@"image saved");
    
}

- (void)removeImage:(NSString*)fileName {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", fileName]];
    
    [fileManager removeItemAtPath: fullPath error:NULL];
    
    NSLog(@"image removed");
    
}

- (BOOL)imageExists:(NSString *)imageName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", imageName]];
    
    return [[NSFileManager defaultManager] fileExistsAtPath:fullPath];
}

- (UIImage*)loadImage:(NSString *)imageName
{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", imageName]];
    
    return [UIImage imageWithContentsOfFile:fullPath];
    
}

-(void) didAddLocationToPlan
{
    [self populateTravelPlans];
    [self.tableView reloadData];
}

-(void) didDeleteLocationFromPlan
{
    [self populateTravelPlans];
    [self.tableView reloadData];
}

@end
