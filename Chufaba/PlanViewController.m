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
#import "SearchDestinationViewController.h"
#import "Utility.h"

@implementation PlanViewController

#define TAG_SITELABEL 5
#define TAG_MASKVIEW 10000

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {

    }
    return self;
}

- (void)addPlanViewControllerDidCancel:(AddPlanViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    UIView *maskView = [self.tableView viewWithTag:10];
    [maskView removeFromSuperview];
    
    UITableViewCell *cellToEdit = (UITableViewCell *)[self.tableView cellForRowAtIndexPath:self.indexPathOfplanToEditOrDelete];
    CGRect cellFrame = cellToEdit.frame;
    cellToEdit.frame = CGRectMake(0,cellFrame.origin.y,320,92);
}

- (void) addPlanViewController:(AddPlanViewController *)controller didAddTravelPlan:(Plan *)plan
{
    if([self.view viewWithTag:TAG_MASKVIEW])
    {
        [[self.view viewWithTag:TAG_MASKVIEW] removeFromSuperview];
    }
    if(!self.tableView.tableHeaderView)
    {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 1)];
        headerView.backgroundColor = [UIColor colorWithRed:227/255.0 green:219/255.0 blue:204/255.0 alpha:1.0];
        self.tableView.tableHeaderView = headerView;
    }
    
    FMDBDataAccess *db = [[FMDBDataAccess alloc] init];
    
    [db insertTravelPlan:plan];
    
    [self populateTravelPlans];
    
    if([self.travelPlans count] == 5)
    { 
        [[self.view viewWithTag:TAG_SITELABEL] removeFromSuperview];
        
        UILabel *siteLabel = [[UILabel alloc] init];
        siteLabel.backgroundColor = [UIColor clearColor];
        siteLabel.text = @"chufaba.me";
        siteLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:12];
        siteLabel.textColor = [UIColor colorWithRed:227/255.0 green:219/255.0 blue:204/255.0 alpha:1.0];
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 50)];
        [siteLabel setFrame:CGRectMake(122, 20, 76, 20)];
        [footerView addSubview:siteLabel];
        self.tableView.tableFooterView = footerView;
    }
    
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
    
    UIView *maskView = [self.tableView viewWithTag:10];
    [maskView removeFromSuperview];
    
    UITableViewCell *cellToEdit = (UITableViewCell *)[self.tableView cellForRowAtIndexPath:self.indexPathOfplanToEditOrDelete];
    CGRect cellFrame = cellToEdit.frame;
    cellToEdit.frame = CGRectMake(0,cellFrame.origin.y,320,92);
    
    //[self saveImage:plan.image withName:[[plan.planId stringValue] stringByAppendingString:@"planCover"]];
}


- (IBAction)showSetting:(id)sender
{
    [self performSegueWithIdentifier:@"ShowSettings" sender:self];
}

