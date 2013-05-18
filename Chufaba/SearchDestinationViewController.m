//
//  SearchDestinationViewController.m
//  Chufaba
//
//  Created by Perry on 13-4-14.
//  Copyright (c) 2013年 ChufabaAPP团队. All rights reserved.
//

#import "SearchDestinationViewController.h"
#import "CfbSearchBar.h"
#import <QuartzCore/QuartzCore.h>

#define SEARCH_TIMEOUT 10

#define TAG_UP_LINE 1
#define TAG_BOTTOM_LINE 2

@interface SearchDestinationViewController ()
{
    BOOL isLineHeader;
    NSTimer *timer;
}

@property int total;
@property BOOL disappearing;
//@property BOOL showNoResultHint;
@property UIActivityIndicatorView *loadingView;

@end

@implementation SearchDestinationViewController

- (void)viewWillDisappear:(BOOL)animated
{
    self.disappearing = true;
    [super viewWillDisappear:animated];
    [self cancelCurrentSearch];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"搜索目的地";
    
    self.view.backgroundColor = [UIColor colorWithRed:244/255.0 green:241/255.0 blue:235/255.0 alpha:1.0];
    
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 7, 40, 30)];
    [backBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backBtn setImage:[UIImage imageNamed:@"back_click"] forState:UIControlStateHighlighted];
    [backBtn addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = btn;
    
    CGRect tableFrame = self.view.bounds;
    tableFrame.size.height -=44;
    self.tableView = [[UITableView alloc] initWithFrame:tableFrame];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor colorWithRed:244/255.0 green:241/255.0 blue:235/255.0 alpha:1.0];
	[self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.rowHeight = 40.0f;
    [self.view addSubview:self.tableView];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    self.searchBar.delegate = self;
    self.searchBar.placeholder = @"想去哪里旅行？";
    self.searchBar.text = self.destination;
    self.searchBar.tintColor = [UIColor colorWithRed:227/255.0 green:219/255.0 blue:204/255.0 alpha:1.0];
    self.searchBar.backgroundImage = [[UIImage imageNamed:@"bg_Search"] stretchableImageWithLeftCapWidth:2 topCapHeight:0];
    for(id cc in [self.searchBar subviews])
    {
        if([cc isKindOfClass:[UITextField class]])
        {
            UITextField *searchField = (UITextField *)cc;
            UIImageView *view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Search"]];
            searchField.leftView = view;
            searchField.textColor = [UIColor colorWithRed:72/255.0 green:70/255.0 blue:66/255.0 alpha:1.0];
            searchField.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:16];
            searchField.clearButtonMode = UITextFieldViewModeWhileEditing;
        }
    }
    [self.view addSubview:self.searchBar];

    self.tableView.contentInset = UIEdgeInsetsMake(CGRectGetHeight(self.searchBar.bounds), 0, 0, 0);
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(CGRectGetHeight(self.searchBar.bounds), 0, 0, 0);
    
    if ([self.destination length] > 0)
    {
        isLineHeader = TRUE;
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 1)];
        headerView.backgroundColor = [UIColor colorWithRed:227/255.0 green:219/255.0 blue:204/255.0 alpha:1.0];
        self.tableView.tableHeaderView = headerView;
    }
    else
    {
        isLineHeader = FALSE;
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
        headerView.backgroundColor = [UIColor colorWithRed:253/255.0 green:249/255.0 blue:242/255.0 alpha:1.0];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0, 100.0, 20.0)];
        label.text = @"热门目的地";
        label.textColor = [UIColor colorWithRed:189/255.0 green:176/255.0 blue:153/255.0 alpha:1.0];
        label.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:12];
        label.backgroundColor = [UIColor clearColor];
        [headerView addSubview:label];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
        lineView.backgroundColor = [UIColor whiteColor];
        [headerView addSubview:lineView];
        
        lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 19, 320, 1)];
        lineView.backgroundColor = [UIColor colorWithRed:227/255.0 green:219/255.0 blue:204/255.0 alpha:1.0];
        [headerView addSubview:lineView];
        
        self.tableView.tableHeaderView = headerView;
    }
}

