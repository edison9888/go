//
//  SearchDestinationViewController.m
//  Chufaba
//
//  Created by Perry on 13-4-14.
//  Copyright (c) 2013年 ChufabaAPP团队. All rights reserved.
//

#import "SearchDestinationViewController.h"
#import <QuartzCore/QuartzCore.h>

#define TAG_UP_LINE 1
#define TAG_BOTTOM_LINE 2

@interface SearchDestinationViewController ()

@property int total;
@property BOOL disappearing;

@end

@implementation SearchDestinationViewController

- (void)viewWillDisappear:(BOOL)animated
{
    self.disappearing = true;
    [super viewWillDisappear:animated];
    [self cancelCurrentSearch];
}

- (void)setTitle:(NSString *)title
{
    [super setTitle:title];
    UILabel *titleView = (UILabel *)self.navigationItem.titleView;
    if (!titleView) {
        titleView = [[UILabel alloc] initWithFrame:CGRectZero];
        titleView.backgroundColor = [UIColor clearColor];
        titleView.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:20];
        titleView.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        
        titleView.textColor = [UIColor colorWithRed:196/255.0 green:230/255.0 blue:184/255.0 alpha:1.0];
        
        self.navigationItem.titleView = titleView;
    }
    titleView.text = title;
    [titleView sizeToFit];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:244/255.0 green:241/255.0 blue:235/255.0 alpha:1.0];
    
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 7, 40, 30)];
    [backBtn setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = btn;
    
    [self setTitle:@"搜索目的地"];
    
    self.searchBar.tintColor = [UIColor colorWithRed:26/255.0 green:128/255.0 blue:128/255.0 alpha:1.0];
    self.searchBar.placeholder = @"想去哪里旅行？";
    self.searchBar.barStyle = UIBarStyleBlack;
    self.searchBar.tintColor = [UIColor colorWithRed:227/255.0 green:219/255.0 blue:204/255.0 alpha:1.0];
    self.searchBar.backgroundImage = [UIImage imageNamed:@"bgbar.png"];
    [self.searchBar becomeFirstResponder];
    
    UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 44, self.view.bounds.size.width, 1)];
    bottomBorder.backgroundColor = [UIColor colorWithRed:227/255.0 green:219/255.0 blue:204/255.0 alpha:1.0];
    [self.searchBar addSubview:bottomBorder];
    
    self.tableView.backgroundColor = [UIColor colorWithRed:244/255.0 green:241/255.0 blue:235/255.0 alpha:1.0];
	[self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 1)];
    headerView.backgroundColor = [UIColor colorWithRed:227/255.0 green:219/255.0 blue:204/255.0 alpha:1.0];
    self.tableView.tableHeaderView = headerView;
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 1)];
    footerView.backgroundColor = [UIColor whiteColor];
    self.tableView.tableFooterView = footerView;
    
    if ([self.destination length] > 0) {
        self.searchBar.text = self.destination;
        [self searchDestination:self.destination];
    }
}

