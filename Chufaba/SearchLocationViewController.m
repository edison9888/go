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

@property int total;
@property NSString *keyword;
@property BOOL searchSameCategory;

@end

@implementation SearchLocationViewController

#define TAG_IMPLYLABEL 1

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.searchSameCategory = YES; //默认显示搜索当前类别
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self cancelCurrentSearch];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];

    self.searchBar.barStyle = UIBarStyleBlack;
    self.searchBar.translucent = YES;
    self.searchBar.backgroundColor = [UIColor clearColor];
    self.searchBar.placeholder = [NSString stringWithFormat:@"搜索%@", self.category];
    
//    for (UIView *subview in self.searchBar.subviews)
//    {
//        if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")])
//        {
//            [subview removeFromSuperview];
//            break;  
//        }  
//    }
    
//    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bar.png"]];
//    [self.searchBar insertSubview:imageView atIndex:1];
    
    UIImage *image = [UIImage imageNamed:@"bar.png"];
    [self.searchBar setBackgroundImage:image];
    
    //[[UISearchBar appearance] setSearchFieldBackgroundImage:[UIImage imageNamed:@"bar.png"]forState:UIControlStateNormal];
    
    self.tableView.backgroundColor = [UIColor colorWithRed:244/255.0 green:241/255.0 blue:235/255.0 alpha:1.0];
    
    [_searchBar becomeFirstResponder];
    [_searchBar setShowsCancelButton:YES];
    
    addLocationBtn = [[UIButton alloc] initWithFrame:CGRectMake(10.0f, 5.0f, 300.0f, 44.0f)];
    
    UILabel *implyLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 6.0f, 240.0f, 32.0f)];
    implyLabel.backgroundColor = [UIColor clearColor];
    implyLabel.textColor = [UIColor colorWithRed:72/255.0 green:70/255.0 blue:66/255.0 alpha:1.0];
    implyLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:16];
    implyLabel.text = @"搜不到\" \"，我来创建";
    implyLabel.tag = TAG_IMPLYLABEL;
    [addLocationBtn addSubview:implyLabel];
    [addLocationBtn setBackgroundImage:[UIImage imageNamed:@"add_btn.png"]
                        forState:UIControlStateNormal];
    
    [addLocationBtn addTarget:self action:@selector(addCustomLocation:) forControlEvents:UIControlEventTouchDown];
}