- (void) viewDidAppear:(BOOL)animated
{
    if ([self.destination length] > 0)
    {
        [self searchDestination:self.destination];
    }
    else
    {
        [self getHotDestinations];
    }
}

-(IBAction)cancel:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText
{
    if (self.disappearing) {
        return;
    }
    searchText = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if([searchText length] == 0){
        self.destination = nil;
        //self.showNoResultHint = NO;
        [self getHotDestinations];
    }else if(![searchText isEqualToString:self.destination]){
        [self searchDestination:searchText];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
    theSearchBar.showsCancelButton = NO;
    [theSearchBar resignFirstResponder];
    [self searchBar:theSearchBar textDidChange:theSearchBar.text];
}

- (void)cancelCurrentSearch
{
    if (fetcher) {
        [fetcher cancel];
        fetcher = nil;
    }
    [self hideLoading];
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
}

- (void)clearResults
{
    [self cancelCurrentSearch];
    self.total = 0;
    allDestinationList = nil;
    [self.tableView reloadData];
}

- (void)showLoading
{
    if (!self.loadingView) {
        self.loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.loadingView setFrame:CGRectMake(120, 80, 60, 60)];
        [self.view addSubview:self.loadingView];
    }
    [self.view bringSubviewToFront:self.loadingView];
    [self.loadingView startAnimating];
}

- (void)hideLoading
{
    if (self.loadingView) {
        [self.loadingView stopAnimating];
    }
}

- (void)searchDestination:(NSString *)destination
{
    [self cancelCurrentSearch];
    //self.showNoResultHint = NO;
    [self clearResults];
    self.destination = destination;
    
    NSString *body = [self getPostBody:destination];
    fetcher = [[JSONFetcher alloc]
               initWithURLString:@"http://chufaba.me:9200/cfb/city/_search?size=30&from=0"
               body:body
               receiver:self
               action:@selector(receiveResponse:)];
    fetcher.showAlerts = NO;
    [fetcher start];
    
    [self showLoading];
    timer = [NSTimer scheduledTimerWithTimeInterval:SEARCH_TIMEOUT target:self selector:@selector(searchTimeout) userInfo:nil repeats:NO];
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
            "                            \"prefix\" : {"
            "                                \"country\": \"%@\""
            "                            } "
            "                        },"
            "                        \"must\" : {"
            "                            \"term\" : {"
            "                                \"province\": \"\" "
            "                            } "
            "                        },"
            "                        \"must\" : {"
            "                            \"term\" : {"
            "                                \"city\": \"\" "
            "                            } "
            "                        },"
            "                        \"boost\" : 5.0"
            "                    }"
            "                },"
            "                {"
            "                    \"bool\" : {"
            "                        \"must\" : {"
            "                            \"prefix\" : {"
            "                                \"country_en\": \"%@\""
            "                            }"
            "                        },"
            "                        \"must\" : {"
            "                            \"term\" : {"
            "                                \"province_en\": \"\" "
            "                            } "
            "                        },"
            "                        \"must\" : {"
            "                            \"term\" : {"
            "                                \"city_en\": \"\" "
            "                            } "
            "                        },"
            "                        \"boost\" : 5.0"
            "                    }"
            "                },"
            "                {"
            "                    \"bool\" : {"
            "                        \"must\" : {"
            "                            \"prefix\" : {"
            "                                \"province\": \"%@\" "
            "                            } "
            "                        },"
            "                        \"must\" : {"
            "                            \"term\" : {"
            "                                \"city\": \"\" "
            "                            } "
            "                        },"
            "                        \"boost\" : 4.0"
            "                    }"
            "                },"
            "                {"
            "                    \"bool\" : {"
            "                        \"must\" : {"
            "                            \"prefix\" : {"
            "                                \"province_en\": \"%@\" "
            "                            } "
            "                        },"
            "                        \"must\" : {"
            "                            \"term\" : {"
            "                                \"city_en\": \"\" "
            "                            } "
            "                        },"
            "                        \"boost\" : 4.0"
            "                    }"
            "                },"
            "                {"
            "                    \"bool\" : {"
            "                        \"should\" : ["
            "                            {"
            "                                \"prefix\" : {"
            "                                    \"country\": {"
            "                                        \"prefix\" : \"%@\","
            "                                        \"boost\" : 3.0"
            "                                    }"
            "                                }"
            "                            },"
            "                            {"
            "                                \"prefix\" : {"
            "                                    \"province\": {"
            "                                        \"prefix\" : \"%@\","
            "                                        \"boost\" : 2.0"
            "                                    }"
            "                                } "
            "                            },"
            "                            {"
            "                                \"prefix\" : {"
            "                                    \"city\": \"%@\" "
            "                                } "
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
            "                                    \"country_en\": {"
            "                                        \"prefix\" : \"%@\","
            "                                        \"boost\" : 3.0"
            "                                    }"
            "                                }"
            "                            },"
            "                            {"
            "                                \"prefix\" : {"
            "                                    \"province_en\": {"
            "                                        \"prefix\" : \"%@\","
            "                                        \"boost\" : 2.0"
            "                                    }"
            "                                } "
            "                            },"
            "                            {"
            "                                \"prefix\" : {"
            "                                    \"city_en\": \"%@\" "
            "                                } "
            "                            }"
            "                        ],"
            "                        \"minimum_number_should_match\" : 1"
            "                    }"
            "                }"
            "            ],"
            "            \"minimum_number_should_match\" : 1"
            "        }"
            "    }"
            "}", keyword, keyword, keyword, keyword, keyword, keyword, keyword, keyword, keyword,keyword];
}

