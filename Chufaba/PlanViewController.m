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
#import "User.h"

@implementation PlanViewController

#define TAG_SITELABEL 5
#define TAG_MASKVIEW 10000

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
    
    [self.travelPlans insertObject:plan atIndex:0];
    
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
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)addPlanViewController:(AddPlanViewController *)controller didEditTravelPlan:(Plan *)plan
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    UIView *maskView = [self.tableView viewWithTag:10];
    [maskView removeFromSuperview];
    
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[self.indexPathOfplanToEditOrDelete] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
    
    UITableViewCell *cellToEdit = (UITableViewCell *)[self.tableView cellForRowAtIndexPath:self.indexPathOfplanToEditOrDelete];
    CGRect cellFrame = cellToEdit.frame;
    cellToEdit.frame = CGRectMake(0,cellFrame.origin.y,320,92);
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
    self.travelPlans = [Plan findAll];
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
    
    cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    cell.imageView.image = [planAtIndex getCover];
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

//TODO itinerary
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
        [selectedPlan loadItinerary];
        itineraryViewController.plan = selectedPlan;
        itineraryViewController.daySelected = [NSNumber numberWithInt:0];
        //[itineraryViewController.dataController updatePois];
    }
    else if ([[segue identifier] isEqualToString:@"AddPlan"])
    {
        [(SwipeableTableViewCell *)[self.tableView cellForRowAtIndexPath:self.indexPathOfplanToEditOrDelete] maskViewTapped:NULL];
        UINavigationController *navigationController = segue.destinationViewController;
        AddPlanViewController *addPlanViewController = [[navigationController viewControllers] objectAtIndex:0];
        addPlanViewController.navigationItem.title = @"添加旅行计划";
        addPlanViewController.delegate = self;
        addPlanViewController.plan = [[Plan alloc] init];
    }
    else if ([[segue identifier] isEqualToString:@"EditPlan"])
    {
        UINavigationController *navigationController = segue.destinationViewController;
        AddPlanViewController *addPlanViewController = [[navigationController viewControllers] objectAtIndex:0];
        addPlanViewController.navigationItem.title = @"编辑旅行计划";
        addPlanViewController.delegate = self;
        addPlanViewController.plan = [self.travelPlans objectAtIndex:self.indexPathOfplanToEditOrDelete.row];
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
        Plan *planToDelete = [self.travelPlans objectAtIndex:self.indexPathOfplanToEditOrDelete.row];
        [planToDelete destroy];
        [self.travelPlans removeObjectAtIndex:self.indexPathOfplanToEditOrDelete.row];
        
        [self.tableView deleteRowsAtIndexPaths:@[self.indexPathOfplanToEditOrDelete] withRowAnimation:UITableViewRowAnimationFade];
        
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
    }
    
    UIView *maskView = [self.tableView viewWithTag:10];
    [maskView removeFromSuperview];
    
    UITableViewCell *cellToEdit = (UITableViewCell *)[self.tableView cellForRowAtIndexPath:self.indexPathOfplanToEditOrDelete];
    CGRect cellFrame = cellToEdit.frame;
    cellToEdit.frame = CGRectMake(0,cellFrame.origin.y,320,92);
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
