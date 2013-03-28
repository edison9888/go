//
//  SelectCategoryViewController.m
//  Chufaba
//
//  Created by 张辛欣 on 13-2-26.
//  Copyright (c) 2013年 ChufabaAPP团队. All rights reserved.
//

#import "SelectCategoryViewController.h"

@interface SelectCategoryViewController ()

@end

@implementation SelectCategoryViewController

#define ICON_HEIGHT 90
#define ICON_WIDTH 90
#define LABEL_HEIGHT 20
#define LABEL_WIDTH 90
#define ICON_ORIGIN_FIRST 50
#define ICON_ORIGIN_SECOND 180

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"选择分类"];
    self.view.backgroundColor = [UIColor colorWithRed:244/255.0 green:241/255.0 blue:235/255.0 alpha:1.0];
	
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 7, 40, 30)];
    [backBtn setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backToPrevious:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = btn;
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(ICON_ORIGIN_FIRST, 20.0, ICON_WIDTH, ICON_HEIGHT)];
    [button setBackgroundColor:[UIColor clearColor]];
    [button setBackgroundImage:[UIImage imageNamed:@"sight.png"]  forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"sight.png"]  forState:UIControlStateSelected | UIControlStateHighlighted];
    [button addTarget:self action:@selector(selectSight:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:button];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(ICON_ORIGIN_FIRST, 116.0, LABEL_WIDTH, LABEL_HEIGHT)];
    label.textColor = [UIColor colorWithRed:72/255.0 green:70/255.0 blue:66/255.0 alpha:1.0];
    label.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:16];
    label.backgroundColor = [UIColor clearColor];
    label.text = @"景点";
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
    
    button = [[UIButton alloc] initWithFrame:CGRectMake(ICON_ORIGIN_SECOND, 20.0, ICON_WIDTH, ICON_HEIGHT)];
    [button setBackgroundColor:[UIColor clearColor]];
    [button setBackgroundImage:[UIImage imageNamed:@"food.png"]  forState:UIControlStateNormal];
    [button addTarget:self action:@selector(selectFood:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:button];
    label = [[UILabel alloc] initWithFrame:CGRectMake(ICON_ORIGIN_SECOND, 116.0, LABEL_WIDTH, LABEL_HEIGHT)];
    label.textColor = [UIColor colorWithRed:72/255.0 green:70/255.0 blue:66/255.0 alpha:1.0];
    label.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:16];
    label.backgroundColor = [UIColor clearColor];
    label.text = @"美食";
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
    
    button = [[UIButton alloc] initWithFrame:CGRectMake(ICON_ORIGIN_FIRST, 150.0, ICON_WIDTH, ICON_HEIGHT)];
    [button setBackgroundColor:[UIColor clearColor]];
    [button setBackgroundImage:[UIImage imageNamed:@"hotel.png"]  forState:UIControlStateNormal];
    [button addTarget:self action:@selector(selectHotel:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:button];
    label = [[UILabel alloc] initWithFrame:CGRectMake(ICON_ORIGIN_FIRST, 246.0, LABEL_WIDTH, LABEL_HEIGHT)];
    label.textColor = [UIColor colorWithRed:72/255.0 green:70/255.0 blue:66/255.0 alpha:1.0];
    label.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:16];
    label.backgroundColor = [UIColor clearColor];
    label.text = @"住宿";
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
    
    button = [[UIButton alloc] initWithFrame:CGRectMake(ICON_ORIGIN_SECOND, 150.0, ICON_WIDTH, ICON_HEIGHT)];
    [button setBackgroundColor:[UIColor clearColor]];
    [button setBackgroundImage:[UIImage imageNamed:@"entertainment.png"]  forState:UIControlStateNormal];
    [button addTarget:self action:@selector(selectEntertainment:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:button];
    label = [[UILabel alloc] initWithFrame:CGRectMake(ICON_ORIGIN_SECOND, 246.0, LABEL_WIDTH, LABEL_HEIGHT)];
    label.textColor = [UIColor colorWithRed:72/255.0 green:70/255.0 blue:66/255.0 alpha:1.0];
    label.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:16];
    label.backgroundColor = [UIColor clearColor];
    label.text = @"娱乐";
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
    
    button = [[UIButton alloc] initWithFrame:CGRectMake(ICON_ORIGIN_FIRST, 280.0, ICON_WIDTH, ICON_HEIGHT)];
    [button setBackgroundColor:[UIColor clearColor]];
    [button setBackgroundImage:[UIImage imageNamed:@"transport.png"]  forState:UIControlStateNormal];
    [button addTarget:self action:@selector(selectTransport:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:button];
    label = [[UILabel alloc] initWithFrame:CGRectMake(ICON_ORIGIN_FIRST, 376.0, LABEL_WIDTH, LABEL_HEIGHT)];
    label.textColor = [UIColor colorWithRed:72/255.0 green:70/255.0 blue:66/255.0 alpha:1.0];
    label.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:16];
    label.backgroundColor = [UIColor clearColor];
    label.text = @"交通";
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
    
    button = [[UIButton alloc] initWithFrame:CGRectMake(ICON_ORIGIN_SECOND, 280.0, ICON_WIDTH, ICON_HEIGHT)];
    [button setBackgroundColor:[UIColor clearColor]];
    [button setBackgroundImage:[UIImage imageNamed:@"more.png"]  forState:UIControlStateNormal];
    [button addTarget:self action:@selector(selectMore:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:button];
    label = [[UILabel alloc] initWithFrame:CGRectMake(ICON_ORIGIN_SECOND, 376.0, LABEL_WIDTH, LABEL_HEIGHT)];
    label.textColor = [UIColor colorWithRed:72/255.0 green:70/255.0 blue:66/255.0 alpha:1.0];
    label.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:16];
    label.backgroundColor = [UIColor clearColor];
    label.text = @"其他";
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
}

- (IBAction)backToPrevious:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"SearchLocation"])
    {
        SearchLocationViewController *searchLocationViewController = segue.destinationViewController;
        searchLocationViewController.searchDelegate = self;
        searchLocationViewController.category = self.category;
        if (self.lastLatitude) {
            searchLocationViewController.lastLatitude = self.lastLatitude;
            searchLocationViewController.lastLongitude = self.lastLongitude;
        }
    }
}

- (void) notifyItinerayView:(Location *) location
{
    [self.delegate didAddLocation: location];
    [self.navigationController popViewControllerAnimated:NO];
}

- (IBAction)selectSight:(id)sender
{
    self.category = @"景点";
    [self performSegueWithIdentifier:@"SearchLocation" sender:sender];
}

- (IBAction)selectFood:(id)sender
{
    self.category = @"美食";
    [self performSegueWithIdentifier:@"SearchLocation" sender:sender];
}

- (IBAction)selectHotel:(id)sender
{
    self.category = @"住宿";
    [self performSegueWithIdentifier:@"SearchLocation" sender:sender];
}

- (IBAction)selectEntertainment:(id)sender
{
    self.category = @"娱乐";
    [self performSegueWithIdentifier:@"SearchLocation" sender:sender];
}

- (IBAction)selectTransport:(id)sender
{
    self.category = @"交通";
    [self performSegueWithIdentifier:@"SearchLocation" sender:sender];
}

- (IBAction)selectMore:(id)sender
{
    self.category = @"更多";
    [self performSegueWithIdentifier:@"SearchLocation" sender:sender];
}

@end
