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
        NSString *encodedString = (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                       NULL,
                                                                                       (CFStringRef)keyword,
                                                                                       NULL,
                                                                                       CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                                       kCFStringEncodingUTF8));
        NSString *url = [NSString stringWithFormat:@"http://106.187.34.224:3000/pois.json?name=%@", encodedString];
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
    NSArray *locations = aFetcher.result;
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
    NSString *name = [locationAtIndex objectForKey: @"name"];
    NSString *nameEn = [locationAtIndex objectForKey: @"name_en"];
    [[cell textLabel] setText: name.length > 0 ? name : nameEn];
    [[cell detailTextLabel] setText:[locationAtIndex objectForKey: @"address"]];
    cell.imageView.image = [Location getCategoryIcon:[locationAtIndex objectForKey:@"category"]];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *locationAtIndex = [allLocationList objectAtIndex:indexPath.row]; 
    Location *location = [Location alloc];
    NSString *name = [locationAtIndex objectForKey: @"name"];
    NSString *nameEn = [locationAtIndex objectForKey: @"name_en"];
    location.name = name.length > 0 ? name : nameEn;
    location.address = [locationAtIndex objectForKey:@"address"];
    location.transportation = [locationAtIndex objectForKey:@"transport"];
    location.category = [locationAtIndex objectForKey:@"category"];
    location.latitude = [locationAtIndex objectForKey:@"latitude"];
    location.longitude = [locationAtIndex objectForKey:@"longitude"];
    [self.delegate didAddLocation: location];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.searchBar resignFirstResponder];
    [self enableCancelButton:self.searchBar];
}


@end
