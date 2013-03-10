//
//  SearchLocationViewController.m
//  出发吧
//
//  Created by 张 辛欣 on 13-1-20.
//  Copyright (c) 2013年 出发吧APP团队. All rights reserved.
//

#import "SearchLocationViewController.h"
#import "Location.h"
#import <QuartzCore/QuartzCore.h>

@interface SearchLocationViewController ()

@property NSNumber *total;
@property NSString *keyword;

@end

@implementation SearchLocationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIImage *image = [UIImage imageNamed:@"bar.png"];
    [self.searchBar setBackgroundImage:image];
    
    self.tableView.backgroundColor = [UIColor colorWithRed:244/255.0 green:241/255.0 blue:235/255.0 alpha:1.0];
    
    [_searchBar becomeFirstResponder];
    [_searchBar setShowsCancelButton:YES];
    
    addLocationBtn = [[UIButton alloc] initWithFrame:CGRectMake(10.0f, 5.0f, 300.0f, 35.0f)];
    [addLocationBtn setTitle:[NSString stringWithFormat:@"创建%@", self.category] forState:UIControlStateNormal];
    [addLocationBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    addLocationBtn.backgroundColor = [UIColor clearColor];
    [[addLocationBtn layer] setBorderWidth:1.0f];
    [[addLocationBtn layer] setBorderColor:[UIColor grayColor].CGColor];
    [addLocationBtn addTarget:self action:@selector(addCustomLocation:) forControlEvents:UIControlEventTouchDown];
    
    showAddLocationBtn = NO;
}

- (IBAction)addCustomLocation:(id)sender
{
    AddLocationViewController *addLocationViewController = [[AddLocationViewController alloc] init];
    addLocationViewController.addLocationName = self.searchBar.text;
    addLocationViewController.lastLatitude = self.lastLatitude;
    addLocationViewController.lastLongitude = self.lastLongitude;
    addLocationViewController.editLocationDelegate = self;
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:addLocationViewController];
    [self presentViewController:navController animated:YES completion:NULL];
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
    if([searchText length] == 0)
    {
        showAddLocationBtn = NO;
        allLocationList = nil;
        [self.tableView reloadData];
    }
    else
    {
        showAddLocationBtn = YES;
        NSString *addLocationBtnText = [NSString stringWithFormat:@"创建%@：%@", self.category, searchText];
        [addLocationBtn setTitle:addLocationBtnText forState:UIControlStateNormal];
        [self searchJiepangByKeyword:searchText];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
    [_searchBar resignFirstResponder];
    [self enableCancelButton:theSearchBar];
    [self searchJiepangByKeyword:_searchBar.text];
}

- (NSString *)getPostBody:(NSString *)keyword {
    if (self.lastLatitude && [self.lastLatitude intValue] != 10000) {
        return [NSString stringWithFormat:@"{\"min_score\":4.5, \"sort\" : [ { \"_geo_distance\" : { \"location\" : { \"lat\" : %f, \"lon\" : %f }, \"order\" : \"asc\", \"unit\" : \"km\" } } ], \"query\":{ \"bool\" : { \"must\" : { \"term\" : { \"category\": \"%@\" } }, \"must\" : { \"match\" : { \"query\" :  \"%@\" } } } } }", [self.lastLatitude floatValue], [self.lastLongitude floatValue], self.category, keyword];
    } else {
        return [NSString stringWithFormat:@"{\"min_score\":4.5, \"query\":{ \"bool\" : { \"must\" : { \"term\" : { \"category\": \"%@\" } }, \"must\" : { \"match\" : { \"query\" :  \"%@\"}}} } }", self.category, keyword];
    }
}

- (void)searchJiepangByKeyword:(NSString *)keyword {
    if([keyword length] > 0)
    {
        self.total = nil;
        self.keyword = keyword;
        if (fetcher) {
            [fetcher cancel];
            [fetcher close];
        }
        NSString *body = [self getPostBody:keyword];
        fetcher = [[JSONFetcher alloc]
                                initWithURLString:@"http://chufaba.me:9200/cfb/poi/_search?size=30&from=0"
                                body:body
                                receiver:self
                                action:@selector(receiveResponse:)];
        [fetcher start];
        allLocationList = nil;
        //[self.tableView reloadData];
    }
}

