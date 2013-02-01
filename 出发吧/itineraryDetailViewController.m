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
#import "itineraryCostViewController.h"

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
    
    if (self.location) {
        self.nameLabel.text = self.location.name;
        self.addressLabel.text = self.location.address;
        self.transportationLabel.text = self.location.transportation;
        [self updateCostLabelWithAmount:self.location.cost AndCurrency:self.location.currency];
        //self.scheduleLabel.text = self.location.schedule;
        self.detailLabel.text = self.location.detail;
        self.categoryLabel.text = self.location.category;
    }
}

- (void)updateCostLabelWithAmount: (NSNumber *)amount AndCurrency:(NSString *)currency
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    self.costLabel.text = [NSString stringWithFormat:@"%@ %@", currency, [formatter stringFromNumber:amount]];
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
        transportViewController.transportation = self.location.transportation;
        transportViewController.delegate = self;
    }else if ([[segue identifier] isEqualToString:@"EditCost"]) {
        itineraryCostViewController *costViewController = [segue destinationViewController];
        costViewController.amount = self.location.cost;
        costViewController.currency = self.location.currency;
        costViewController.delegate = self;
    }
}

-(void) didEditTransport:(NSString *)transportation
{
    self.location.transportation = transportation;
    self.transportationLabel.text = transportation;
}

-(void) didEditCostWithAmount:(NSNumber *)amount AndCurrency:(NSString *)currency
{
    self.location.cost = amount;
    self.location.currency = currency;
    [self updateCostLabelWithAmount:amount AndCurrency:currency];
}

-(void) didEditScheduleWithStart:(NSDate *)start AndEnd:(NSDate *)end
{
    
}

-(void) didEditDetail:(NSString *)detail
{
    
}

-(void) didEditCategory:(NSString *)category
{
    
}

@end
