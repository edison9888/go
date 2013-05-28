//
//  LocationMapViewController.m
//  Chufaba
//
//  Created by Perry on 13-2-21.
//  Copyright (c) 2013年 ChufabaAPP团队. All rights reserved.
//

#import "LocationMapViewController.h"
#import "QuartzCore/QuartzCore.h"

@interface LocationMapViewController ()
{
    BOOL ios6OrAbove;
    NSInteger btnOffset;
}

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
    self.categoryImage = [NSDictionary dictionaryWithObjectsAndKeys:@"pin_sight", @"景点", @"pin_food", @"美食", @"pin_hotel", @"住宿", @"pin_more", @"其它", nil];
    
    self.navigationItem.title = @"地图详情";
    
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 7, 40, 30)];
    [backBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backBtn setImage:[UIImage imageNamed:@"back_click"] forState:UIControlStateHighlighted];
    [backBtn addTarget:self action:@selector(backToPrevious:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = btn;
    
    MKMapView *mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    mapView.delegate = self;
    mapView.tag = 20;
    
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    if ([currSysVer compare:@"6.0" options:NSNumericSearch] != NSOrderedAscending)
    {
        ios6OrAbove = TRUE;
        btnOffset = 90;
    }
    else
    {
        ios6OrAbove = FALSE;
        btnOffset = 96;
    }
    
	CLLocationCoordinate2D customLoc2D_5 = CLLocationCoordinate2DMake([self.location.latitude doubleValue], [self.location.longitude doubleValue]);
    [mapView setCenterCoordinate:customLoc2D_5 animated:YES];
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(customLoc2D_5, 1500, 1500);
    MKCoordinateRegion adjustedRegion = [mapView regionThatFits:region];
    
    [mapView setRegion:adjustedRegion animated:false];
    [mapView addAnnotation:[LocationAnnotation annotationForLocation:self.location ShowTitle:true]];
    [mapView selectAnnotation:[LocationAnnotation annotationForLocation:self.location ShowTitle:true] animated:false];
    
    UIButton *mapModeButton = [[UIButton alloc] initWithFrame:CGRectMake(270,mapView.frame.size.height-btnOffset,40,30)];
    mapModeButton.tag = 21;
    [mapModeButton setImage:[UIImage imageNamed:@"satelitemap"] forState:UIControlStateNormal];
    [mapModeButton setImage:[UIImage imageNamed:@"satelitemap_click"] forState:UIControlStateHighlighted];
    [mapModeButton addTarget:self action:@selector(selectSateliteMap:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *positionButton = [[UIButton alloc] initWithFrame:CGRectMake(10,mapView.frame.size.height-btnOffset,40,30)];
    [positionButton setImage:[UIImage imageNamed:@"position"] forState:UIControlStateNormal];
    [positionButton setImage:[UIImage imageNamed:@"position_click"] forState:UIControlStateHighlighted];
    [positionButton addTarget:self action:@selector(positionMe:) forControlEvents:UIControlEventTouchUpInside];
    
    [mapView addSubview:mapModeButton];
    [mapView addSubview:positionButton];
    mapView.showsUserLocation = YES;

    if (!ios6OrAbove)
    {
        for (UIGestureRecognizer *gesture in mapView.gestureRecognizers)
        {
            if([gesture isKindOfClass:[UITapGestureRecognizer class]])
            {
                gesture.delegate = self;
                break;
            }
        }
    }
    
    [self.view addSubview:mapView];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[UIButton class]])
    {
        return NO;
    }
    return YES;
}

- (BOOL)showPositionAlert
{
    if(![CLLocationManager locationServicesEnabled])
        return TRUE;
    if([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
        return TRUE;
    return FALSE;
}

- (IBAction)positionMe:(id)sender
{
    if([self showPositionAlert])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"请在系统设置中打开“定位服务”来允许“出发吧”确定您的位置"
                                                       delegate:nil
                                              cancelButtonTitle:@"知道了"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
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
    [mapModeBtn setImage:[UIImage imageNamed:@"satelitemap"] forState:UIControlStateNormal];
    [mapModeBtn setImage:[UIImage imageNamed:@"satelitemap_click"] forState:UIControlStateHighlighted];
    [mapModeBtn removeTarget:self action:@selector(selectNormalMap:) forControlEvents:UIControlEventTouchUpInside];
    [mapModeBtn addTarget:self action:@selector(selectSateliteMap:) forControlEvents:UIControlEventTouchUpInside];
    
    mapView.mapType = MKMapTypeStandard;
}


- (IBAction)selectSateliteMap:(id)sender
{    
    MKMapView *mapView = (MKMapView *)[self.view viewWithTag:20];
    
    UIButton *mapModeBtn = (UIButton *)[mapView viewWithTag:21];
    [mapModeBtn setImage:[UIImage imageNamed:@"normalmap"] forState:UIControlStateNormal];
    [mapModeBtn setImage:[UIImage imageNamed:@"normalmap_click"] forState:UIControlStateHighlighted];
    [mapModeBtn removeTarget:self action:@selector(selectSateliteMap:) forControlEvents:UIControlEventTouchUpInside];
    [mapModeBtn addTarget:self action:@selector(selectNormalMap:) forControlEvents:UIControlEventTouchUpInside];
    
    mapView.mapType = MKMapTypeSatellite;
}

#define LOCATION_ANNOTATION_VIEWS @"LocationAnnotationViews"

- (MKAnnotationView *)mapView:(MKMapView *)sender viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]])
    {
        ((MKUserLocation *)annotation).title = @"我在这";
        return nil;
    }
    
    MKAnnotationView *aView = [sender dequeueReusableAnnotationViewWithIdentifier:LOCATION_ANNOTATION_VIEWS];
    
	if (!aView) {
        aView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:LOCATION_ANNOTATION_VIEWS];
        //aView.image = [Location getCategoryIconMap:self.location.category];
        aView.image = [UIImage imageNamed:[self.categoryImage objectForKey:self.location.category]];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, 28, 28);
        button.tag = 1;
        [button setImage:[UIImage imageNamed:@"navigation"] forState:UIControlStateNormal];
        aView.rightCalloutAccessoryView = button;
        
        aView.annotation = annotation;
		aView.canShowCallout = YES;
	}
	return aView;
}

