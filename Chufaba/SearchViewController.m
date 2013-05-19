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
#import "CfbSearchBar.h"
#import "SearchTableViewCell.h"


@interface SearchViewController ()
{
    NSTimer *timer;
}

@property int total;
@property BOOL disappearing;
@property UIActivityIndicatorView *loadingView;

@end

@implementation SearchViewController

#define SEARCH_TIMEOUT 10

#define TAG_TOPVIEW 10000
#define TAG_SIGHTBTN 2
#define TAG_FOODBTN 3
#define TAG_HOTELBTN 4
#define TAG_OTHERBTN 5
#define TAG_IMPLYLABEL 6

#define LABEL_WIDTH 190
#define NAME_LABEL_HEIGHT 24
#define ENAME_LABEL_HEIGHT 12
#define LOCATION_LABEL_HEIGHT 12
#define TOP_VIEW_HEIGHT 85

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
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
    self.categoryImage = [NSDictionary dictionaryWithObjectsAndKeys:@"sight80", @"景点", @"food80", @"美食", @"hotel80", @"住宿", @"more80", @"其它", nil];
    self.category = @"景点";
    
    UINavigationBar *navBar = self.navigationController.navigationBar;
    navBar.layer.shadowPath = [UIBezierPath bezierPathWithRect:navBar.bounds].CGPath;
    navBar.layer.masksToBounds = NO;
    navBar.layer.shadowOffset = CGSizeMake(0, 1);
    navBar.layer.shadowRadius = 2;
    navBar.layer.shadowColor = [[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.3] CGColor];
    navBar.layer.shadowOpacity = 1;
    navBar.layer.shouldRasterize = YES;
    navBar.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.navigationItem.title = @"添加旅行地点";
    
    UIButton *closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 7, 40, 30)];
    [closeBtn setImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [closeBtn setImage:[UIImage imageNamed:@"cancel_click"] forState:UIControlStateHighlighted];
    [closeBtn addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *cBtn = [[UIBarButtonItem alloc] initWithCustomView:closeBtn];
    self.navigationItem.leftBarButtonItem = cBtn;
    
    self.view.backgroundColor = [UIColor colorWithRed:244/255.0 green:241/255.0 blue:235/255.0 alpha:1.0];
    
    //top view part
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 85)];
    topView.tag = TAG_TOPVIEW;
    topView.opaque = YES;
    
    CAGradientLayer *viewShadow = [[CAGradientLayer alloc] init];
    CGRect viewShadowFrame = CGRectMake(0, 0, 320, topView.frame.size.height);
    viewShadow.frame = viewShadowFrame;
    viewShadow.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithRed:230/255.0 green:223/255.0 blue:209/255.0 alpha:1.0].CGColor,(id)[UIColor colorWithRed:227/255.0 green:219/255.0 blue:204/255.0 alpha:1.0].CGColor,nil];
    [topView.layer addSublayer:viewShadow];
    
    topView.layer.shadowPath = [UIBezierPath bezierPathWithRect:topView.bounds].CGPath;
    topView.layer.masksToBounds = NO;
    topView.layer.shadowOffset = CGSizeMake(0, 1);
    topView.layer.shadowRadius = 1;
    topView.layer.shadowColor = [[UIColor colorWithRed:189/255.0 green:176/255.0 blue:153/255.0 alpha:1.0] CGColor];
    topView.layer.shadowOpacity = 1;
    topView.layer.opaque = YES;
    topView.layer.shouldRasterize = YES;
    topView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    UIButton *sightBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 75, 25)];
    sightBtn.tag = TAG_SIGHTBTN;
    [sightBtn setImage:[UIImage imageNamed:@"tab_sight"] forState:UIControlStateNormal];
    [sightBtn setImage:[UIImage imageNamed:@"tab_sight_click"] forState:UIControlStateHighlighted];
    [sightBtn setImage:[UIImage imageNamed:@"tab_sight_click"] forState:UIControlStateSelected];
    [sightBtn addTarget:self action:@selector(changeCategory:) forControlEvents:UIControlEventTouchUpInside];
    sightBtn.selected = YES;
    [topView addSubview:sightBtn];
    
    UIButton *foodBtn = [[UIButton alloc] initWithFrame:CGRectMake(85, 10, 75, 25)];
    foodBtn.tag = TAG_FOODBTN;
    [foodBtn setImage:[UIImage imageNamed:@"tab_food"] forState:UIControlStateNormal];
    [foodBtn setImage:[UIImage imageNamed:@"tab_food_click"] forState:UIControlStateHighlighted];
    [foodBtn setImage:[UIImage imageNamed:@"tab_food_click"] forState:UIControlStateSelected];
    [foodBtn addTarget:self action:@selector(changeCategory:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:foodBtn];
    
    UIButton *hotelBtn = [[UIButton alloc] initWithFrame:CGRectMake(160, 10, 75, 25)];
    hotelBtn.tag = TAG_HOTELBTN;
    [hotelBtn setImage:[UIImage imageNamed:@"tab_hotel"] forState:UIControlStateNormal];
    [hotelBtn setImage:[UIImage imageNamed:@"tab_hotel_click"] forState:UIControlStateHighlighted];
    [hotelBtn setImage:[UIImage imageNamed:@"tab_hotel_click"] forState:UIControlStateSelected];
    [hotelBtn addTarget:self action:@selector(changeCategory:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:hotelBtn];
    
    UIButton *otherBtn = [[UIButton alloc] initWithFrame:CGRectMake(235, 10, 75, 25)];
    otherBtn.tag = TAG_OTHERBTN;
    [otherBtn setImage:[UIImage imageNamed:@"tab_more"] forState:UIControlStateNormal];
    [otherBtn setImage:[UIImage imageNamed:@"tab_more_click"] forState:UIControlStateHighlighted];
    [otherBtn setImage:[UIImage imageNamed:@"tab_more_click"] forState:UIControlStateSelected];
    [otherBtn addTarget:self action:@selector(changeCategory:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:otherBtn];
    
    self.nameInput = [[UISearchBar alloc] initWithFrame:CGRectMake(5, 45, 195, 30)];
    self.nameInput.placeholder = @"搜索景点";
    self.nameInput.delegate = self;
    self.locationInput = [[UISearchBar alloc] initWithFrame:CGRectMake(200, 45, 115, 30)];
    self.locationInput.placeholder = @"市,省,国家";
    self.locationInput.delegate = self;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:@"preferDestination"])
    {
        self.locationInput.text = [userDefaults objectForKey:@"preferDestination"];
    }
    else
    {
        self.locationInput.text = self.locationKeyword;
    }

    for(id cc in [self.nameInput subviews])
    {
        if([cc isKindOfClass:[UITextField class]])
        {
            UITextField *searchField = (UITextField *)cc;
            UIImageView *view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Search"]];
            searchField.leftView = view;
            searchField.textColor = [UIColor colorWithRed:72/255.0 green:70/255.0 blue:66/255.0 alpha:1.0];
            searchField.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:14];
            searchField.clearButtonMode = UITextFieldViewModeWhileEditing;
        }
        if ([cc isKindOfClass:NSClassFromString(@"UISearchBarBackground")])
        {
            [cc removeFromSuperview];
        }
    }
    for(id cc in [self.locationInput subviews])
    {
        if([cc isKindOfClass:[UITextField class]])
        {
            UITextField *searchField = (UITextField *)cc;
            UIImageView *view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pin"]];
            searchField.leftView = view;
            searchField.textColor = [UIColor colorWithRed:72/255.0 green:70/255.0 blue:66/255.0 alpha:1.0];
            searchField.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:14];
            searchField.clearButtonMode = UITextFieldViewModeWhileEditing;
        }
        if ([cc isKindOfClass:NSClassFromString(@"UISearchBarBackground")])
        {
            [cc removeFromSuperview];
        }
    }
    
