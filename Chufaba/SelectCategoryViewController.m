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
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
	// Do any additional setup after loading the view.
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