- (void)mapView:(MKMapView *)sender annotationView:(MKAnnotationView *)aView calloutAccessoryControlTapped:(UIControl *)control
{
    if (control.tag == 1)
    {
        if (ios6OrAbove)
        {
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]])
            {
                UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"使用苹果自带地图导航", @"使用Googel Maps导航", nil];
                actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
                [actionSheet showInView:self.view];
            }
            else
            {
                MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:aView.annotation.coordinate addressDictionary:nil];
                MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
                [mapItem setName:aView.annotation.title];
                NSDictionary *launchOptions = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving};
                MKMapItem *currentLocationMapItem = [MKMapItem mapItemForCurrentLocation];
                [MKMapItem openMapsWithItems:@[currentLocationMapItem, mapItem] launchOptions:launchOptions];
            }
        }
        else
        {
            if([self showPositionAlert])
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                                message:@"请在系统设置中打开“定位服务”来允许“出发吧”确定您的位置"
                                                               delegate:nil
                                                      cancelButtonTitle:@"知道了"
                                                      otherButtonTitles:nil];
                [alert show];
                return;
            }
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]])
            {
                NSString* url = [NSString stringWithFormat: @"comgooglemaps://?saddr=%f,%f&daddr=%f,%f&directionsmode=transit", sender.userLocation.coordinate.latitude, sender.userLocation.coordinate.longitude, aView.annotation.coordinate.latitude, aView.annotation.coordinate.longitude];
                [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
            }
            else
            {
                NSString* url = [NSString stringWithFormat: @"http://maps.google.com/maps?saddr=%f,%f&daddr=%f,%f&dirflg=r", sender.userLocation.coordinate.latitude, sender.userLocation.coordinate.longitude, aView.annotation.coordinate.latitude, aView.annotation.coordinate.longitude];
                [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
            }
        }
    }
}

-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    MKMapView *mapView = (MKMapView *)[self.view viewWithTag:20];
    id <MKAnnotation> annotation = [mapView.selectedAnnotations objectAtIndex:0];
    if(buttonIndex == 0)
    {
        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:annotation.coordinate addressDictionary:nil];
        MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
        [mapItem setName:annotation.title];
        NSDictionary *launchOptions = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving};
        MKMapItem *currentLocationMapItem = [MKMapItem mapItemForCurrentLocation];
        [MKMapItem openMapsWithItems:@[currentLocationMapItem, mapItem] launchOptions:launchOptions];
    }
    else if(buttonIndex == 1)
    {
        if([self showPositionAlert])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"请在系统设置中打开“定位服务”来允许“出发吧”确定您的位置"
                                                           delegate:nil
                                                  cancelButtonTitle:@"知道了"
                                                  otherButtonTitles:nil];
            [alert show];
            return;
        }
        NSString* url = [NSString stringWithFormat: @"comgooglemaps://?saddr=%f,%f&daddr=%f,%f&directionsmode=transit", mapView.userLocation.coordinate.latitude, mapView.userLocation.coordinate.longitude, annotation.coordinate.latitude, annotation.coordinate.longitude];
        [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