- (void)receiveResponse:(JSONFetcher *)aFetcher
{
    NSArray *locations = [(NSDictionary *)[(NSDictionary *)aFetcher.result objectForKey:@"hits"] objectForKey:@"hits"];
    self.total = [(NSDictionary *)[(NSDictionary *)aFetcher.result objectForKey:@"hits"] objectForKey:@"total"];
    
    if (locations) {
        allLocationList = [locations mutableCopy];
        [self.tableView reloadData];
    }
    
    fetcher = nil;
}

- (void)fetchRestResult
{
    if([self.keyword length] > 0)
    {
        NSInteger from = allLocationList.count;
        if (from >= [self.total intValue]) {
            return;
        };
        if (fetcher) {
            return;
        }
        
        NSString *body = [self getPostBody:self.keyword];
        fetcher = [[JSONFetcher alloc]
                   initWithURLString:[NSString stringWithFormat:@"http://chufaba.me:9200/cfb/poi/_search?size=30&from=%d", from]
                   body:body
                   receiver:self
                   action:@selector(receiveRestResult:)];
        [fetcher start];
    }
}

- (void)receiveRestResult:(JSONFetcher *)aFetcher
{
    NSArray *locations = [(NSDictionary *)[(NSDictionary *)aFetcher.result objectForKey:@"hits"] objectForKey:@"hits"];
    
    if (locations) {
        [allLocationList addObjectsFromArray:locations];
        [self.tableView reloadData];
    }
    
    fetcher = nil;
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
//    if(showAddLocationBtn)
//        return [allLocationList count] + 1;
//    else
//        return [allLocationList count];
    
    if ([allLocationList count] == 0)
    {
        if (fetcher)
        {
            return 1;
        }
        else
        {
            return 0;
        }
    }
    else
    {
        if ([allLocationList count] == [self.total intValue])
        {
            return [allLocationList count] + 1; //添加自定义地点的cell
        }
        else
        {
            return [allLocationList count] + 1; //菊花
        }
    }
}

- (float)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // This will create a "invisible" footer
    return 0.01f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.row < [allLocationList count])
    {
        NSString *CellIdentifier = @"SearchLocationCell";
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        NSDictionary *locationAtIndex = [(NSDictionary *)[allLocationList objectAtIndex:indexPath.row] objectForKey:@"_source"];
        NSString *name = [locationAtIndex objectForKey: @"name"];
        NSString *nameEn = [locationAtIndex objectForKey: @"name_en"];
        [[cell textLabel] setText: name.length > 0 ? name : nameEn];
        [[cell detailTextLabel] setText:[locationAtIndex objectForKey: @"address"]];
        cell.imageView.image = [Location getCategoryIcon:[locationAtIndex objectForKey:@"category"]];
    }
    else if ([allLocationList count] != [self.total intValue])
    {
        NSString *CellIdentifier = @"LoadingCell";
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil){
            cell = [[SearchTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.imageView.image = [UIImage imageNamed:@"loading.gif"];
        }
        [self fetchRestResult];
    }
    else
    {
        UITableViewCell *addLocationCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"addLocation"];
        [addLocationCell addSubview:addLocationBtn];
        
        [addLocationCell bringSubviewToFront:addLocationBtn];
        
        return addLocationCell;
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *locationAtIndex = [(NSDictionary *)[allLocationList objectAtIndex:indexPath.row] objectForKey:@"_source"];
    Location *location = [[Location alloc] init];
    NSString *name = [locationAtIndex objectForKey: @"name"];
    NSString *nameEn = [locationAtIndex objectForKey: @"name_en"];
    location.name = name.length > 0 ? name : nameEn;
    location.address = [locationAtIndex objectForKey:@"address"];
    location.transportation = [locationAtIndex objectForKey:@"transport"];
    location.category = [locationAtIndex objectForKey:@"category"];
    NSDictionary *point = [locationAtIndex objectForKey:@"location"];
    location.latitude = [point objectForKey:@"lat"];
    if ([location.latitude intValue] == 10000) {
        location.latitude = nil;
    }
    location.longitude = [point objectForKey:@"lon"];
    if ([location.longitude intValue] == 10000) {
        location.longitude = nil;
    }

    [self.searchDelegate notifyItinerayView:location];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.searchBar resignFirstResponder];
    [self enableCancelButton:self.searchBar];
}

-(void) AddLocationViewController:(AddLocationViewController *) addLocationViewController didFinishAdd:(Location *) location
{
    [self.searchDelegate notifyItinerayView:location];
}

@end
