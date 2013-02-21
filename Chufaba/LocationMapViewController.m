//
//  LocationMapViewController.m
//  Chufaba
//
//  Created by Perry on 13-2-21.
//  Copyright (c) 2013年 ChufabaAPP团队. All rights reserved.
//

#import "LocationMapViewController.h"

@interface LocationMapViewController ()

@end

@implementation LocationMapViewController

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
	if ([self.location.latitude intValue] != 10000) {
        self.mapView.frame = self.view.bounds;
        CLLocationCoordinate2D customLoc2D_5 = CLLocationCoordinate2DMake([self.location.latitude doubleValue], [self.location.longitude doubleValue]);
        [self.mapView setCenterCoordinate:customLoc2D_5 animated:YES];
        MKCoordinateRegion region;
        region.center = customLoc2D_5;
        MKCoordinateSpan span;
        span.latitudeDelta = 0.4;
        span.longitudeDelta = 0.4;
        region.span=span;
        [self.mapView setRegion:region animated:false];
        [self.mapView selectAnnotation:[LocationAnnotation annotationForLocation:self.location ShowTitle:true] animated:false];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
