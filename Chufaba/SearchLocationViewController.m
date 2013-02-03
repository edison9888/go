//
//  SearchLocationViewController.m
//  出发吧
//
//  Created by 张 辛欣 on 13-1-20.
//  Copyright (c) 2013年 出发吧APP团队. All rights reserved.
//

#import "SearchLocationViewController.h"
#import "Location.h"

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
    if (!self.lastLatitude) {
        self.lastLatitude = [NSNumber numberWithFloat:0];
        self.lastLongitude = [NSNumber numberWithFloat:0];
    }
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
    if([keyword length] > 0)
    {
        if (fetcher) {
            [fetcher cancel];
            [fetcher close];
        }
        NSString *encodedString = [keyword stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *url = [NSString stringWithFormat:@"http://api.jiepang.com/v1/locations/search?q=%@&source=100743&count=20&lat=%f&lon=%f", encodedString, [self.lastLatitude floatValue], [self.lastLongitude floatValue]];
        //NSLog(url);
        fetcher = [[JSONFetcher alloc]
                                initWithURLString: url
                                receiver:self
                                action:@selector(receiveResponse:)];
        [fetcher start];
        allLocationList = nil;
        [self.tableView reloadData];
    }
}

- (void)receiveResponse:(JSONFetcher *)aFetcher
{
    NSArray *locations = [aFetcher.result objectForKey:@"items"];
    if (locations) {
        allLocationList = [locations mutableCopy];
        [self.tableView reloadData];
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
    return [allLocationList count];
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
     
     NSArray *categories = [locationAtIndex objectForKey:@"categories"];
    if ([categories count] > 0) {
        NSDictionary *primaryCategory = [categories objectAtIndex:0];
        NSString *category = [Location getLocationCategoryByJiepangCategoryId:[primaryCategory objectForKey:@"id"]];
        
        cell.imageView.image = [Location getCategoryIcon:category];
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *locationAtIndex = [allLocationList objectAtIndex:indexPath.row];
    NSArray *categories = [locationAtIndex objectForKey:@"categories"];
    NSDictionary *primaryCategory = [categories objectAtIndex:0];
    NSString *category = [Location getLocationCategoryByJiepangCategoryId:[primaryCategory objectForKey:@"id"]];
    Location *location = [Location alloc];
    location.name = [locationAtIndex objectForKey:@"name"];
    location.address = [locationAtIndex objectForKey:@"addr"];
    location.category = category;
    location.latitude = [locationAtIndex objectForKey:@"lat"];
    location.longitude = [locationAtIndex objectForKey:@"lon"];
    [self.delegate didAddLocation: location];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.searchBar resignFirstResponder];
}


@end
