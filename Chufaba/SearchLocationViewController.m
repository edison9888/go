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
    
    addLocationBtn = [[UIButton alloc] initWithFrame:CGRectMake(10.0f, 5.0f, 300.0f, 35.0f)];
    CALayer *addBtnLayer = addLocationBtn.layer;
    
//    CAGradientLayer *viewShadow = [[CAGradientLayer alloc] init];
//    viewShadow.frame = addLocationBtn.bounds;
//    viewShadow.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithRed:230/255.0 green:223/255.0 blue:209/255.0 alpha:1.0].CGColor,(id)[UIColor colorWithRed:227/255.0 green:219/255.0 blue:204/255.0 alpha:1.0].CGColor,nil];
//    [addBtnLayer addSublayer:viewShadow];
    
    [addLocationBtn setTitle:[NSString stringWithFormat:@"创建%@", self.category] forState:UIControlStateNormal];
    [addLocationBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    addLocationBtn.backgroundColor = [UIColor colorWithRed:230/255.0 green:223/255.0 blue:209/255.0 alpha:1.0];
    addBtnLayer.borderWidth = 1.0;
    addBtnLayer.borderColor = [UIColor grayColor].CGColor;
    addBtnLayer.cornerRadius = 5.0;
    
    addBtnLayer.masksToBounds = NO;
    addBtnLayer.shadowOffset = CGSizeMake(0, 1);
    addBtnLayer.shadowRadius = 1;
    addBtnLayer.shadowColor = [[UIColor colorWithRed:189/255.0 green:176/255.0 blue:153/255.0 alpha:1.0] CGColor];
    addBtnLayer.shadowOpacity = 1;
    
    [addLocationBtn addTarget:self action:@selector(addCustomLocation:) forControlEvents:UIControlEventTouchDown];
    
    showAddLocationBtn = NO;
}

- (IBAction)addCustomLocation:(id)sender
{
    AddLocationViewController *addLocationViewController = [[AddLocationViewController alloc] init];
    addLocationViewController.location = [[Location alloc] init];
    addLocationViewController.location.name = self.searchBar.text;
    addLocationViewController.location.category = self.category;
    addLocationViewController.hasCoordinate = NO;
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
        //NSString *addLocationBtnText = [NSString stringWithFormat:@"创建%@：%@", self.category, searchText];
        NSString *addLocationBtnText = [NSString stringWithFormat:@"搜不到 \"%@\" ？ 我来创建！", searchText];
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
        return [NSString stringWithFormat:@"{"
                "\"min_score\":3.5, "
                "\"sort\" : [ "
                    "{ \"_geo_distance\" : {"
                        "\"location\" : { \"lat\" : %f, \"lon\" : %f }, "
                        "\"order\" : \"asc\", "
                        "\"unit\" : \"km\" "
                    "} } ],"
                "\"query\":{ "
                    "\"bool\" : { "
                        "\"must\" : { \"term\" : { \"category\": \"%@\" } }, "
                        "\"must\" : { "
                            "\"multi_match\" :{"
                                "\"query\" : \"%@\","
                                "\"fields\" : [\"name\", \"name_en\" ,  \"query\"]"
                            "}"
                        "}}"
                "} }", [self.lastLatitude floatValue], [self.lastLongitude floatValue], self.category, keyword];
    } else {
        return [NSString stringWithFormat:@"{"
                "\"min_score\":3.5, "
                "\"query\":{ "
                    "\"bool\" : { "
                        "\"must\" : { \"term\" : { \"category\": \"%@\" } }, "
                        "\"must\" : { "
                            "\"multi_match\" :{"
                                "\"query\" : \"%@\","
                                "\"fields\" : [\"name\" ,  \"name_en\", \"query\"]"
                            "}"
                    "}}"
                "} }", self.category, keyword];
        
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
        fetcher.showAlerts = NO;
        [fetcher start];
        allLocationList = nil;
        //[self.tableView reloadData];
    }
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
        self.total = [(NSDictionary *)[(NSDictionary *)aFetcher.result objectForKey:@"hits"] objectForKey:@"total"];
        
        if (locations) {
            allLocationList = [locations mutableCopy];
            [self.tableView reloadData];
        }
    }
    fetcher = nil;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    allLocationList = [[NSMutableArray alloc] init];
    [self.tableView reloadData];
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
        
        if (locations) {
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
        if (city) {
            [[cell textLabel] setText: [NSString stringWithFormat: @"%@, %@", name, city]];
        } else {
            [[cell textLabel] setText: name];
        }
        [[cell detailTextLabel] setText: name_en];
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
    location.name = [locationAtIndex objectForKey: @"name"];
    location.nameEn = [locationAtIndex objectForKey: @"name_en"];
    location.country = [locationAtIndex objectForKey: @"country"];
    location.city = [locationAtIndex objectForKey: @"city"];
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
