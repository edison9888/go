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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:244/255.0 green:241/255.0 blue:235/255.0 alpha:1.0];
	// Do any additional setup after loading the view.
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(45.0, 20.0, 100.0, 100.0)];
    [button setBackgroundColor:[UIColor clearColor]];
    [button setBackgroundImage:[UIImage imageNamed:@"sight.png"]  forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"sight.png"]  forState:UIControlStateSelected | UIControlStateHighlighted];
    [button addTarget:self action:@selector(selectSight:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:button];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(45.0, 120.0, 100.0, 20.0)];
    label.backgroundColor = [UIColor clearColor];
    label.text = @"景点";
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
    
    button = [[UIButton alloc] initWithFrame:CGRectMake(175.0, 20.0, 100.0, 100.0)];
    [button setBackgroundColor:[UIColor clearColor]];
    [button setBackgroundImage:[UIImage imageNamed:@"food.png"]  forState:UIControlStateNormal];
    [button addTarget:self action:@selector(selectFood:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:button];
    label = [[UILabel alloc] initWithFrame:CGRectMake(175.0, 120.0, 100.0, 20.0)];
    label.backgroundColor = [UIColor clearColor];
    label.text = @"美食";
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
    
    button = [[UIButton alloc] initWithFrame:CGRectMake(45.0, 150.0, 100.0, 100.0)];
    [button setBackgroundColor:[UIColor clearColor]];
    [button setBackgroundImage:[UIImage imageNamed:@"hotel.png"]  forState:UIControlStateNormal];
    [button addTarget:self action:@selector(selectHotel:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:button];
    label = [[UILabel alloc] initWithFrame:CGRectMake(45.0, 250.0, 100.0, 20.0)];
    label.backgroundColor = [UIColor clearColor];
    label.text = @"住宿";
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
    
    button = [[UIButton alloc] initWithFrame:CGRectMake(175.0, 150.0, 100.0, 100.0)];
    [button setBackgroundColor:[UIColor clearColor]];
    [button setBackgroundImage:[UIImage imageNamed:@"entertainment.png"]  forState:UIControlStateNormal];
    [button addTarget:self action:@selector(selectEntertainment:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:button];
    label = [[UILabel alloc] initWithFrame:CGRectMake(175.0, 250.0, 100.0, 20.0)];
    label.backgroundColor = [UIColor clearColor];
    label.text = @"娱乐";
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
    
    button = [[UIButton alloc] initWithFrame:CGRectMake(45.0, 280.0, 100.0, 100.0)];
    [button setBackgroundColor:[UIColor clearColor]];
    [button setBackgroundImage:[UIImage imageNamed:@"transport.png"]  forState:UIControlStateNormal];
    [button addTarget:self action:@selector(selectTransport:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:button];
    label = [[UILabel alloc] initWithFrame:CGRectMake(45.0, 380.0, 100.0, 20.0)];
    label.backgroundColor = [UIColor clearColor];
    label.text = @"交通";
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
    
    button = [[UIButton alloc] initWithFrame:CGRectMake(175.0, 280.0, 100.0, 100.0)];
    [button setBackgroundColor:[UIColor clearColor]];
    [button setBackgroundImage:[UIImage imageNamed:@"more.png"]  forState:UIControlStateNormal];
    [button addTarget:self action:@selector(selectMore:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:button];
    label = [[UILabel alloc] initWithFrame:CGRectMake(175.0, 380.0, 100.0, 20.0)];
    label.backgroundColor = [UIColor clearColor];
    label.text = @"其他";
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
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
