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
    self.normalMapMode = YES;
    
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 7, 40, 30)];
    [backBtn setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backToPrevious:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = btn;
    
    MKMapView *mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    mapView.delegate = self;
    mapView.tag = 20;
    
    [self setTitle:@"地图详情"];
	CLLocationCoordinate2D customLoc2D_5 = CLLocationCoordinate2DMake([self.location.latitude doubleValue], [self.location.longitude doubleValue]);
    [mapView setCenterCoordinate:customLoc2D_5 animated:YES];
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(customLoc2D_5, 1500, 1500);
    MKCoordinateRegion adjustedRegion = [mapView regionThatFits:region];
    
    [mapView setRegion:adjustedRegion animated:false];
    [mapView selectAnnotation:[LocationAnnotation annotationForLocation:self.location ShowTitle:true] animated:false];
    
    UIButton *mapModeButton = [[UIButton alloc] initWithFrame:CGRectMake(270,mapView.frame.size.height-80,40,30)];
    mapModeButton.tag = 21;
    [mapModeButton setImage:[UIImage imageNamed:@"satelitemap.png"] forState:UIControlStateNormal];
    [mapModeButton addTarget:self action:@selector(selectSateliteMap:) forControlEvents:UIControlEventTouchDown];
    
    UIButton *positionButton = [[UIButton alloc] initWithFrame:CGRectMake(10,mapView.frame.size.height-80,40,30)];
    [positionButton setImage:[UIImage imageNamed:@"position.png"] forState:UIControlStateNormal];
    [positionButton addTarget:self action:@selector(positionMe:) forControlEvents:UIControlEventTouchDown];
    
    [mapView addSubview:mapModeButton];
    [mapView addSubview:positionButton];
    mapView.showsUserLocation = YES;
    
    [self.view addSubview:mapView];
}

- (IBAction)positionMe:(id)sender
{
    MKMapView *mapView = (MKMapView *)[self.view viewWithTag:20];
    [mapView setCenterCoordinate:mapView.userLocation.coordinate animated:YES];
    [mapView selectAnnotation:mapView.userLocation animated:YES];
}

- (IBAction)backToPrevious:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)selectNormalMap:(id)sender
{
    MKMapView *mapView = (MKMapView *)[self.view viewWithTag:20];
    
    UIButton *mapModeBtn = (UIButton *)[mapView viewWithTag:21];
    [mapModeBtn setImage:[UIImage imageNamed:@"satelitemap.png"] forState:UIControlStateNormal];
    [mapModeBtn removeTarget:self action:@selector(selectNormalMap:) forControlEvents:UIControlEventTouchDown];
    [mapModeBtn addTarget:self action:@selector(selectSateliteMap:) forControlEvents:UIControlEventTouchDown];
    
    mapView.mapType = MKMapTypeStandard;
}


- (IBAction)selectSateliteMap:(id)sender
{    
    MKMapView *mapView = (MKMapView *)[self.view viewWithTag:20];
    
    UIButton *mapModeBtn = (UIButton *)[mapView viewWithTag:21];
    [mapModeBtn setImage:[UIImage imageNamed:@"normalmap.png"] forState:UIControlStateNormal];
    [mapModeBtn removeTarget:self action:@selector(selectSateliteMap:) forControlEvents:UIControlEventTouchDown];
    [mapModeBtn addTarget:self action:@selector(selectNormalMap:) forControlEvents:UIControlEventTouchDown];
    
    mapView.mapType = MKMapTypeSatellite;
}

#define LOCATION_ANNOTATION_VIEWS @"LocationAnnotationViews"

- (MKAnnotationView *)mapView:(MKMapView *)sender viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]])
    {
//        ((MKUserLocation *)annotation).title = @"我在这";
//        MKPinAnnotationView *userLocationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"UserLocation"];
//        userLocationView.pinColor = MKPinAnnotationColorGreen;
//        userLocationView.canShowCallout = YES;
//        return userLocationView;
        ((MKUserLocation *)annotation).title = @"我在这";
        return nil;
    }
    
    MKAnnotationView *aView = [sender dequeueReusableAnnotationViewWithIdentifier:LOCATION_ANNOTATION_VIEWS];
    
	if (!aView) {
        aView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:LOCATION_ANNOTATION_VIEWS];
        aView.image = [Location getCategoryIconMap:self.location.category];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, 20, 20);
        button.tag = 1;
        [button setImage:[UIImage imageNamed:@"direction.png"] forState:UIControlStateNormal];
        aView.rightCalloutAccessoryView = button;
        
        aView.leftCalloutAccessoryView = [[UILabel alloc] initWithFrame:CGRectMake(0,0,30,30)];
        ((UILabel *)aView.leftCalloutAccessoryView).textAlignment = NSTextAlignmentCenter;
        ((UILabel *)aView.leftCalloutAccessoryView).textColor = [UIColor colorWithRed:196/255.0 green:230/255.0 blue:184/255.0 alpha:1];
        ((UILabel *)aView.leftCalloutAccessoryView).backgroundColor = [UIColor clearColor];
        ((UILabel *)aView.leftCalloutAccessoryView).text = [NSString stringWithFormat:@"%d", self.index + 1];
        
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
