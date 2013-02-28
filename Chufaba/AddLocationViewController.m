//
//  AddLocationViewController.m
//  Chufaba
//
//  Created by 张辛欣 on 13-2-28.
//  Copyright (c) 2013年 ChufabaAPP团队. All rights reserved.
//

#import "AddLocationViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface AddLocationViewController ()

@end

@implementation AddLocationViewController

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
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    [topView setBackgroundColor:[UIColor whiteColor]];
    
    UITextField *nameOfAddLocation = [[UITextField alloc] initWithFrame:CGRectMake(10, 5, 300, 40)];
    [nameOfAddLocation setBorderStyle:UITextBorderStyleLine];
    nameOfAddLocation.layer.cornerRadius=5.0f;
    nameOfAddLocation.layer.masksToBounds=YES;
    nameOfAddLocation.layer.borderColor=[[UIColor grayColor]CGColor];
    nameOfAddLocation.layer.borderWidth= 1.0f;
    nameOfAddLocation.text = self.addLocationName;
    nameOfAddLocation.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    
    [topView addSubview:nameOfAddLocation];
    [topView bringSubviewToFront:nameOfAddLocation];
    [self.view addSubview:topView];
    
	MKMapView *mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 50, 320, 430)];
    mapView.delegate = self;
    
    UILabel *implyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20)];
    implyLabel.text = @"点击地图，为这个地点标注正确的位置";
    implyLabel.backgroundColor = [UIColor colorWithRed:0.239 green:0.239 blue:0.239 alpha:0.8];
    implyLabel.font = [UIFont systemFontOfSize:14];
    implyLabel.textColor = [UIColor whiteColor];
    implyLabel.textAlignment = NSTextAlignmentCenter;
    [mapView addSubview:implyLabel];
    
    [self.view addSubview:mapView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(confirmAddLocation:)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAddLocation:)];
    
    if ([self.lastLatitude intValue] != 10000 && [self.lastLatitude intValue] != 0)
    {
        CLLocationCoordinate2D customLoc2D_5 = CLLocationCoordinate2DMake([self.lastLatitude doubleValue], [self.lastLongitude doubleValue]);
        [mapView setCenterCoordinate:customLoc2D_5 animated:YES];
        MKCoordinateRegion region;
        region.center = customLoc2D_5;
        MKCoordinateSpan span;
        span.latitudeDelta = 0.4;
        span.longitudeDelta = 0.4;
        region.span=span;
        [mapView setRegion:region animated:false];
    }
}

- (IBAction)confirmAddLocation:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)cancelAddLocation:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