//    self.nameInput = [[CfbSearchBar alloc] initWithFrame:CGRectMake(10, 45, 180, 30)];
//    self.nameInput.placeholder = @"搜索景点";
//    self.nameInput.delegate = self;
//    self.locationInput = [[CfbSearchBar alloc] initWithFrame:CGRectMake(200, 45, 110, 30)];
//    self.locationInput.placeholder = @"市,省,国家";
//    self.locationInput.delegate = self;
//    self.locationInput.text = self.locationKeyword;
//    for(id cc in [self.nameInput subviews])
//    {
//        if([cc isKindOfClass:[UITextField class]])
//        {
//            UITextField *textField = (UITextField *)cc;
//            UIImageView *view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Search"]];
//            textField.leftView = view;
//        }
//    }
//    for(id cc in [self.locationInput subviews])
//    {
//        if([cc isKindOfClass:[UITextField class]])
//        {
//            UITextField *textField = (UITextField *)cc;
//            UIImageView *view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pin"]];
//            textField.leftView = view;
//        }
//    }
//    self.nameInput = [[CfbTextField alloc] initWithFrame:CGRectMake(10, 45, 180, 30)];
//    self.nameInput.textColor = [UIColor colorWithRed:72/255.0 green:70/255.0 blue:66/255.0 alpha:1.0];
//    self.nameInput.placeholder = @"搜索景点";
//    self.nameInput.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
//    self.nameInput.borderStyle = UITextBorderStyleNone;
//    self.nameInput.background = [[UIImage imageNamed:@"skuang.png"] stretchableImageWithLeftCapWidth:3 topCapHeight:0];
//    self.nameInput.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:16];
//    UIView *nPaddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 26, 30)];
//    UIImageView *nImgView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 7, 16, 16)];
//    nImgView.image = [UIImage imageNamed:@"Search.png"];
//    [nPaddingView addSubview:nImgView];
//    self.nameInput.leftView = nPaddingView;
//    self.nameInput.leftViewMode = UITextFieldViewModeAlways;
//    self.nameInput.delegate = self;
//    [self.nameInput addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
//    self.nameInput.clearButtonMode = TRUE;
//    
//    self.locationInput = [[CfbTextField alloc] initWithFrame:CGRectMake(200, 45, 110, 30)];
//    self.locationInput.text = self.locationKeyword;
//    self.locationInput.textColor = [UIColor colorWithRed:72/255.0 green:70/255.0 blue:66/255.0 alpha:1.0];
//    self.locationInput.placeholder = @"城市,省,国家";
//    self.locationInput.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
//    self.locationInput.borderStyle = UITextBorderStyleNone;
//    self.locationInput.background = [[UIImage imageNamed:@"skuang.png"] stretchableImageWithLeftCapWidth:3 topCapHeight:0];
//    self.locationInput.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:16];
//    UIView *lPaddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 22, 30)];
//    UIImageView *lImgView = [[UIImageView alloc] initWithFrame:CGRectMake(3, 7, 16, 16)];
//    lImgView.image = [UIImage imageNamed:@"pin.png"];
//    [lPaddingView addSubview:lImgView];
//    self.locationInput.leftView = lPaddingView;
//    self.locationInput.leftViewMode = UITextFieldViewModeAlways;
//    self.locationInput.delegate = self;
//    [self.locationInput addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
//    self.locationInput.clearButtonMode = TRUE;
    
    [topView addSubview:self.nameInput];
    [topView addSubview:self.locationInput];
    
    [self.view addSubview:topView];
    
    //tableview part
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 85, 320, self.view.bounds.size.height-130) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor colorWithRed:244/255.0 green:241/255.0 blue:235/255.0 alpha:1.0];
    self.tableView.rowHeight = 62.0f;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 1)];
    headerView.backgroundColor = [UIColor colorWithRed:227/255.0 green:219/255.0 blue:204/255.0 alpha:1.0];
    self.tableView.tableHeaderView = headerView;
    
    [self.view addSubview:self.tableView];
    [self.view bringSubviewToFront:topView];
    
    addLocationBtn = [[UIButton alloc] initWithFrame:CGRectMake(10.0f, 5.0f, 300.0f, 44.0f)];
    UILabel *implyLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 6.0f, 240.0f, 32.0f)];
    implyLabel.backgroundColor = [UIColor clearColor];
    implyLabel.text = @"创建旅行地点";
    implyLabel.textColor = [UIColor colorWithRed:128/255.0 green:108/255.0 blue:77/255.0 alpha:1.0];
    implyLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:16];
    implyLabel.tag = TAG_IMPLYLABEL;
    [addLocationBtn addSubview:implyLabel];
    [addLocationBtn setBackgroundImage:[UIImage imageNamed:@"add_btn"]forState:UIControlStateNormal];
    [addLocationBtn setBackgroundImage:[UIImage imageNamed:@"add_btn_click"]forState:UIControlStateHighlighted];
    [addLocationBtn addTarget:self action:@selector(beginAddCustomLocation:) forControlEvents:UIControlEventTouchDown];
}

