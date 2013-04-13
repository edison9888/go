//
//  SearchViewController.m
//  Chufaba
//
//  Created by 张辛欣 on 13-4-13.
//  Copyright (c) 2013年 ChufabaAPP团队. All rights reserved.
//

#import "SearchViewController.h"
#import "QuartzCore/QuartzCore.h"
#import "FMDBDataAccess.h" 
#import "iToast.h"

@interface SearchViewController ()

@property int total;
@property BOOL disappearing;

@end

@implementation SearchViewController

#define TAG_CATEGORYVIEW 1
#define TAG_SIGHTBTN 2
#define TAG_FOODBTN 3
#define TAG_HOTELBTN 4
#define TAG_OTHERBTN 5

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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

- (void)viewWillDisappear:(BOOL)animated
{
    self.disappearing = true;
    [super viewWillDisappear:animated];
    [self cancelCurrentSearch];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.category = @"景点";
    
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)] )
    {
        UIImage *image = [UIImage imageNamed:@"bar.png"];
        UINavigationBar *navBar = self.navigationController.navigationBar;
        [navBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
        
        navBar.layer.masksToBounds = NO;
        navBar.layer.shadowOffset = CGSizeMake(0, 1);
        navBar.layer.shadowRadius = 2;
        navBar.layer.shadowColor = [[UIColor colorWithRed:163/255.0 green:160/255.0 blue:155/255.0 alpha:1.0] CGColor];
        navBar.layer.shadowOpacity = 1;
    }
    
    UIButton *closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 7, 40, 30)];
    [closeBtn setImage:[UIImage imageNamed:@"cancel.png"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *cBtn = [[UIBarButtonItem alloc] initWithCustomView:closeBtn];
    self.navigationItem.leftBarButtonItem = cBtn;
    
    self.view.backgroundColor = [UIColor colorWithRed:244/255.0 green:241/255.0 blue:235/255.0 alpha:1.0];
    
    //category view part
    UIView *categoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    categoryView.tag = TAG_CATEGORYVIEW;
    categoryView.backgroundColor = [UIColor whiteColor];
    
    UIButton *sightBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 40)];
    sightBtn.tag = TAG_SIGHTBTN;
    [sightBtn setImage:[UIImage imageNamed:@"sight60.png"] forState:UIControlStateNormal];
    [sightBtn addTarget:self action:@selector(changeCategory:) forControlEvents:UIControlEventTouchUpInside];
    [categoryView addSubview:sightBtn];
    
    UIButton *foodBtn = [[UIButton alloc] initWithFrame:CGRectMake(80, 0, 80, 40)];
    foodBtn.tag = TAG_FOODBTN;
    [foodBtn setImage:[UIImage imageNamed:@"food60.png"] forState:UIControlStateNormal];
    [foodBtn addTarget:self action:@selector(changeCategory:) forControlEvents:UIControlEventTouchUpInside];
    [categoryView addSubview:foodBtn];
    
    UIButton *hotelBtn = [[UIButton alloc] initWithFrame:CGRectMake(160, 0, 80, 40)];
    hotelBtn.tag = TAG_HOTELBTN;
    [hotelBtn setImage:[UIImage imageNamed:@"hotel60.png"] forState:UIControlStateNormal];
    [hotelBtn addTarget:self action:@selector(changeCategory:) forControlEvents:UIControlEventTouchUpInside];
    [categoryView addSubview:hotelBtn];
    
    UIButton *otherBtn = [[UIButton alloc] initWithFrame:CGRectMake(240, 0, 80, 40)];
    otherBtn.tag = TAG_OTHERBTN;
    [otherBtn setImage:[UIImage imageNamed:@"more60.png"] forState:UIControlStateNormal];
    [otherBtn addTarget:self action:@selector(changeCategory:) forControlEvents:UIControlEventTouchUpInside];
    [categoryView addSubview:otherBtn];
    
    [self.view addSubview:categoryView];
    
    //search bar part
    self.nameInput = [[UITextField alloc] initWithFrame:CGRectMake(10, 46, 180, 40)];
    self.nameInput.placeholder = @"搜索旅行地点";
    self.nameInput.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.nameInput.borderStyle = UITextBorderStyleNone;
    self.nameInput.background = [UIImage imageNamed:@"kuang.png"];
    self.nameInput.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:16];
    UIView *nPaddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 40)];
    self.nameInput.leftView = nPaddingView;
    self.nameInput.leftViewMode = UITextFieldViewModeAlways;
    self.nameInput.delegate = self;
    [self.nameInput addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    self.locationInput = [[UITextField alloc] initWithFrame:CGRectMake(200, 46, 110, 40)];
    self.locationInput.placeholder = @"城市或国家";
    self.locationInput.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.locationInput.borderStyle = UITextBorderStyleNone;
    self.locationInput.background = [UIImage imageNamed:@"kuang.png"];
    self.locationInput.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:16];
    UIView *lPaddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 40)];
    self.locationInput.leftView = lPaddingView;
    self.locationInput.leftViewMode = UITextFieldViewModeAlways;
    self.locationInput.delegate = self;
    [self.locationInput addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    [self.view addSubview:self.nameInput];
    [self.view addSubview:self.locationInput];
    
    //tableview part
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 90, 320, self.view.bounds.size.height) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor colorWithRed:244/255.0 green:241/255.0 blue:235/255.0 alpha:1.0];
    [self.view addSubview:self.tableView];
}

