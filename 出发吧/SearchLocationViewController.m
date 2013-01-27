//
//  SearchLocationViewController.m
//  出发吧
//
//  Created by 张 辛欣 on 13-1-20.
//  Copyright (c) 2013年 出发吧APP团队. All rights reserved.
//

#import "SearchLocationViewController.h"
#import "JsonFetcher.h"
#import "SearchLocation.h"

@interface SearchLocationViewController ()

@end

@implementation SearchLocationViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        //self.tableView.tableHeaderView = self.searchBar;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _searchBar.delegate = (id)self;
    [_searchBar becomeFirstResponder];
    [_searchBar setShowsCancelButton:YES];
    
    searching = NO;
}

- (void)enableCancelButton:(UISearchBar*)searchBar
{
    for (id subview in [searchBar subviews])
    {
        if([subview isKindOfClass:[UIButton class]]){
            [subview setEnabled:YES];
        }
    }
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    //[self performSelector:@selector(enableCancelButton:) withObject:searchBar afterDelay:0.0];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [_searchBar resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText
{
    [self searchJiepangByKeyword:searchText];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
    [_searchBar resignFirstResponder];
    [self enableCancelButton:theSearchBar];
    [self searchJiepangByKeyword:_searchBar.text];
}

- (void)searchJiepangByKeyword:(NSString *)keyword {
    if(!searching && [keyword length] > 0)
    {
        searching = YES;
        NSString *encodedString = [keyword stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *url = [NSString stringWithFormat:@"http://api.jiepang.com/v1/locations/search?q=%@&source=100743&count=5", encodedString];
        JSONFetcher *fetcher = [[JSONFetcher alloc]
                                initWithURLString: url
                                receiver:self
                                action:@selector(receiveResponse:)];
        [fetcher start];
        allLocationList = nil;
        [self.tableView reloadData];
    }
}

- (void)receiveResponse:(JSONFetcher *)fetcher
{
    NSArray *locations = [fetcher.result objectForKey:@"items"];
    if (locations) {
        allLocationList = [locations mutableCopy];
        [self.tableView reloadData];
    }
    searching = NO;
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
    if (searching)
        return [allLocationList count];
    else
        return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SearchLocationCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSDictionary *locationAtIndex = [allLocationList objectAtIndex:indexPath.row];
    [[cell textLabel] setText:[locationAtIndex objectForKey: @"name"]];
    [[cell detailTextLabel] setText:[locationAtIndex objectForKey: @"addr"]];
    
    return cell;
}

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
    NSDictionary *locationAtIndex = [allLocationList objectAtIndex:indexPath.row];
    SearchLocation *location = [[SearchLocation alloc] initWithName:[locationAtIndex objectForKey:@"name"] address:[locationAtIndex objectForKey:@"addr"]];
    [self.delegate searchLocationViewController:self didAddSearchLocation: location];
}

@end