- (void) viewDidAppear:(BOOL)animated
{
    self.disappearing = FALSE;
    [self searchPoi];
}

- (IBAction)beginAddCustomLocation:(id)sender
{
    [self.nameInput resignFirstResponder];
    [self.locationInput resignFirstResponder];
    
    AddLocationViewController *addLocationViewController = [[AddLocationViewController alloc] init];
    addLocationViewController.location = [[Location alloc] init];
    addLocationViewController.location.name = self.nameInput.text;
    addLocationViewController.location.category = self.category;
    addLocationViewController.hasCoordinate = NO;
    addLocationViewController.addLocation = YES;
    addLocationViewController.lastLatitude = self.lastLatitude;
    addLocationViewController.lastLongitude = self.lastLongitude;
    addLocationViewController.editLocationDelegate = self;
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:addLocationViewController];
    [self presentViewController:navController animated:YES completion:NULL];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    if(searchBar == self.nameInput)
    {
        if(self.nameInput.frame.size.width != 195)
        {
            [UIView animateWithDuration:0.3
                                  delay:0
                                options:UIViewAnimationOptionLayoutSubviews
                             animations:^{
                                 [self.nameInput setFrame:CGRectMake(5, 45, 195, 30)];
                                 [self.locationInput setFrame:CGRectMake(200, 45, 115, 30)];
                             }
                             completion:NULL];
        }
    }
    else
    {
        if(self.locationInput.frame.size.width == 115)
        {    
            [UIView animateWithDuration:0.3
                                  delay:0
                                options:UIViewAnimationOptionLayoutSubviews
                             animations:^{
                                 [self.nameInput setFrame:CGRectMake(5, 45, 115, 30)];
                                 [self.locationInput setFrame:CGRectMake(120, 45, 195, 30)];
                             }
                             completion:NULL];
        }
    }
}