-(IBAction)textFieldDidChange:(id)sender
{
    if (self.disappearing)
    {
        return;
    }
    
    if(sender == self.nameInput)
    {
        self.nameKeyword = [self.nameInput.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    else if(sender == self.locationInput)
    {
        self.locationKeyword = [self.locationInput.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    
    if([self.nameKeyword length] == 0 && [self.locationKeyword length] == 0)
    {
        [self clearResults];
    }
    else
    {
        [self searchPoi];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [allLocationList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 62.0f;
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
        
        UIButton *addBtn = [[UIButton alloc] initWithFrame:CGRectMake(275.0, 15.0, 31.0, 31.0)];
        [addBtn setImage:[UIImage imageNamed:@"addLocation.png"] forState:UIControlStateNormal];
        [addBtn addTarget:self action:@selector(addLocationToItinerary:) forControlEvents:UIControlEventTouchDown];
        addBtn.tag = indexPath.row+10;
        [cell.contentView addSubview:addBtn];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 61, self.view.bounds.size.width, 1)];
    lineView.backgroundColor = [UIColor colorWithRed:227/255.0 green:219/255.0 blue:204/255.0 alpha:1.0];
    [cell.contentView addSubview:lineView];
    
    UIView *wLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 1)];
    wLineView.backgroundColor = [UIColor whiteColor];
    [cell.contentView addSubview:wLineView];
    
    return cell;
}

- (IBAction)addLocationToItinerary:(id)sender
{
    [self.nameInput resignFirstResponder];
    [self.locationInput resignFirstResponder];
    
    UIButton *button = (UIButton*)sender;
    int index = button.tag-10;
    NSDictionary *locationAtIndex = [(NSDictionary *)[allLocationList objectAtIndex:index] objectForKey:@"_source"];
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
    
    FMDatabase *db = [FMDatabase databaseWithPath:[Utility getDatabasePath]];
    [db open];
    [db executeUpdate:@"INSERT INTO location (plan_id,whichday,seqofday,name,name_en,country,city,address,transportation,category,latitude,longitude,useradd,poi_id,opening,fee,website) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);",self.planId,self.dayToAdd,self.seqToAdd,[location getRealName],[location getRealNameEn],location.country,location.city,location.address,location.transportation,location.category,location.latitude,location.longitude,[NSNumber numberWithBool:location.useradd],location.poiId,location.opening,location.fee,location.website];
    FMResultSet *results = [db executeQuery:@"SELECT * FROM location order by id desc limit 1"];
    if([results next])
    {
        location.locationId = [NSNumber numberWithInt:[results intForColumn:@"id"]];
    }
    [db close];
    
    location.whichday = self.dayToAdd;
    location.seqofday = self.seqToAdd;
    
    //[[iToast makeText:NSLocalizedString(@"成功添加到计划", @"")] show];
    [[[[iToast makeText:NSLocalizedString(@"成功添加到计划", @"")] setGravity:iToastGravityCenter] setDuration:iToastDurationShort] show];
}

- (IBAction)changeCategory:(id)sender
{

}

-(IBAction)close:(id)sender
{
    [self.searchDelegate notifyItinerayToReload];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)fetchRestResult
{
    if([self.nameKeyword length] > 0 && [self.locationKeyword length] > 0)
    {
        int from = allLocationList.count;
        if (from >= self.total) {
            return;
        }
        [self cancelCurrentSearch];
        
        //需要修改成传name,location,category这三个参数
        NSString *body = [self getSameCategoryPostBody:self.nameKeyword];
        
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
    allLocationList = nil;
    [self.tableView reloadData];
}

- (void)searchPoi
{
    [self cancelCurrentSearch];
    
    //需要修改成传name,location,category这三个参数
    NSString *body = [self getSameCategoryPostBody:self.nameKeyword];
    
    fetcher = [[JSONFetcher alloc]
               initWithURLString:@"http://chufaba.me:9200/cfb/poi/_search?size=30&from=0"
               body:body
               receiver:self
               action:@selector(receiveResponse:)];
    fetcher.showAlerts = NO;
    [fetcher start];
}

- (NSString *)getSameCategoryPostBody:(NSString *)keyword {
    keyword = [keyword stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    keyword = [keyword stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
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

- (void)receiveResponse:(JSONFetcher *)aFetcher
{
    if (aFetcher.failureCode)
    {
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
        if (locations.count == 0 )
        {
            [self clearResults];
        }
        else
        {
            self.total = [[(NSDictionary *)[(NSDictionary *)aFetcher.result objectForKey:@"hits"] objectForKey:@"total"] intValue];
            allLocationList = [locations mutableCopy];
            [self.tableView reloadData];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.nameInput resignFirstResponder];
    [self.locationInput resignFirstResponder];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self clearResults];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