- (void)receiveResponse:(JSONFetcher *)aFetcher
{
    [self hideLoading];
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
    //self.showNoResultHint = YES;
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
        if (destinations.count == 0) {
            [self clearResults];
        } else {
            self.total = [[(NSDictionary *)[(NSDictionary *)aFetcher.result objectForKey:@"hits"] objectForKey:@"total"] intValue];
            allDestinationList = [destinations mutableCopy];
            [self.tableView reloadData];
            if(!isLineHeader)
            {
                UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 1)];
                lineView.backgroundColor = [UIColor colorWithRed:227/255.0 green:219/255.0 blue:204/255.0 alpha:1.0];
                self.tableView.tableHeaderView = lineView;
                isLineHeader = TRUE;
            }
        }
    }
}

- (void)searchTimeout
{
    [self cancelCurrentSearch];
    UIAlertView *alert =
    [[UIAlertView alloc]
     initWithTitle:nil
     message:@"网速太慢了，请稍后重试"
     delegate:nil
     cancelButtonTitle:@"确定"
     otherButtonTitles:nil];
    [alert show];
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
        timer = [NSTimer scheduledTimerWithTimeInterval:SEARCH_TIMEOUT target:self selector:@selector(searchTimeout) userInfo:nil repeats:NO];
    }
}

- (void)receiveRestResult:(JSONFetcher *)aFetcher
{
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
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
            if(!isLineHeader)
            {
                UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 1)];
                lineView.backgroundColor = [UIColor colorWithRed:227/255.0 green:219/255.0 blue:204/255.0 alpha:1.0];
                self.tableView.tableHeaderView = lineView;
                isLineHeader = TRUE;
            }
        }
    }
    
    fetcher = nil;
}

