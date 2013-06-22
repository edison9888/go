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

@protocol MapViewControllerDelegate <NSObject>

@optional
-(void) didChangeLocationFromMap:(Location *)location;
-(void) notifyItinerayRoloadToThisDay:(NSNumber *)day;

@end

@interface MapViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, NIDropDownDelegate, UIGestureRecognizerDelegate, AddLocationDelegate, NavigateLocationDelegate>

@property (nonatomic,strong) MKMapView *mapView;
@property (nonatomic, strong) NSArray *annotations; // of id <MKAnnotation>

@property (nonatomic, strong) NSDictionary *categoryImage;

@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) CLLocation *curLocation;

@property (strong, nonatomic) NSMutableArray *currentItineraryList;
@property (strong, nonatomic) NSMutableArray *itineraryListBackup;

@property (nonatomic,weak) NSNumber *daySelected;
@property (nonatomic, assign) NSInteger indexOfCurSelected;

@property (nonatomic, strong) NSNumber *itineraryDuration;

@property (nonatomic,weak) id<MapViewControllerDelegate> delegate;

@end