- (IBAction)addCustomLocation:(id)sender
{
    AddLocationViewController *addLocationViewController = [[AddLocationViewController alloc] init];
    addLocationViewController.location = [[Location alloc] init];
    addLocationViewController.location.name = self.searchBar.text;
    addLocationViewController.location.category = self.category;
    addLocationViewController.hasCoordinate = NO;
    addLocationViewController.addLocation = YES;
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
    searchText = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if([searchText length] == 0)
    {
        self.keyword = nil;
        [self clearResults];
    }
    else if(![searchText isEqualToString:self.keyword])
    {
        NSString *addLocationBtnText = [NSString stringWithFormat:@"搜不到 \"%@\" ？ 我来创建！", searchText];
        ((UILabel *)[addLocationBtn viewWithTag:TAG_IMPLYLABEL]).text = addLocationBtnText;
        [self searchPoiByKeyword:searchText andSameCategory:YES];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
    [_searchBar resignFirstResponder];
    [self enableCancelButton:theSearchBar];
    [self searchBar:theSearchBar textDidChange:theSearchBar.text];
}

- (NSString *)getSameCategoryPostBody:(NSString *)keyword {
    NSString *query = [NSString stringWithFormat:@
                       "    \"min_score\" : 2.0,"
                       "    \"query\":{"
                       "        \"bool\" : { "
                       "            \"must\" : {"
                       "                \"term\" : {"
                       "                    \"category\":\"%@\""
                       "                }"
                       "            },"
                       "            \"should\" : ["
                       "                {"
                       "                    \"match_phrase_prefix\" :{"
                       "                        \"query\" : {"
                       "                            \"query\" : \"%@\","
                       "                            \"max_expansions\" : 10"
                       "                        }"
                       "                    }"
                       "                },"
                       "                {"
                       "                    \"multi_match\" :{"
                       "                        \"query\" : \"%@\","
                       "                        \"fields\" : [ \"name\", \"name_en\", \"query\" ]"
                       "                    }"
                       "                }"
                       "            ],"
                       "            \"minimum_number_should_match\" : 1"
                       "        }"
                       "    }"
                       , self.category, keyword, keyword];
    if (self.lastLatitude && [self.lastLatitude intValue] != 10000) {
        return [NSString stringWithFormat:@"{"
                "\"sort\" : [ "
                "{ \"_geo_distance\" : {"
                "\"location\" : { \"lat\" : %f, \"lon\" : %f }, "
                "\"order\" : \"asc\", "
                "\"unit\" : \"km\" "
                "} } ],"
                "%@}", [self.lastLatitude floatValue], [self.lastLongitude floatValue], query];
    } else {
        return [NSString stringWithFormat:@"{%@}", query];
    }
}

- (NSString *)getOtherCategoryPostBody:(NSString *)keyword {
    NSString *query = [NSString stringWithFormat:@
                       "    \"min_score\" : 2.0,"
                       "    \"query\":{"
                       "        \"bool\" : { "
                       "            \"must_not\" : {"
                       "                \"term\" : {"
                       "                    \"category\":\"%@\""
                       "                }"
                       "            },"
                       "            \"should\" : ["
                       "                {"
                       "                    \"match_phrase_prefix\" :{"
                       "                        \"query\" : {"
                       "                            \"query\" : \"%@\","
                       "                            \"max_expansions\" : 10"
                       "                        }"
                       "                    }"
                       "                },"
                       "                {"
                       "                    \"multi_match\" :{"
                       "                        \"query\" : \"%@\","
                       "                        \"fields\" : [ \"name\", \"name_en\", \"query\" ]"
                       "                    }"
                       "                }"
                       "            ],"
                       "            \"minimum_number_should_match\" : 1"
                       "        }"
                       "    }"
                       , self.category, keyword, keyword];
    if (self.lastLatitude && [self.lastLatitude intValue] != 10000) {
        return [NSString stringWithFormat:@"{"
                "\"sort\" : [ "
                    "{ \"_geo_distance\" : {"
                        "\"location\" : { \"lat\" : %f, \"lon\" : %f }, "
                        "\"order\" : \"asc\", "
                        "\"unit\" : \"km\" "
                    "} } ],"
                "%@}", [self.lastLatitude floatValue], [self.lastLongitude floatValue], query];
    } else {
        return [NSString stringWithFormat:@"{%@}", query];
    }
}

- (void)cancelCurrentSearch
{
    if (fetcher) {
        [fetcher cancel];
        [fetcher close];
        fetcher = nil;
    }
}

- (void)clearResults
{
    [self cancelCurrentSearch];
    self.total = 0;
    allLocationList = nil;
    [self.tableView reloadData];
}

- (void)searchPoiByKeyword:(NSString *)keyword andSameCategory:(Boolean)category{
    [self cancelCurrentSearch];
    self.searchSameCategory = category;
    self.keyword = keyword;
 
    NSString *body;
    if (category) {
        body = [self getSameCategoryPostBody:keyword];
    } else {
        body = [self getOtherCategoryPostBody:keyword];
    }
    fetcher = [[JSONFetcher alloc]
               initWithURLString:@"http://chufaba.me:9200/cfb/poi/_search?size=30&from=0"
               body:body
               receiver:self
               action:@selector(receiveResponse:)];
    fetcher.showAlerts = NO;
    [fetcher start];
}

- (void)receiveResponse:(JSONFetcher *)aFetcher
{
    if (aFetcher.failureCode) {
        UIAlertView *alert =
        [[UIAlertView alloc]
         initWithTitle:nil
         message:@"服务器跪了，请稍后重试"
         delegate:self
         cancelButtonTitle:@"确定"
         otherButtonTitles:nil];
        [alert show];
    } else {
        NSArray *locations = [(NSDictionary *)[(NSDictionary *)aFetcher.result objectForKey:@"hits"] objectForKey:@"hits"];
        if (locations.count == 0 ) {
            if(self.searchSameCategory) {
                [self searchPoiByKeyword:self.keyword andSameCategory:NO];
            }else{
                [self clearResults];
            }
        } else {
            self.total = [[(NSDictionary *)[(NSDictionary *)aFetcher.result objectForKey:@"hits"] objectForKey:@"total"] intValue];
            allLocationList = [locations mutableCopy];
            [self.tableView reloadData];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self clearResults];
}

- (void)fetchRestResult
{
    if([self.keyword length] > 0)
    {
        int from = allLocationList.count;
        if (from >= self.total) {
            return;
        }
        [self cancelCurrentSearch];
        NSString *body;
        if (self.searchSameCategory) {
            body = [self getSameCategoryPostBody:self.keyword];
        } else {
            body = [self getOtherCategoryPostBody:self.keyword];
        }
        fetcher = [[JSONFetcher alloc]
                   initWithURLString:[NSString stringWithFormat:@"http://chufaba.me:9200/cfb/poi/_search?size=30&from=%d", from]
                   body:body
                   receiver:self
                   action:@selector(receiveRestResult:)];
        fetcher.showAlerts = NO;
        [fetcher start];
    }
}

- (void)receiveRestResult:(JSONFetcher *)aFetcher
{
    if (aFetcher.failureCode) {
        UIAlertView *alert =
        [[UIAlertView alloc]
         initWithTitle:nil
         message:@"服务器跪了，请稍后重试"
         delegate:self
         cancelButtonTitle:@"确定"
         otherButtonTitles:nil];
        [alert show];
    } else {
        NSArray *locations = [(NSDictionary *)[(NSDictionary *)aFetcher.result objectForKey:@"hits"] objectForKey:@"hits"];
        if (locations.count > 0) {
            [allLocationList addObjectsFromArray:locations];
            [self.tableView reloadData];
        }
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
    if (self.keyword.length == 0) {
        return 0;
    } else {
        return [allLocationList count] + 1;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"搜索%@", self.searchSameCategory ? self.category : @"所有类型"];
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
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        NSDictionary *locationAtIndex = [(NSDictionary *)[allLocationList objectAtIndex:indexPath.row] objectForKey:@"_source"];
        NSString *name = [locationAtIndex objectForKey: @"name"];
        NSString *name_en = [locationAtIndex objectForKey: @"name_en"];
        NSString *city = [locationAtIndex objectForKey: @"city"];
        if ([name length] == 0) {
            name = name_en;
            name_en = nil;
        }
        if ([city length] > 0) {
            [[cell textLabel] setText: [NSString stringWithFormat: @"%@, %@", name, city]];
        } else {
            [[cell textLabel] setText: name];
        }
        cell.textLabel.textColor = [UIColor colorWithRed:72/255.0 green:70/255.0 blue:66/255.0 alpha:1.0];
        cell.textLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:16];
        
        [[cell detailTextLabel] setText: name_en];
        cell.detailTextLabel.textColor = [UIColor colorWithRed:153/255.0 green:150/255.0 blue:145/255.0 alpha:1.0];
        cell.detailTextLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:12];
        
        cell.imageView.image = [Location getCategoryIconMedium:[locationAtIndex objectForKey:@"category"]];
    }
    else if ([allLocationList count] != self.total)
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
    
    //add separator line
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 60, self.view.bounds.size.width, 1)];
    lineView.backgroundColor = [UIColor colorWithRed:227/255.0 green:219/255.0 blue:204/255.0 alpha:1.0];
    [cell.contentView addSubview:lineView];
    
    lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 61, self.view.bounds.size.width, 1)];
    lineView.backgroundColor = [UIColor whiteColor];
    [cell.contentView addSubview:lineView];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 62.0f;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *locationAtIndex = [(NSDictionary *)[allLocationList objectAtIndex:indexPath.row] objectForKey:@"_source"];
    Location *location = [[Location alloc] init];
    location.poiId = [locationAtIndex objectForKey: @"id"]; 
    location.name = [locationAtIndex objectForKey: @"name"];
    location.nameEn = [locationAtIndex objectForKey: @"name_en"];
    location.country = [locationAtIndex objectForKey: @"country"];
    location.city = [locationAtIndex objectForKey: @"city"];
    location.category = [locationAtIndex objectForKey:@"category"];
    location.address = [locationAtIndex objectForKey:@"address"];
    NSDictionary *point = [locationAtIndex objectForKey:@"location"];
    location.latitude = [point objectForKey:@"lat"];
    if ([location.latitude intValue] == 10000) {
        location.latitude = nil;
    }
    location.longitude = [point objectForKey:@"lon"];
    if ([location.longitude intValue] == 10000) {
        location.longitude = nil;
    }
    location.transportation = [locationAtIndex objectForKey:@"transport"];
    location.opening = [locationAtIndex objectForKey:@"opening"];
    location.fee = [locationAtIndex objectForKey:@"fee"];
    location.website = [locationAtIndex objectForKey:@"website"];

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