-(IBAction)cancel:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = YES;
    
    for (UIView *subView in searchBar.subviews) {
        if([subView isKindOfClass:[UIButton class]])
        {
            UIButton *cancelButton = (UIButton *)subView;
            [cancelButton setTitle:@"" forState:UIControlStateNormal];
            
            UIView *overlay = [[UIView alloc] initWithFrame:CGRectMake(2, 2, 40, 20)];
            [overlay setBackgroundColor:[UIColor clearColor]];
            [overlay setUserInteractionEnabled:NO];
            [cancelButton addSubview:overlay];
            
            UILabel *newLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, 40, 20)];
            newLabel.backgroundColor = [UIColor clearColor];
            newLabel.textColor = [UIColor colorWithRed:72/255.0 green:70/255.0 blue:66/255.0 alpha:1.0];
            newLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:12];
            [newLabel setText:@"取消"];
            [newLabel setTextAlignment:NSTextAlignmentCenter];
            [newLabel setUserInteractionEnabled:NO];
            [overlay addSubview:newLabel];
        }
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = NO;
    [searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText
{
    if (self.disappearing) {
        return;
    }
    searchText = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if([searchText length] == 0){
        self.destination = nil;
        [self clearResults];
    }else if(![searchText isEqualToString:self.destination]){
       [self searchDestination:searchText];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
    [_searchBar resignFirstResponder];
    [self searchBar:theSearchBar textDidChange:theSearchBar.text];
}

- (void)cancelCurrentSearch
{
    if (fetcher) {
        [fetcher cancel];
        fetcher = nil;
    }
}

- (void)clearResults
{
    [self cancelCurrentSearch];
    self.total = 0;
    allDestinationList = nil;
    [self.tableView reloadData];
}

- (void)searchDestination:(NSString *)destination{
    [self cancelCurrentSearch];
    self.destination = destination;
    
    NSString *body = [self getPostBody:destination];
    fetcher = [[JSONFetcher alloc]
               initWithURLString:@"http://chufaba.me:9200/cfb/city/_search?size=30&from=0"
               body:body
               receiver:self
               action:@selector(receiveResponse:)];
    fetcher.showAlerts = NO;
    [fetcher start];
}

- (NSString *)getPostBody:(NSString *)keyword {
    keyword = [keyword stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    keyword = [keyword stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    keyword = [keyword capitalizedString];
    return [NSString stringWithFormat:@
                       "{"
                       "    \"query\":{"
                       "        \"bool\" : {"
                       "            \"should\" : ["
                       "                {"
                       "                    \"bool\" : {"
                       "                        \"must\" : {"
                       "                            \"term\" : {"
                       "                                \"city\": \"\" "
                       "                            } "
                       "                        },"
                       "                        \"must\" : {"
                       "                            \"prefix\" : {"
                       "                                \"country\": \"%@\""
                       "                            } "
                       "                        },"
                       "                        \"boost\" : 5.0"
                       "                    }"
                       "                },"
                       "                {"
                       "                    \"bool\" : {"
                       "                        \"must\" : {"
                       "                            \"term\" : {"
                       "                                \"city_en\": \"\" "
                       "                            } "
                       "                        },"
                       "                        \"must\" : {"
                       "                            \"prefix\" : {"
                       "                                \"country_en\": \"%@\""
                       "                            }"
                       "                        },"
                       "                        \"boost\" : 5.0"
                       "                    }"
                       "                },"
                       "                {"
                       "                    \"bool\" : {"
                       "                        \"should\" : ["
                       "                            {"
                       "                                \"prefix\" : {"
                       "                                    \"city\": \"%@\" "
                       "                                } "
                       "                            },"
                       "                            {"
                       "                                \"prefix\" : {"
                       "                                    \"country\": {"
                       "                                        \"prefix\" : \"%@\","
                       "                                        \"boost\" : 2.0"
                       "                                    }"
                       "                                }"
                       "                            }"
                       "                        ],"
                       "                        \"minimum_number_should_match\" : 1"
                       "                    }"
                       "                },"
                       "                {"
                       "                    \"bool\" : {"
                       "                        \"should\" : ["
                       "                            {"
                       "                                \"prefix\" : {"
                       "                                    \"city_en\": \"%@\" "
                       "                                } "
                       "                            },"
                       "                            {"
                       "                                \"prefix\" : {"
                       "                                    \"country_en\": {"
                       "                                        \"prefix\" : \"%@\","
                       "                                        \"boost\" : 2.0"
                       "                                    }"
                       "                                }"
                       "                            }"
                       "                        ],"
                       "                        \"minimum_number_should_match\" : 1"
                       "                    }"
                       "                }"
                       "            ],"
                       "            \"minimum_number_should_match\" : 1"
                       "        }"
                       "    }"
                       "}"
                       , keyword, keyword, keyword, keyword, keyword, keyword];
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
        NSArray *destinations = [(NSDictionary *)[(NSDictionary *)aFetcher.result objectForKey:@"hits"] objectForKey:@"hits"];
        if (destinations.count == 0 ) {
            [self clearResults];
        } else {
            self.total = [[(NSDictionary *)[(NSDictionary *)aFetcher.result objectForKey:@"hits"] objectForKey:@"total"] intValue];
            allDestinationList = [destinations mutableCopy];
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
    if([self.destination length] > 0)
    {
        int from = allDestinationList.count;
        if (from >= self.total) {
            return;
        }
        [self cancelCurrentSearch];
        NSString *body = [self getPostBody:self.destination];
        fetcher = [[JSONFetcher alloc]
                   initWithURLString:[NSString stringWithFormat:@"http://chufaba.me:9200/cfb/city/_search?size=30&from=%d", from]
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
        NSArray *destinations = [(NSDictionary *)[(NSDictionary *)aFetcher.result objectForKey:@"hits"] objectForKey:@"hits"];
        if (destinations.count > 0) {
            [allDestinationList addObjectsFromArray:destinations];
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
    return [allDestinationList count];
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
    if (indexPath.row < [allDestinationList count])
    {
        NSString *CellIdentifier = @"SearchDestinationCell";
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        cell.textLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:16];
        cell.textLabel.textColor = [UIColor colorWithRed:72/255.0 green:70/255.0 blue:66/255.0 alpha:1.0];
        cell.textLabel.highlightedTextColor = [UIColor colorWithRed:72/255.0 green:70/255.0 blue:66/255.0 alpha:1.0];
        
        UIView *bgColorView = [[UIView alloc] init];
        [bgColorView setBackgroundColor:[UIColor colorWithRed:233/255.0 green:227/255.0 blue:214/255.0 alpha:1.0]];
        [cell setSelectedBackgroundView:bgColorView];
        
        NSDictionary *destAtIndex = [(NSDictionary *)[allDestinationList objectAtIndex:indexPath.row] objectForKey:@"_source"];
        NSString *city = [destAtIndex objectForKey: @"city"];
        NSString *country = [destAtIndex objectForKey: @"country"];
        if ([city length] > 0 && [country length] > 0) {
            [[cell textLabel] setText: [NSString stringWithFormat: @"%@，%@", city, country]];
        } else if([country length] > 0) {
            [[cell textLabel] setText: country];
        }
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 39, self.view.bounds.size.width, 1)];
        lineView.backgroundColor = [UIColor colorWithRed:227/255.0 green:219/255.0 blue:204/255.0 alpha:1.0];
        [cell.contentView addSubview:lineView];
        
        lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 1)];
        lineView.backgroundColor = [UIColor whiteColor];
        [cell.contentView addSubview:lineView];
        
//        UIView *uplineView = [cell.contentView viewWithTag:TAG_UP_LINE];
//        if (indexPath.row > 0) {
//            if (uplineView) {
//                [uplineView setHidden:false];
//            } else {
//                uplineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.contentView.frame.size.width, 1)];
//                uplineView.backgroundColor = [UIColor whiteColor];;
//                uplineView.tag = TAG_UP_LINE;
//                [cell.contentView addSubview:uplineView];
//            }
//        } else {
//            if (uplineView){
//                [uplineView setHidden:true];
//            }
//        }
//
//        UIView *bottomlineView = [cell.contentView viewWithTag:TAG_BOTTOM_LINE];
//        if (indexPath.row < [allDestinationList count] - 1) {
//            if (bottomlineView) {
//                [bottomlineView setHidden:false];
//            } else {
//                bottomlineView = [[UIView alloc] initWithFrame:CGRectMake(0, 39, cell.contentView.frame.size.width, 1)];
//                bottomlineView.backgroundColor = [UIColor colorWithRed:227/255.0 green:219/255.0 blue:204/255.0 alpha:1.0];
//                bottomlineView.tag = TAG_BOTTOM_LINE;
//                [cell.contentView addSubview:bottomlineView];
//            }
//        } else {
//            if (bottomlineView){
//                [bottomlineView setHidden:true];
//            }
//        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.0f;
}

#pragma mark - Table view delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *destAtIndex = [(NSDictionary *)[allDestinationList objectAtIndex:indexPath.row] objectForKey:@"_source"];
    NSString *city = [destAtIndex objectForKey: @"city"];
    NSString *country = [destAtIndex objectForKey: @"country"];
    if (city.length > 0) {
        [self.delegate updateDestination:city];
    } else {
        [self.delegate updateDestination:country];
    }
    [self cancel:self];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.searchBar resignFirstResponder];
}

@end