//- (void)textFieldDidBeginEditing:(UITextField *)textField
//{
//    if(textField == self.nameInput)
//    {
//        if(self.nameInput.frame.size.width != 180)
//        {
//            [UIView beginAnimations:nil context:nil];
//            [UIView setAnimationDuration:0.3];
//            [self.nameInput setFrame:CGRectMake(10, 45, 180, 30)];
//            [self.locationInput setFrame:CGRectMake(200, 45, 110, 30)];
//            [UIView commitAnimations];
//        }
//    }
//    else
//    {
//        if(self.locationInput.frame.size.width == 110)
//        {
//            [UIView beginAnimations:nil context:nil];
//            [UIView setAnimationDuration:0.3];
//            [self.locationInput setFrame:CGRectMake(130, 45, 180, 30)];
//            [self.nameInput setFrame:CGRectMake(10, 45, 110, 30)];
//            [UIView commitAnimations];
//        }
//    }
//}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (self.disappearing)
    {
        return;
    }
    
    if(searchBar == self.nameInput)
    {
        self.nameKeyword = [self.nameInput.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *addLocationBtnText = [NSString stringWithFormat:@"创建旅行地点 \"%@\"", self.nameKeyword];
        ((UILabel *)[addLocationBtn viewWithTag:TAG_IMPLYLABEL]).text = addLocationBtnText;
    }
    else if(searchBar == self.locationInput)
    {
        self.locationKeyword = [self.locationInput.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    
    if([self.locationKeyword length] == 0)
    {
        [self clearResults];
    }
    else
    {
        [self searchPoi];
    }
}

//-(IBAction)textFieldDidChange:(id)sender
//{
//    if (self.disappearing)
//    {
//        return;
//    }
//    
//    if(sender == self.nameInput)
//    {
//        self.nameKeyword = [self.nameInput.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//        NSString *addLocationBtnText = [NSString stringWithFormat:@"创建旅行地点 \"%@\"", self.nameKeyword];
//        ((UILabel *)[addLocationBtn viewWithTag:TAG_IMPLYLABEL]).text = addLocationBtnText;
//    }
//    else if(sender == self.locationInput)
//    {
//        self.locationKeyword = [self.locationInput.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//    }
//    
//    if([self.locationKeyword length] == 0)
//    {
//        [self clearResults];
//    }
//    else
//    {
//        [self searchPoi];
//    }
//}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.locationKeyword.length == 0)
    {
        return 0;
    }
    else
    {
        if (self.total > [allLocationList count]) {
            return [allLocationList count] + 1; //多显示一个loading cell
        }else{
            if (self.nameKeyword.length == 0) {
                return [allLocationList count]; //不多显示
            }else{
                return [allLocationList count] + 1; //多显示一个新建cell
            }
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.row < [allLocationList count])
    {
        static NSString *CellIdentifier = @"SearchLocationCell";
        
        cell = (SearchTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil){
            cell = [[SearchTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        NSDictionary *locationAtIndex = [(NSDictionary *)[allLocationList objectAtIndex:indexPath.row] objectForKey:@"_source"];
        NSString *name = [locationAtIndex objectForKey: @"name"];
        NSString *name_en = [locationAtIndex objectForKey: @"name_en"];
        NSString *city = [locationAtIndex objectForKey: @"city"];
        NSString *province = [locationAtIndex objectForKey: @"province"];
        NSString *country = [locationAtIndex objectForKey: @"country"];
        NSMutableArray *dests = [[NSMutableArray alloc] init];
        if (city.length > 0) {
            [dests addObject:city];
        }
        if (province.length > 0) {
            [dests addObject:province];
        }
        if ([country length] > 0) {
            [dests addObject:country];
        }
        
        NSNumber *poiId = [locationAtIndex objectForKey: @"id"];
        
        if ([name length] == 0) {
            name = name_en;
            name_en = nil;
        }
        
        UIImageView *categoryImage = (UIImageView *)[cell.contentView viewWithTag:1];
        categoryImage.image = [UIImage imageNamed:[self.categoryImage objectForKey:[locationAtIndex objectForKey:@"category"]]];
        
        UILabel *nameLabel = (UILabel *)[cell.contentView viewWithTag:2];
        nameLabel.text = name;
        
        UILabel *eNameLabel = (UILabel *)[cell.contentView viewWithTag:3];
        eNameLabel.hidden = NO;
        if(name_en.length != 0)
            eNameLabel.text = name_en;
        
        UILabel *locationLabel = (UILabel *)[cell.contentView viewWithTag:4];
        [locationLabel setText:[dests componentsJoinedByString:@"，"]];
        
        CGPoint nameLabelOrigin = CGPointMake(60, 7);
        CGPoint eNameLabelOrigin = CGPointMake(60, 29);
        CGPoint locationLabelOrigin = CGPointMake(60, 42);
        
        if (name_en.length == 0 && city.length == 0) {
            nameLabelOrigin = CGPointMake(60, 19);
            eNameLabel.hidden = YES;
        } else if (name_en.length == 0) {
            nameLabelOrigin = CGPointMake(60, 12);
            locationLabelOrigin = CGPointMake(60, 35);
            eNameLabel.hidden = YES;
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
        
        UIButton *operationBtn = (UIButton *)[cell.contentView viewWithTag:5];
        
        if(addedBefore)
        {
            [operationBtn setBackgroundImage:[UIImage imageNamed:@"remove_list"] forState:UIControlStateNormal];
            [operationBtn setBackgroundImage:[UIImage imageNamed:@"remove_list_click"] forState:UIControlStateHighlighted];
            [operationBtn removeTarget:self action:@selector(addLocation:) forControlEvents:UIControlEventTouchUpInside];
            [operationBtn addTarget:self action:@selector(removeLocation:) forControlEvents:UIControlEventTouchUpInside];
        }
        else
        {
            [operationBtn setBackgroundImage:[UIImage imageNamed:@"add_list"] forState:UIControlStateNormal];
            [operationBtn setBackgroundImage:[UIImage imageNamed:@"add_list_click"] forState:UIControlStateHighlighted];
            [operationBtn removeTarget:self action:@selector(removeLocation:) forControlEvents:UIControlEventTouchUpInside];
            [operationBtn addTarget:self action:@selector(addLocation:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    else if ([allLocationList count] != self.total)
    {
        static NSString *LoadingCellIdentifier = @"LoadingCell";
        
        cell = [tableView dequeueReusableCellWithIdentifier:LoadingCellIdentifier];
        
        if (!cell){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LoadingCellIdentifier];
        }
        UIActivityIndicatorView *loadingView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [loadingView setFrame:CGRectMake(140, 11, 40, 40)];
        [loadingView startAnimating];
        [cell.contentView addSubview:loadingView];
        [self fetchRestResult];
    }
    else if (indexPath.row == [allLocationList count])
    {
        static NSString *AddCellIdentifier = @"addLocationCell";
        cell = [tableView dequeueReusableCellWithIdentifier:AddCellIdentifier];
        if(!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AddCellIdentifier];
        }
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 1)];
        lineView.backgroundColor = [UIColor whiteColor];
        [cell.contentView addSubview:lineView];
        if(self.nameInput.text.length != 0)
        {
            [cell addSubview:addLocationBtn];
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.layer.opaque = YES;
    cell.layer.shouldRasterize = YES;
    cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    return cell;
}

- (IBAction)removeLocation:(id)sender
{
    shouldUpdateItinerary = YES;
    
    [self.nameInput resignFirstResponder];
    [self.locationInput resignFirstResponder];
    
    UIButton *button = (UIButton*)sender;
    UITableViewCell *cell = (UITableViewCell *)button.superview.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSDictionary *locationAtIndex = [(NSDictionary *)[allLocationList objectAtIndex:indexPath.row] objectForKey:@"_source"];
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
    
    [button setBackgroundImage:[UIImage imageNamed:@"add_list"] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"add_list_click"] forState:UIControlStateHighlighted];
    [button removeTarget:self action:@selector(removeLocation:) forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:self action:@selector(addLocation:) forControlEvents:UIControlEventTouchUpInside];
    
    iToastSettings *theSettings = [iToastSettings getSharedSettings];
    [theSettings setImage:[UIImage imageNamed:@"prompt_no"] forType:iToastTypeNotice];
    theSettings.duration = 3000;
    [[[[iToast makeText:NSLocalizedString(@"已从计划中移除", @"")] setGravity:iToastGravityCenter] setDuration:iToastDurationShort] show:iToastTypeNotice];
}

- (IBAction)addLocation:(id)sender
{
    shouldUpdateItinerary = YES;
    
    [self.nameInput resignFirstResponder];
    [self.locationInput resignFirstResponder];
    
    UIButton *button = (UIButton*)sender;
    UITableViewCell *cell = (UITableViewCell *)button.superview.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
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
    
    location.whichday = self.dayToAdd;
    location.seqofday = self.seqToAdd;
    
    [self.poiArray addObject:location.poiId];
    
    FMDatabase *db = [FMDatabase databaseWithPath:[Utility getDatabasePath]];
    [db open];
    [db executeUpdate:@"INSERT INTO location (plan_id,whichday,seqofday,name,name_en,country,city,address,transportation,category,latitude,longitude,useradd,poi_id,opening,fee,website) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);",self.planId,self.dayToAdd,self.seqToAdd,[location getRealName],[location getRealNameEn],location.country,location.city,location.address,location.transportation,location.category,location.latitude,location.longitude,[NSNumber numberWithBool:location.useradd],location.poiId,location.opening,location.fee,location.website];
    [db close];
    
    //increase seqToAdd
    self.seqToAdd = [NSNumber numberWithInt:[self.seqToAdd intValue]+1];
    
    [button setBackgroundImage:[UIImage imageNamed:@"remove_list"] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"remove_list_click"] forState:UIControlStateHighlighted];
    [button removeTarget:self action:@selector(addLocation:) forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:self action:@selector(removeLocation:) forControlEvents:UIControlEventTouchUpInside];
    
    iToastSettings *theSettings = [iToastSettings getSharedSettings];
    [theSettings setImage:[UIImage imageNamed:@"prompt_yes"] forType:iToastTypeNotice];
    theSettings.duration = 3000;
    [[[[iToast makeText:NSLocalizedString(@"已添加到计划", @"")] setGravity:iToastGravityCenter] setDuration:iToastDurationShort] show:iToastTypeNotice];
}

- (void)addCustomLocation:(Location *)location
{
    shouldUpdateItinerary = YES;
    
    FMDatabase *db = [FMDatabase databaseWithPath:[Utility getDatabasePath]];
    [db open];
    [db executeUpdate:@"INSERT INTO location (plan_id,whichday,seqofday,name,name_en,country,city,address,transportation,category,latitude,longitude,useradd,poi_id,opening,fee,website) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);",self.planId,self.dayToAdd,self.seqToAdd,[location getRealName],[location getRealNameEn],location.country,location.city,location.address,location.transportation,location.category,location.latitude,location.longitude,[NSNumber numberWithBool:location.useradd],location.poiId,location.opening,location.fee,location.website];
    [db close];
    
    self.seqToAdd = [NSNumber numberWithInt:[self.seqToAdd intValue]+1];
    iToastSettings *theSettings = [iToastSettings getSharedSettings];
    [theSettings setImage:[UIImage imageNamed:@"prompt_yes"] forType:iToastTypeNotice];
    theSettings.duration = 3000;
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
            self.nameInput.placeholder = @"搜索景点";
            break;
        case TAG_FOODBTN:
            self.category = @"美食";
            self.nameInput.placeholder = @"搜索美食";
            break;
        case TAG_HOTELBTN:
            self.category = @"住宿";
            self.nameInput.placeholder = @"搜索住宿";
            break;
        case TAG_OTHERBTN:
            self.category = @"其它";
            self.nameInput.placeholder = @"搜索其它";
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
    [self hideLoading];
}

- (void)clearResults
{
    [self cancelCurrentSearch];
    self.total = 0;
    allLocationList = nil;
    [self.tableView reloadData];
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
}

- (void)showLoading
{
    if (!self.loadingView) {
        self.loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.loadingView setFrame:CGRectMake(140, 180, 40, 40)];
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

- (void)searchPoi
{
    if([self.locationKeyword length] > 0)
    {
       if(self.locationInput.text != self.locationKeyword)
       {
           NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
           [userDefaults setObject:self.locationInput.text forKey:@"preferDestination"];
           [userDefaults synchronize];
       }
        
        [self clearResults];
        
        NSString *body = [self getSearchPostBody];
        if (body != nil) {
            fetcher = [[JSONFetcher alloc]
                       initWithURLString:@"http://chufaba.me:9200/cfb/poi/_search?size=30&from=0"
                       body:body
                       receiver:self
                       action:@selector(receiveResponse:)];
            fetcher.showAlerts = NO;
            [fetcher start];
            [self showLoading];
            timer = [NSTimer scheduledTimerWithTimeInterval:SEARCH_TIMEOUT target:self selector:@selector(searchTimeout) userInfo:nil repeats:NO];
        }
    }
}

- (NSString *)getSearchPostBody {
    NSString *keyword = [self.nameKeyword stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    keyword = [keyword stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    //NSString *location = [self.locationKeyword stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    NSString *location = [self.locationInput.text stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
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
                               "                        \"province\": {"
                               "                            \"prefix\": \"%@\","
                               "                            \"boost\": 2.0"
                               "                        }"
                               "                    }"
                               "                },"
                               "                {"
                               "                    \"prefix\" : {"
                               "                        \"province_en\": {"
                               "                            \"prefix\": \"%@\","
                               "                            \"boost\": 2.0"
                               "                        }"
                               "                    }"
                               "                },"
                               "                {"
                               "                    \"prefix\" : {"
                               "                        \"country\": {"
                               "                            \"prefix\": \"%@\","
                               "                            \"boost\": 3.0"
                               "                        }"
                               "                    }"
                               "                },"
                               "                {"
                               "                    \"prefix\" : {"
                               "                        \"country_en\": {"
                               "                            \"prefix\": \"%@\","
                               "                            \"boost\": 3.0"
                               "                        }"
                               "                    }"
                               "                }"
                               "            ],"
                               "            \"minimum_number_should_match\" : 1"
                               , location, location, location, location, location, location];
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
    [self hideLoading];
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
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
            [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
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
            timer = [NSTimer scheduledTimerWithTimeInterval:SEARCH_TIMEOUT target:self selector:@selector(searchTimeout) userInfo:nil repeats:NO];
        }
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

-(void) AddLocationViewController:(AddLocationViewController *) addLocationViewController didFinishAdd:(Location *) location
{
    [self addCustomLocation:location];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
