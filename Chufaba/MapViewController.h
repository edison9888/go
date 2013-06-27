//
//  MapViewController.h
//  Chufaba
//
//  Created by 张辛欣 on 13-6-22.
//  Copyright (c) 2013年 ChufabaAPP团队. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "NIDropDown.h"
#import "LocationViewController.h"

@class Plan;

@protocol MapViewControllerDelegate <NSObject>

@optional
-(void) didChangeLocationFromMap:(Location *)location;
-(void) notifyItinerayRoloadToThisDay:(NSUInteger)day AndMode:(Boolean)singleDayMode;

@end

@interface MapViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, NIDropDownDelegate, UIGestureRecognizerDelegate, AddLocationDelegate>

@property (nonatomic,strong) MKMapView *mapView;

@property (nonatomic, strong) NSDictionary *categoryImage;

@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) CLLocation *curLocation;

@property (strong, nonatomic) Plan *plan;
@property NSUInteger daySelected;
@property Boolean singleDayMode;

@property (nonatomic,weak) id<MapViewControllerDelegate> delegate;

@end
