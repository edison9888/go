//
//  itineraryDetailViewController.m
//  出发吧
//
//  Created by kenzo on 13-1-16.
//  Copyright (c) 2013年 出发吧APP团队. All rights reserved.
//

#import "itineraryDetailViewController.h"
#import "TravelLocation.h"
#import "itineraryTransportViewController.h"

@interface itineraryDetailViewController ()
- (void)configureView;
@end

@implementation itineraryDetailViewController

#pragma mark - Managing the detail item

- (void)setLocation:(TravelLocation *) newLocation
{
    if (_location != newLocation) {
        _location = newLocation;
        
        // Update the view.
        [self configureView];
    }
}

- (void)configureView
{
    // Update the user interface for the detail item.

    TravelLocation *theLocation = self.location;
    
    if (theLocation) {
        self.nameLabel.text = theLocation.name;
        self.addressLabel.text = theLocation.address;
        self.transportationLabel.text = theLocation.transportation;
        //self.costLabel.text = theLocation.cost;
        //self.scheduleLabel.text = theLocation.schedule;
        self.detailLabel.text = theLocation.detail;
        self.categoryLabel.text = theLocation.category;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"EditTransport"]) {
        itineraryTransportViewController *transportViewController = [segue destinationViewController];
        transportViewController.transportation = self.transportationLabel.text;
        transportViewController.delegate = self;
    }
}

-(void) didEditTransport:(NSString *)transportation
{
    self.transportationLabel.text = transportation;
}

@end
