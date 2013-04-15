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
#import "CfbTextField.h"
#import "SearchTableViewCell.h"

@interface SearchViewController ()

@property int total;
@property BOOL disappearing;

@end

@implementation SearchViewController

#define TAG_TOPVIEW 1
#define TAG_SIGHTBTN 2
#define TAG_FOODBTN 3
#define TAG_HOTELBTN 4
#define TAG_OTHERBTN 5

#define LABEL_WIDTH 190
#define NAME_LABEL_HEIGHT 24
#define ENAME_LABEL_HEIGHT 12
#define LOCATION_LABEL_HEIGHT 12

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
    
    //top view part
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 85)];
    topView.tag = TAG_TOPVIEW;
    topView.backgroundColor = [UIColor whiteColor];
    
    CAGradientLayer *viewShadow = [[CAGradientLayer alloc] init];
    CGRect viewShadowFrame = CGRectMake(0, 0, 320, topView.frame.size.height);
    viewShadow.frame = viewShadowFrame;
    viewShadow.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithRed:230/255.0 green:223/255.0 blue:209/255.0 alpha:1.0].CGColor,(id)[UIColor colorWithRed:227/255.0 green:219/255.0 blue:204/255.0 alpha:1.0].CGColor,nil];
    [topView.layer addSublayer:viewShadow];
    
    topView.layer.masksToBounds = NO;
    topView.layer.shadowOffset = CGSizeMake(0, 1);
    topView.layer.shadowRadius = 1;
    topView.layer.shadowColor = [[UIColor colorWithRed:189/255.0 green:176/255.0 blue:153/255.0 alpha:1.0] CGColor];
    topView.layer.shadowOpacity = 1;
    
    UIButton *sightBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 75, 25)];
    sightBtn.tag = TAG_SIGHTBTN;
    [sightBtn setImage:[UIImage imageNamed:@"tab_sight.png"] forState:UIControlStateNormal];
    [sightBtn setImage:[UIImage imageNamed:@"tab_sight_click.png"] forState:UIControlStateHighlighted];
    [sightBtn setImage:[UIImage imageNamed:@"tab_sight_click.png"] forState:UIControlStateSelected];
    [sightBtn addTarget:self action:@selector(changeCategory:) forControlEvents:UIControlEventTouchUpInside];
    sightBtn.selected = YES;
    [topView addSubview:sightBtn];
    
    UIButton *foodBtn = [[UIButton alloc] initWithFrame:CGRectMake(85, 10, 75, 25)];
    foodBtn.tag = TAG_FOODBTN;
    [foodBtn setImage:[UIImage imageNamed:@"tab_food.png"] forState:UIControlStateNormal];
    [foodBtn setImage:[UIImage imageNamed:@"tab_food_click.png"] forState:UIControlStateHighlighted];
    [foodBtn setImage:[UIImage imageNamed:@"tab_food_click.png"] forState:UIControlStateSelected];
    [foodBtn addTarget:self action:@selector(changeCategory:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:foodBtn];
    
    UIButton *hotelBtn = [[UIButton alloc] initWithFrame:CGRectMake(160, 10, 75, 25)];
    hotelBtn.tag = TAG_HOTELBTN;
    [hotelBtn setImage:[UIImage imageNamed:@"tab_hotel.png"] forState:UIControlStateNormal];
    [hotelBtn setImage:[UIImage imageNamed:@"tab_hotel_click.png"] forState:UIControlStateHighlighted];
    [hotelBtn setImage:[UIImage imageNamed:@"tab_hotel_click.png"] forState:UIControlStateSelected];
    [hotelBtn addTarget:self action:@selector(changeCategory:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:hotelBtn];
    
    UIButton *otherBtn = [[UIButton alloc] initWithFrame:CGRectMake(235, 10, 75, 25)];
    otherBtn.tag = TAG_OTHERBTN;
    [otherBtn setImage:[UIImage imageNamed:@"tab_more.png"] forState:UIControlStateNormal];
    [otherBtn setImage:[UIImage imageNamed:@"tab_more_click.png"] forState:UIControlStateHighlighted];
    [otherBtn setImage:[UIImage imageNamed:@"tab_more_click.png"] forState:UIControlStateSelected];
    [otherBtn addTarget:self action:@selector(changeCategory:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:otherBtn];
    
    //search bar part
    self.nameInput = [[CfbTextField alloc] initWithFrame:CGRectMake(10, 45, 180, 30)];
    //self.nameInput.textColor = [UIColor colorWithRed:227/255.0 green:219/255.0 blue:204/255.0 alpha:1.0];
    self.nameInput.textColor = [UIColor colorWithRed:72/255.0 green:70/255.0 blue:66/255.0 alpha:1.0];
    self.nameInput.placeholder = @"搜索景点";
    self.nameInput.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.nameInput.borderStyle = UITextBorderStyleNone;
    //self.nameInput.background = [UIImage imageNamed:@"kuang.png"];
    self.nameInput.background = [[UIImage imageNamed:@"skuang.png"] stretchableImageWithLeftCapWidth:3 topCapHeight:0];
    self.nameInput.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:16];
    UIView *nPaddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 26, 30)];
    UIImageView *nImgView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 7, 16, 16)];
    nImgView.image = [UIImage imageNamed:@"Search.png"];
    [nPaddingView addSubview:nImgView];
    self.nameInput.leftView = nPaddingView;
    self.nameInput.leftViewMode = UITextFieldViewModeAlways;
    self.nameInput.delegate = self;
    [self.nameInput addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    self.nameInput.clearButtonMode = TRUE;
    
    self.locationInput = [[CfbTextField alloc] initWithFrame:CGRectMake(200, 45, 110, 30)];
    self.locationInput.textColor = [UIColor colorWithRed:72/255.0 green:70/255.0 blue:66/255.0 alpha:1.0];
    self.locationInput.placeholder = @"城市,省,国家";
    self.locationInput.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.locationInput.borderStyle = UITextBorderStyleNone;
    //self.locationInput.background = [UIImage imageNamed:@"kuang.png"];
    self.locationInput.background = [[UIImage imageNamed:@"skuang.png"] stretchableImageWithLeftCapWidth:3 topCapHeight:0];
    self.locationInput.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:16];
    UIView *lPaddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 22, 30)];
    UIImageView *lImgView = [[UIImageView alloc] initWithFrame:CGRectMake(3, 7, 16, 16)];
    lImgView.image = [UIImage imageNamed:@"pin.png"];
    [lPaddingView addSubview:lImgView];
    self.locationInput.leftView = lPaddingView;
    self.locationInput.leftViewMode = UITextFieldViewModeAlways;
    self.locationInput.delegate = self;
    [self.locationInput addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    self.locationInput.clearButtonMode = TRUE;
    
    [topView addSubview:self.nameInput];
    [topView addSubview:self.locationInput];
    
    [self.view addSubview:topView];
    
    //tableview part
    NSLog(@"height:%f", self.view.bounds.size.height);
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 86, 320, 330) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor colorWithRed:244/255.0 green:241/255.0 blue:235/255.0 alpha:1.0];
    [self.view addSubview:self.tableView];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if(textField == self.nameInput)
    {
        if(self.nameInput.frame.size.width != 180)
        {
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.3];
            [self.nameInput setFrame:CGRectMake(10, 45, 180, 30)];
            [self.locationInput setFrame:CGRectMake(200, 45, 110, 30)];
            [UIView commitAnimations];
        }
    }
    else
    {
        if(self.locationInput.frame.size.width == 110)
        {
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.3];
            [self.locationInput setFrame:CGRectMake(130, 45, 180, 30)];
            [self.nameInput setFrame:CGRectMake(10, 45, 110, 30)];
            [UIView commitAnimations];
        }
    }
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
    if (self.locationKeyword.length == 0) {
        return 0;
    } else {
        return [allLocationList count] + 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 62.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[[cell textLabel] setText: [NSString stringWithFormat: @"%@, %@", name, city]];
    SearchTableViewCell *cell;
    if (indexPath.row < [allLocationList count])
    {
        NSString *CellIdentifier = @"SearchLocationCell";
        
        cell = (SearchTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil){
            cell = [[SearchTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        NSDictionary *locationAtIndex = [(NSDictionary *)[allLocationList objectAtIndex:indexPath.row] objectForKey:@"_source"];
        NSString *name = [locationAtIndex objectForKey: @"name"];
        NSString *name_en = [locationAtIndex objectForKey: @"name_en"];
        NSString *city = [locationAtIndex objectForKey: @"city"];
        NSString *country = [locationAtIndex objectForKey: @"country"];
        
        NSNumber *poiId = [locationAtIndex objectForKey: @"id"];
        
        if ([name length] == 0) {
            name = name_en;
            name_en = nil;
        }
        
        UIImageView *categoryImage = (UIImageView *)[cell.contentView viewWithTag:1];
        categoryImage.image = [Location getCategoryIconMedium:[locationAtIndex objectForKey:@"category"]];
        
        UILabel *nameLabel = (UILabel *)[cell.contentView viewWithTag:2];
        nameLabel.text = name;
        
        UILabel *eNameLabel = (UILabel *)[cell.contentView viewWithTag:3];
        if(name_en.length != 0)
            eNameLabel.text = name_en;
        
        UILabel *locationLabel = (UILabel *)[cell.contentView viewWithTag:4];
        if(city.length != 0 && country.length != 0)
        {
            locationLabel.text = [NSString stringWithFormat: @"%@, %@", city, country];
        }
        else if(city.length != 0)
        {
            locationLabel.text = city;
        }
        else if(country.length != 0)
        {
            locationLabel.text = country;
        }
        
        CGPoint nameLabelOrigin = CGPointMake(60, 7);
        CGPoint eNameLabelOrigin = CGPointMake(60, 27);
        CGPoint locationLabelOrigin = CGPointMake(60, 42);
        
        if (name_en.length == 0 && city.length == 0) {
            nameLabelOrigin = CGPointMake(60, 19);
        } else if (name_en.length == 0) {
            nameLabelOrigin = CGPointMake(60, 12);
            locationLabelOrigin = CGPointMake(60, 35);
        } else if (city.length == 0) {
            nameLabelOrigin = CGPointMake(60, 12);
            eNameLabelOrigin = CGPointMake(60, 35);
        }
        
        nameLabel.frame = CGRectMake(nameLabelOrigin.x, nameLabelOrigin.y, LABEL_WIDTH, NAME_LABEL_HEIGHT);
        eNameLabel.frame = CGRectMake(eNameLabelOrigin.x, eNameLabelOrigin.y, LABEL_WIDTH, ENAME_LABEL_HEIGHT);
        locationLabel.frame = CGRectMake(locationLabelOrigin.x, locationLabelOrigin.y, LABEL_WIDTH, LOCATION_LABEL_HEIGHT);
        
        BOOL addedBefore = FALSE;
        for(NSNumber *poi in self.poiArray)
        {
            if([poi intValue] == [poiId intValue])
            {
                addedBefore = TRUE;
                break;
            }
        }
        
        if(addedBefore)
        {
            UIButton *removeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [removeBtn setFrame:CGRectMake(260.0, 16.0, 50.0, 30.0)];
            [removeBtn setBackgroundImage:[UIImage imageNamed:@"remove_list.png"] forState:UIControlStateNormal];
            [removeBtn setBackgroundImage:[UIImage imageNamed:@"remove_list_click.png"] forState:UIControlStateHighlighted];
            [removeBtn addTarget:self action:@selector(removeLocation:) forControlEvents:UIControlEventTouchDown];
            removeBtn.tag = indexPath.row+10;
            [cell.contentView addSubview:removeBtn];
        }
        else
        {
            UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [addBtn setFrame:CGRectMake(260.0, 16.0, 50.0, 30.0)];
            [addBtn setBackgroundImage:[UIImage imageNamed:@"add_list.png"] forState:UIControlStateNormal];
            [addBtn setBackgroundImage:[UIImage imageNamed:@"add_list_click.png"] forState:UIControlStateHighlighted];
            [addBtn addTarget:self action:@selector(addLocation:) forControlEvents:UIControlEventTouchDown];
            addBtn.tag = indexPath.row+10;
            [cell.contentView addSubview:addBtn];
        }
        
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
    
    if(indexPath.row !=0)
    {
        lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 1)];
        lineView.backgroundColor = [UIColor whiteColor];
        [cell.contentView addSubview:lineView];
    }
    
    return cell;
}

//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    UITableViewCell *cell;
//    if (indexPath.row < [allLocationList count])
//    {
//        NSString *CellIdentifier = @"SearchLocationCell";
//        
//        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//        
//        if (cell == nil){
//            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
//        }
//        NSDictionary *locationAtIndex = [(NSDictionary *)[allLocationList objectAtIndex:indexPath.row] objectForKey:@"_source"];
//        NSString *name = [locationAtIndex objectForKey: @"name"];
//        NSString *name_en = [locationAtIndex objectForKey: @"name_en"];
//        NSString *city = [locationAtIndex objectForKey: @"city"];
//        NSNumber *poiId = [locationAtIndex objectForKey: @"id"];
//        if ([name length] == 0) {
//            name = name_en;
//            name_en = nil;
//        }
//        if ([city length] > 0) {
//            //[[cell textLabel] setText: [NSString stringWithFormat: @"%@, %@", name, city]];
//            [[cell textLabel] setText: [NSString stringWithFormat: @"%@", name]];
//        } else {
//            [[cell textLabel] setText: name];
//        }
//        cell.textLabel.textColor = [UIColor colorWithRed:72/255.0 green:70/255.0 blue:66/255.0 alpha:1.0];
//        cell.textLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:16];
//        
//        [[cell detailTextLabel] setText: name_en];
//        cell.detailTextLabel.textColor = [UIColor colorWithRed:153/255.0 green:150/255.0 blue:145/255.0 alpha:1.0];
//        cell.detailTextLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:12];
//        
//        cell.imageView.image = [Location getCategoryIconMedium:[locationAtIndex objectForKey:@"category"]];
//        
//        BOOL addedBefore = FALSE;
//        for(NSNumber *poi in self.poiArray)
//        {
//            if([poi intValue] == [poiId intValue])
//            {
//                addedBefore = TRUE;
//                break;
//            }
//        }
//        
//        if(addedBefore)
//        {
//            UIButton *removeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//            [removeBtn setFrame:CGRectMake(260.0, 16.0, 50.0, 30.0)];
//            [removeBtn setBackgroundImage:[UIImage imageNamed:@"remove_list.png"] forState:UIControlStateNormal];
//            [removeBtn setBackgroundImage:[UIImage imageNamed:@"remove_list_click.png"] forState:UIControlStateHighlighted];
//            [removeBtn addTarget:self action:@selector(removeLocation:) forControlEvents:UIControlEventTouchDown];
//            removeBtn.tag = indexPath.row+10;
//            [cell.contentView addSubview:removeBtn];
//        }
//        else
//        {
//            UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//            [addBtn setFrame:CGRectMake(260.0, 16.0, 50.0, 30.0)];
//            [addBtn setBackgroundImage:[UIImage imageNamed:@"add_list.png"] forState:UIControlStateNormal];
//            [addBtn setBackgroundImage:[UIImage imageNamed:@"add_list_click.png"] forState:UIControlStateHighlighted];
//            [addBtn addTarget:self action:@selector(addLocation:) forControlEvents:UIControlEventTouchDown];
//            addBtn.tag = indexPath.row+10;
//            [cell.contentView addSubview:addBtn];
//        }
//        
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    }
//    else if ([allLocationList count] != self.total)
//    {
//        NSString *CellIdentifier = @"LoadingCell";
//        
//        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//        
//        if (cell == nil){
//            cell = [[SearchTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//            cell.imageView.image = [UIImage imageNamed:@"loading.gif"];
//        }
//        [self fetchRestResult];
//    }
//    else
//    {
//        UITableViewCell *addLocationCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"addLocation"];
//        [addLocationCell addSubview:addLocationBtn];
//        
//        [addLocationCell bringSubviewToFront:addLocationBtn];
//        
//        return addLocationCell;
//    }
//    
//    //add separator line
//    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 61, self.view.bounds.size.width, 1)];
//    lineView.backgroundColor = [UIColor colorWithRed:227/255.0 green:219/255.0 blue:204/255.0 alpha:1.0];
//    [cell.contentView addSubview:lineView];
//    
//    if(indexPath.row !=0)
//    {
//        lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 1)];
//        lineView.backgroundColor = [UIColor whiteColor];
//        [cell.contentView addSubview:lineView];
//    }
//    
//    return cell;
//}

- (IBAction)removeLocation:(id)sender
{
    shouldUpdateItinerary = YES;
    
    [self.nameInput resignFirstResponder];
    [self.locationInput resignFirstResponder];
    
    UIButton *button = (UIButton*)sender;
    int index = button.tag-10;
    NSDictionary *locationAtIndex = [(NSDictionary *)[allLocationList objectAtIndex:index] objectForKey:@"_source"];
    NSNumber *poiId = [locationAtIndex objectForKey: @"id"];
    
    NSNumber *seqToDelete;
    FMDatabase *db = [FMDatabase databaseWithPath:[Utility getDatabasePath]];
    [db open];
    
    FMResultSet *results = [db executeQuery:@"SELECT * FROM location WHERE poi_id = ? AND whichday = ?", poiId, self.dayToAdd];
    if([results next])
    {
        seqToDelete = [NSNumber numberWithInt:[results intForColumn:@"seqofday"]];
    }

    [db executeUpdate:@"DELETE FROM location WHERE poi_id = ? AND whichday = ?", poiId, self.dayToAdd];
    [db executeUpdate:@"UPDATE location SET seqofday = seqofday-1 where seqofday > ? and whichday = ?",seqToDelete,self.dayToAdd];
    [db close];
    
    //update poi array
    for(NSNumber *poi in self.poiArray)
    {
        if([poi intValue] == [poiId intValue])
        {
            [self.poiArray removeObject:poi];
            break;
        }
    }
    
    self.seqToAdd = [NSNumber numberWithInt:[self.seqToAdd intValue]-1];
    
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [addBtn setFrame:CGRectMake(260.0, 16.0, 50.0, 30.0)];
    
    addBtn.tag = button.tag;
    UIView *cellContentView = button.superview;
    [button removeFromSuperview];
    
    [addBtn setBackgroundImage:[UIImage imageNamed:@"add_list.png"] forState:UIControlStateNormal];
    [addBtn setBackgroundImage:[UIImage imageNamed:@"add_list_click.png"] forState:UIControlStateHighlighted];
    [addBtn addTarget:self action:@selector(addLocation:) forControlEvents:UIControlEventTouchDown];
    [cellContentView addSubview:addBtn];
    
    iToastSettings *theSettings = [iToastSettings getSharedSettings];
    [theSettings setImage:[UIImage imageNamed:@"prompt_no.png"] forType:iToastTypeNotice];
    theSettings.duration = 8000;
    [[[[iToast makeText:NSLocalizedString(@"已从计划中移除", @"")] setGravity:iToastGravityCenter] setDuration:iToastDurationShort] show:iToastTypeNotice];
}

- (IBAction)addLocation:(id)sender
{
    shouldUpdateItinerary = YES;
    
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
    
    location.whichday = self.dayToAdd;
    location.seqofday = self.seqToAdd;
    
    [self.poiArray addObject:location.poiId];
    
    FMDatabase *db = [FMDatabase databaseWithPath:[Utility getDatabasePath]];
    [db open];
    [db executeUpdate:@"INSERT INTO location (plan_id,whichday,seqofday,name,name_en,country,city,address,transportation,category,latitude,longitude,useradd,poi_id,opening,fee,website) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);",self.planId,self.dayToAdd,self.seqToAdd,[location getRealName],[location getRealNameEn],location.country,location.city,location.address,location.transportation,location.category,location.latitude,location.longitude,[NSNumber numberWithBool:location.useradd],location.poiId,location.opening,location.fee,location.website];
    [db close];
    
    //increase seqToAdd
    self.seqToAdd = [NSNumber numberWithInt:[self.seqToAdd intValue]+1];
    
    UIButton *removeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [removeBtn setFrame:CGRectMake(260.0, 16.0, 50.0, 30.0)];
    
    removeBtn.tag = button.tag;
    UIView *cellContentView = button.superview;
    [button removeFromSuperview];
    
    [removeBtn setBackgroundImage:[UIImage imageNamed:@"remove_list.png"] forState:UIControlStateNormal];
    [removeBtn setBackgroundImage:[UIImage imageNamed:@"remove_list_click.png"] forState:UIControlStateHighlighted];
    [removeBtn addTarget:self action:@selector(removeLocation:) forControlEvents:UIControlEventTouchDown];
    [cellContentView addSubview:removeBtn];
    
    iToastSettings *theSettings = [iToastSettings getSharedSettings];
    [theSettings setImage:[UIImage imageNamed:@"prompt_yes.png"] forType:iToastTypeNotice];
    theSettings.duration = 8000;
    [[[[iToast makeText:NSLocalizedString(@"已添加到计划", @"")] setGravity:iToastGravityCenter] setDuration:iToastDurationShort] show:iToastTypeNotice];
}

- (IBAction)changeCategory:(id)sender
{
    [self.nameInput resignFirstResponder];
    [self.locationInput resignFirstResponder];
    
    ((UIButton *)[[self.view viewWithTag:TAG_TOPVIEW] viewWithTag:TAG_SIGHTBTN]).selected = NO;
    ((UIButton *)[[self.view viewWithTag:TAG_TOPVIEW] viewWithTag:TAG_FOODBTN]).selected = NO;
    ((UIButton *)[[self.view viewWithTag:TAG_TOPVIEW] viewWithTag:TAG_HOTELBTN]).selected = NO;
    ((UIButton *)[[self.view viewWithTag:TAG_TOPVIEW] viewWithTag:TAG_OTHERBTN]).selected = NO;
    
    UIButton *button = (UIButton*)sender;
    button.selected = YES;
    
    switch (button.tag)
    {
        case TAG_SIGHTBTN:
            self.category = @"景点";
            break;
        case TAG_FOODBTN:
            self.category = @"美食";
            break;
        case TAG_HOTELBTN:
            self.category = @"住宿";
            break;
        case TAG_OTHERBTN:
            self.category = @"其它";
            break;
            
        default:
            break;
    }
    
    [self searchPoi];
}

-(IBAction)close:(id)sender
{
    if(shouldUpdateItinerary)
    {
        [self.searchDelegate notifyItinerayToReload];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
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
    if([self.locationKeyword length] > 0)
    {
        [self cancelCurrentSearch];
        
        NSString *body = [self getSearchPostBody];
        if (body != nil) {
            fetcher = [[JSONFetcher alloc]
                       initWithURLString:@"http://chufaba.me:9200/cfb/poi/_search?size=30&from=0"
                       body:body
                       receiver:self
                       action:@selector(receiveResponse:)];
            fetcher.showAlerts = NO;
            [fetcher start];
        }
    }
}

- (NSString *)getSearchPostBody {
    NSString *keyword = [self.nameKeyword stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    keyword = [keyword stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *location = [self.locationKeyword stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    location = [location stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    location = [location capitalizedString];
    if (location.length == 0) {
        //没有地名就不搜
        return nil;
    }
    NSString *sort = nil;
    if (self.lastLatitude && [self.lastLatitude intValue] != 10000) {
        sort = [NSString stringWithFormat:@"\"sort\" : ["
                "{ \"_geo_distance\" : {"
                "   \"location\" : { \"lat\" : %f, \"lon\" : %f }, "
                "   \"order\" : \"asc\", "
                "   \"unit\" : \"km\" "
                "}},"
                "{\"rank\":\"desc\"},"
                "\"id\""
                "]", [self.lastLatitude floatValue], [self.lastLongitude floatValue]];
    } else {
        sort = @"\"sort\":["
                "{\"rank\":\"desc\"},"
                "\"id\""
                "]";
    }
    NSString *locationQuery = [NSString stringWithFormat:@
                               "            \"should\" : ["
                               "                {"
                               "                    \"prefix\" : {"
                               "                        \"city\": \"%@\" "
                               "                    } "
                               "                },"
                               "                {"
                               "                    \"prefix\" : {"
                               "                        \"city_en\": \"%@\" "
                               "                    } "
                               "                },"
                               "                {"
                               "                    \"prefix\" : {"
                               "                        \"country\": {"
                               "                            \"prefix\": \"%@\","
                               "                            \"boost\": 2.0"
                               "                        }"
                               "                    }"
                               "                },"
                               "                {"
                               "                    \"prefix\" : {"
                               "                        \"country_en\": {"
                               "                            \"prefix\": \"%@\","
                               "                            \"boost\": 2.0"
                               "                        }"
                               "                    }"
                               "                }"
                               "            ],"
                               "            \"minimum_number_should_match\" : 1"
                               , location, location, location, location];
    NSString *keywordQuery = @"";
    if (keyword.length > 0) {
        keywordQuery = [NSString stringWithFormat:@
                               "            \"must\" : {"
                               "                \"match_phrase_prefix\" :{"
                               "                    \"query\" : {"
                               "                        \"query\" : \"%@\""
                               "                    }"
                               "                }"
                               "            },"
                               , keyword];
    }
    NSString *query = [NSString stringWithFormat:@
                           "    \"query\":{ "
                           "        \"bool\" : { "
                           "            \"must\" : {"
                           "                \"term\" : {"
                           "                    \"category\": \"%@\" "
                           "                } "
                           "            }, "
                           "            %@"
                           "            %@"
                           "}}", self.category, keywordQuery, locationQuery];
    
    return [NSString stringWithFormat:@"{%@,%@}", sort, query];
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

- (void)fetchRestResult
{
    if([self.locationKeyword length] > 0)
    {
        int from = allLocationList.count;
        if (from >= self.total) {
            return;
        }
        
        [self cancelCurrentSearch];
        
        NSString *body = [self getSearchPostBody];
        if (body != nil) {
            fetcher = [[JSONFetcher alloc]
                       initWithURLString:[NSString stringWithFormat:@"http://chufaba.me:9200/cfb/poi/_search?size=30&from=%d", from]
                       body:body
                       receiver:self
                       action:@selector(receiveRestResult:)];
            fetcher.showAlerts = NO;
            [fetcher start];
        }
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