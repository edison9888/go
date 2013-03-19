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
    MKMapView *mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    mapView.delegate = self;
    [self.view addSubview:mapView];
    self.navigationItem.title = @"地图详情";
	if ([self.location.latitude intValue] != 10000) {
        CLLocationCoordinate2D customLoc2D_5 = CLLocationCoordinate2DMake([self.location.latitude doubleValue], [self.location.longitude doubleValue]);
        [mapView setCenterCoordinate:customLoc2D_5 animated:YES];
        
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(customLoc2D_5, 1500, 1500);
        MKCoordinateRegion adjustedRegion = [mapView regionThatFits:region];
        
        //[mapView setRegion:region animated:false];
        [mapView setRegion:adjustedRegion animated:false];
        [mapView selectAnnotation:[LocationAnnotation annotationForLocation:self.location ShowTitle:true] animated:false];
    }
}

#define LOCATION_ANNOTATION_VIEWS @"LocationAnnotationViews"

- (MKAnnotationView *)mapView:(MKMapView *)sender viewForAnnotation:(id <MKAnnotation>)annotation
{
    MKAnnotationView *aView = [sender dequeueReusableAnnotationViewWithIdentifier:LOCATION_ANNOTATION_VIEWS];
    
	if (!aView) {
		aView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:LOCATION_ANNOTATION_VIEWS];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, 20, 20);
        button.tag = 1;
        [button setImage:[UIImage imageNamed:@"direction.png"] forState:UIControlStateNormal];
        aView.rightCalloutAccessoryView = button;
        
        aView.leftCalloutAccessoryView = [[UILabel alloc] initWithFrame:CGRectMake(0,0,30,30)];
        ((UILabel *)aView.leftCalloutAccessoryView).textAlignment = NSTextAlignmentCenter;
        ((UILabel *)aView.leftCalloutAccessoryView).textColor = [UIColor whiteColor];
        ((UILabel *)aView.leftCalloutAccessoryView).backgroundColor = [UIColor colorWithRed:0.239 green:0.239 blue:0.239 alpha:0.1];
        ((UILabel *)aView.leftCalloutAccessoryView).text = [NSString stringWithFormat:@"%d", [self.index intValue]+1];
        
        aView.annotation = annotation;
		aView.canShowCallout = YES;
	}
	return aView;
}

- (void)mapView:(MKMapView *)sender annotationView:(MKAnnotationView *)aView calloutAccessoryControlTapped:(UIControl *)control
{
    if (control.tag == 1) {
        Class mapItemClass = [MKMapItem class];
        if (mapItemClass && [mapItemClass respondsToSelector:@selector(openMapsWithItems:launchOptions:)])
        {
            MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:aView.annotation.coordinate addressDictionary:nil];
            MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
            [mapItem setName:aView.annotation.title];
            
            NSDictionary *launchOptions = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving};
            
            MKMapItem *currentLocationMapItem = [MKMapItem mapItemForCurrentLocation];
            
            [MKMapItem openMapsWithItems:@[currentLocationMapItem, mapItem] launchOptions:launchOptions];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
