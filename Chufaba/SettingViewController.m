//
//  SettingViewController.m
//  Chufaba
//
//  Created by 张 辛欣 on 13-2-13.
//  Copyright (c) 2013年 ChufabaAPP团队. All rights reserved.
//

#import "SettingViewController.h"
#import "SocialAccountManager.h"

@interface SettingViewController ()

@end

@implementation SettingViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.accountManager = [[SocialAccountManager alloc] init];
    
    if([self.accountManager.sinaweibo isAuthValid])
    {
        self.logoutCell.hidden = NO;
    }
    else
    {
        self.logoutCell.hidden = YES;
    }

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

 - (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ShowLogin"])
    {
        LoginViewController *loginController = [segue destinationViewController];
        //loginController.delegate = self;
    }
    else if ([[segue identifier] isEqualToString:@"AccountBinding"])
    {
//        AccountViewController *accountController = [segue destinationViewController];
//        [accountController.sinaweibo logOut];
    }
}

//implement loginviewcontroller delegate
-(void) loginViewController:(LoginViewController *) controller updateDisplayName:(NSString *) displayName
{
    self.userName.text = displayName;
}

#pragma mark - Table view data source

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.tableView.indexPathForSelectedRow.section == 0 && self.tableView.indexPathForSelectedRow.row == 0)
    {
        [self performSegueWithIdentifier:@"ShowLogin" sender:[tableView cellForRowAtIndexPath:indexPath]];
    }
    else if(self.tableView.indexPathForSelectedRow.section == 0 && self.tableView.indexPathForSelectedRow.row == 1)
    {
        [self performSegueWithIdentifier:@"AccountBinding" sender:[tableView cellForRowAtIndexPath:indexPath]];
    }
    else if(self.tableView.indexPathForSelectedRow.section == 2)
    {
        [self.accountManager.sinaweibo logOut];
        self.logoutCell.hidden = YES;
        self.userName.text = @"点击登录";
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)saveSetting:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

//implement socialaccountmanager delegate
-(void) socialAccountManager:(SocialAccountManager *) manager updateDisplayName:(NSString *) displayName
{
    self.userName.text = displayName;
}

-(void) socialAccountManager:(SocialAccountManager *) manager updateLogoutcell:(BOOL) display
{
    self.logoutCell.hidden = display;
}

@end
