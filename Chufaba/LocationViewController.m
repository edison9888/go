//
//  itineraryDetailViewController.m
//  出发吧
//
//  Created by kenzo on 13-1-16.
//  Copyright (c) 2013年 出发吧APP团队. All rights reserved.
//

#import "LocationViewController.h"
#import "Location.h"
#import "EditTransportViewController.h"
#import "EditCostViewController.h"
#import "EditDetailViewController.h"
#import "EditScheduleViewController.h"
#import "EditCategoryViewController.h"

@interface LocationViewController ()

@property (nonatomic) BOOL changed;

- (void)configureView;

@end

@implementation LocationViewController

#pragma mark - Managing the detail item

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    self.navigationItem.rightBarButtonItem = doneButton;
}

- (void)done
{
    if (self.changed) {
        [self.delegate didChangeLocation:self.location];
    }
    [self.navigationController popViewControllerAnimated:true];
}

- (void)setLocation:(Location *) newLocation
{
    if (_location != newLocation) {
        _location = newLocation;
        
        // Update the view.
        [self configureView];
        self.changed = false;
    }
}

- (void)configureView
{
    // Update the user interface for the detail item.
    
    if (self.location) {
        self.nameLabel.text = self.location.name;
        self.addressLabel.text = self.location.address;
        self.transportationLabel.text = self.location.transportation;
        [self configureCostCell];
        [self configureScheduleCell];
        self.detailLabel.text = self.location.detail;
        self.categoryLabel.text = self.location.category;
    }
}

- (void)configureCostCell
{
    if(!self.location.cost){
        self.location.cost = [NSNumber numberWithInt:0];
    }
    if(!self.location.currency){
        self.location.currency = @"RMB";
    }
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    self.costLabel.text = [NSString stringWithFormat:@"%@ %@", self.location.currency, [formatter stringFromNumber:self.location.cost]];
}

- (void)configureScheduleCell
{
    if(self.location.visitBegin || self.location.visitEnd){
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterNoStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        self.scheduleLabel.text = [NSString stringWithFormat:@"%@ - %@", [formatter stringFromDate:self.location.visitBegin] ?: @"", [formatter stringFromDate:self.location.visitEnd] ?: @""];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"EditTransport"]) {
        EditTransportViewController *transportViewController = [segue destinationViewController];
        transportViewController.transportation = self.location.transportation;
        transportViewController.delegate = self;
    }else if ([[segue identifier] isEqualToString:@"EditCost"]) {
        EditCostViewController *costViewController = [segue destinationViewController];
        costViewController.amount = self.location.cost;
        costViewController.currency = self.location.currency;
        costViewController.delegate = self;
    }else if ([[segue identifier] isEqualToString:@"EditDetail"]) {
        EditDetailViewController *detailViewController = [segue destinationViewController];
        detailViewController.detail = self.location.detail;
        detailViewController.delegate = self;
        detailViewController.delegate = self;
    }else if ([[segue identifier] isEqualToString:@"EditSchedule"]) {
        EditScheduleViewController *scheduleViewController = [segue destinationViewController];
        scheduleViewController.start = self.location.visitBegin;
        scheduleViewController.end = self.location.visitEnd;
        scheduleViewController.delegate = self;
    }else if ([[segue identifier] isEqualToString:@"EditCategory"]) {
        EditCategoryViewController *categoryViewController = [segue destinationViewController];
        categoryViewController.category = self.location.category;
        categoryViewController.delegate = self;
    }
}

-(void) didEditTransport:(NSString *)transportation
{
    self.location.transportation = transportation;
    self.transportationLabel.text = transportation;
    self.changed = true;
}

-(void) didEditCostWithAmount:(NSNumber *)amount AndCurrency:(NSString *)currency
{
    self.location.cost = amount;
    self.location.currency = currency;
    [self configureCostCell];
    self.changed = true;
}

-(void) didEditScheduleWithStart:(NSDate *)start AndEnd:(NSDate *)end
{
    self.location.visitBegin = start;
    self.location.visitEnd = end;
    [self configureScheduleCell];
    self.changed = true;
}

-(void) didEditDetail:(NSString *)detail
{
    self.location.detail = detail;
    self.detailLabel.text = detail;
    self.changed = true;
}

-(void) didEditCategory:(NSString *)category
{
    self.location.category = category;
    self.categoryLabel.text = category;
    self.changed = true;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