- (IBAction)AddPlan:(id)sender
{
    [self performSegueWithIdentifier:@"AddPlan" sender:self];
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
    
    UIButton *addBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 7, 40, 30)];
    [addBtn setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
    [addBtn setImage:[UIImage imageNamed:@"add_click"] forState:UIControlStateHighlighted];
    [addBtn addTarget:self action:@selector(AddPlan:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithCustomView:addBtn];
    self.navigationItem.rightBarButtonItem = btn;
    
    UIButton *settingBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 7, 40, 30)];
    [settingBtn setImage:[UIImage imageNamed:@"setting"] forState:UIControlStateNormal];
    [settingBtn setImage:[UIImage imageNamed:@"setting_click"] forState:UIControlStateHighlighted];
    [settingBtn addTarget:self action:@selector(showSetting:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *setBtn = [[UIBarButtonItem alloc] initWithCustomView:settingBtn];
    self.navigationItem.leftBarButtonItem = setBtn;
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    UINavigationBar *navBar = self.navigationController.navigationBar;
    navBar.layer.shadowPath = [UIBezierPath bezierPathWithRect:navBar.bounds].CGPath;
    navBar.layer.masksToBounds = NO;
    navBar.layer.shadowOffset = CGSizeMake(0, 1);
    navBar.layer.shadowRadius = 2;
    navBar.layer.shadowColor = [[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.3] CGColor];
    navBar.layer.shadowOpacity = 1;
    navBar.layer.shouldRasterize = YES;
    navBar.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_bar"]];
    [self populateTravelPlans];
    
    self.view.backgroundColor = [UIColor colorWithRed:244/255.0 green:241/255.0 blue:235/255.0 alpha:1.0];
    
    UILabel *siteLabel = [[UILabel alloc] init];
    siteLabel.backgroundColor = [UIColor clearColor];
    siteLabel.text = @"chufaba.me";
    siteLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:12];
    siteLabel.textColor = [UIColor colorWithRed:227/255.0 green:219/255.0 blue:204/255.0 alpha:1.0];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 1)];
    headerView.backgroundColor = [UIColor colorWithRed:227/255.0 green:219/255.0 blue:204/255.0 alpha:1.0];
    self.tableView.tableHeaderView = headerView;
    
    if([self.travelPlans count] > 4)
    {
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 50)];
        [siteLabel setFrame:CGRectMake(122, 20, 76, 20)];
        [footerView addSubview:siteLabel];
        self.tableView.tableFooterView = footerView;
    }
    else if([self.travelPlans count] > 0)
    {
        [siteLabel setFrame:CGRectMake(122, self.view.bounds.size.height-80, 76, 30)];
        siteLabel.tag = TAG_SITELABEL;
        [self.view addSubview:siteLabel];
    }
    else
    {
        [siteLabel setFrame:CGRectMake(122, self.view.bounds.size.height-80, 76, 30)];
        siteLabel.tag = TAG_SITELABEL;
        [self.view addSubview:siteLabel];
        self.tableView.tableHeaderView = NULL;
        
        UIView *maskView = [[UIView alloc] init];
        maskView.tag = TAG_MASKVIEW;
        maskView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        UILabel *implyLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 170, 80, 30)];
        implyLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:16];
        implyLabel.text = @"这里空荡荡";
        implyLabel.textColor = [UIColor colorWithRed:189/255.0 green:176/255.0 blue:153/255.0 alpha:1.0];
        implyLabel.backgroundColor = [UIColor clearColor];
        [maskView addSubview:implyLabel];
        [self.view addSubview:maskView];
        [self.view bringSubviewToFront:maskView];
    }
    
    self.tableView.rowHeight = 92.0f;
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PlanCell";
    
    static NSDateFormatter *formatter = nil;
    if (formatter == nil)
    {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
    }
    
    SwipeableTableViewCell *cell = (SwipeableTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
    {
        cell = [[SwipeableTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    Plan *planAtIndex = [self.travelPlans objectAtIndex:indexPath.row];

    NSString *coverName = [[planAtIndex.planId stringValue] stringByAppendingString:@"planCover"];
    
    cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    if([self imageExists:coverName])
    {
        cell.imageView.image = [self loadImage: coverName];
    }
    else
    {
        cell.imageView.image = [UIImage imageNamed:@"plan_cover"];
    }
    
    cell.textLabel.text = planAtIndex.name;
    cell.detailTextLabel.text = [formatter stringFromDate:planAtIndex.date];
    
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:4];
    label.text = [NSString stringWithFormat:@"%@天，%d个地点", [planAtIndex.duration stringValue], planAtIndex.locationCount];
    
    if(indexPath.row == [self.travelPlans count]-1)
    {
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 92, 320, 1)];
        lineView.backgroundColor = [UIColor whiteColor];
        [cell.contentView addSubview:lineView];
    }
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ShowItinerary"])
    {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        if ([userDefaults objectForKey:@"preferDestination"])
        {
            [userDefaults removeObjectForKey:@"preferDestination"];
            [userDefaults synchronize];
        }
        
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
        itineraryViewController.dataController.masterTravelDayList = tempList;
        itineraryViewController.dataController.itineraryDuration = selectedPlan.duration;
        itineraryViewController.itineraryListBackup = tempList;
        itineraryViewController.daySelected = [NSNumber numberWithInt:0];
        itineraryViewController.plan = selectedPlan;
        [db close];
        
    }
    else if ([[segue identifier] isEqualToString:@"AddPlan"])
    {
        [(SwipeableTableViewCell *)[self.tableView cellForRowAtIndexPath:self.indexPathOfplanToEditOrDelete] maskViewTapped:NULL];
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
        addPlanViewController.plan = [[Plan alloc] initWithName:tempPlan.name destination:tempPlan.destination duration:tempPlan.duration date:tempPlan.date image:tempPlan.image];
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
        
        if([self.travelPlans count] == 4)
        {
            self.tableView.tableFooterView = NULL;
            
            UILabel *siteLabel = [[UILabel alloc] initWithFrame:CGRectMake(122, 380, 76, 30)];
            siteLabel.backgroundColor = [UIColor clearColor];
            siteLabel.text = @"chufaba.me";
            siteLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:12];
            siteLabel.textColor = [UIColor colorWithRed:227/255.0 green:219/255.0 blue:204/255.0 alpha:1.0];
            siteLabel.tag = TAG_SITELABEL;
            [self.view addSubview:siteLabel];
        }
        
        //[self.tableView deleteRowsAtIndexPaths:@[self.indexPathOfplanToEditOrDelete] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView reloadData];
        if([self.travelPlans count] == 0)
        {
            self.tableView.tableHeaderView = NULL;
            if(![self.view viewWithTag:TAG_MASKVIEW])
            {
                UIView *maskView = [[UIView alloc] init];
                maskView.tag = TAG_MASKVIEW;
                maskView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
                UILabel *implyLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 170, 80, 30)];
                implyLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:16];
                implyLabel.text = @"这里空荡荡";
                implyLabel.textColor = [UIColor colorWithRed:189/255.0 green:176/255.0 blue:153/255.0 alpha:1.0];
                implyLabel.backgroundColor = [UIColor clearColor];
                [maskView addSubview:implyLabel];
                [self.view addSubview:maskView];
                [self.view bringSubviewToFront:maskView];
            }
        }
        [self removeImage: [[planToDelete.planId stringValue] stringByAppendingString:@"planCover"]];
    }
    
    UIView *maskView = [self.tableView viewWithTag:10];
    [maskView removeFromSuperview];
    
    UITableViewCell *cellToEdit = (UITableViewCell *)[self.tableView cellForRowAtIndexPath:self.indexPathOfplanToEditOrDelete];
    CGRect cellFrame = cellToEdit.frame;
    cellToEdit.frame = CGRectMake(0,cellFrame.origin.y,320,92);
}

- (void)saveImage:(UIImage *)image withName:(NSString*)imageName
{
    
    NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg", imageName]];
    
    [fileManager createFileAtPath:fullPath contents:imageData attributes:nil];
    
    NSLog(@"image saved");
    
}

- (void)removeImage:(NSString*)fileName {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg", fileName]];
    
    [fileManager removeItemAtPath: fullPath error:NULL];
    
    NSLog(@"image removed");
    
}

- (BOOL)imageExists:(NSString *)imageName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg", imageName]];
    
    return [[NSFileManager defaultManager] fileExistsAtPath:fullPath];
}

- (UIImage*)loadImage:(NSString *)imageName
{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg", imageName]];
    
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