- (void)getHotDestinations
{
    [self cancelCurrentSearch];
    //self.showNoResultHint = NO;
    [self clearResults];
    
    fetcher = [[JSONFetcher alloc]
               initWithURLString:@"http://chufaba.me:3000/hot_destinations.json"
               receiver:self
               action:@selector(receiveHotDestinations:)];
    fetcher.showAlerts = NO;
    [fetcher start];
    
    [self showLoading];
    timer = [NSTimer scheduledTimerWithTimeInterval:SEARCH_TIMEOUT target:self selector:@selector(searchTimeout) userInfo:nil repeats:NO];
}

- (void)receiveHotDestinations:(JSONFetcher *)aFetcher
{
    [self hideLoading];
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
    if (!aFetcher.failureCode) {
        NSArray *destinations = (NSArray *)aFetcher.result;
        if (destinations.count > 0) {
            allDestinationList = [[NSMutableArray alloc] init];
            self.total = destinations.count;
            for (id object in destinations) {
                NSDictionary *source = [[NSDictionary alloc] initWithObjectsAndKeys:[(NSDictionary *)object objectForKey:@"destination"], @"city", nil];
                NSDictionary *dest = [[NSDictionary alloc] initWithObjectsAndKeys:source, @"_source", nil];
                [allDestinationList addObject:dest];
            }
            [self.tableView reloadData];
            if(isLineHeader)
            {
                UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
                headerView.backgroundColor = [UIColor colorWithRed:253/255.0 green:249/255.0 blue:242/255.0 alpha:1.0];
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0, 100.0, 20.0)];
                label.text = @"热门目的地";
                label.textColor = [UIColor colorWithRed:189/255.0 green:176/255.0 blue:153/255.0 alpha:1.0];
                label.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:12];
                label.backgroundColor = [UIColor clearColor];
                [headerView addSubview:label];
                
                UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
                lineView.backgroundColor = [UIColor whiteColor];
                [headerView addSubview:lineView];
                
                lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 19, 320, 1)];
                lineView.backgroundColor = [UIColor colorWithRed:227/255.0 green:219/255.0 blue:204/255.0 alpha:1.0];
                [headerView addSubview:lineView];
                
                self.tableView.tableHeaderView = headerView;
                isLineHeader = FALSE;
            }
        }
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
    if (self.total > 0)
    {
        if ([allDestinationList count] < self.total) {
            return [allDestinationList count] + 1; //获取剩下的结果
        }
        else
        {
            return [allDestinationList count];
        }
    }
    else
    {
        return 0;
    }
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
        NSString *country = [destAtIndex objectForKey: @"country"];
        NSString *province = [destAtIndex objectForKey: @"province"];
        NSString *city = [destAtIndex objectForKey: @"city"];
        NSMutableArray *dests = [[NSMutableArray alloc]init];
        if (city.length > 0) {
            [dests addObject:city];
        }
        if (province.length > 0) {
            [dests addObject:province];
        }
        if ([country length] > 0) {
            [dests addObject:country];
        }
        [cell.textLabel setText:[dests componentsJoinedByString:@"，"]];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 39, self.view.bounds.size.width, 1)];
        lineView.backgroundColor = [UIColor colorWithRed:227/255.0 green:219/255.0 blue:204/255.0 alpha:1.0];
        [cell.contentView addSubview:lineView];
    }
    else if (self.total > 0)
    {
        NSString *CellIdentifier = @"LoadingCell";
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        UIActivityIndicatorView *loadingView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [loadingView setFrame:CGRectMake(140, 0, 40, 40)];
        [loadingView startAnimating];
        [cell.contentView addSubview:loadingView];
        
        [self fetchRestResult];
    }
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.total == 0 ? nil : indexPath;
}

- (Boolean)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.total > 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.total) {
        NSString *dest = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
        NSRange endRange = [dest rangeOfString:@"，"];
        if (endRange.length > 0) {
            dest = [dest substringToIndex:endRange.location];
        }
        [self.delegate updateDestination:dest];
        [self cancel:self];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.searchBar resignFirstResponder];
}

@end
