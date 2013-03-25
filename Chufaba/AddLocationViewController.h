//
//  AddLocationViewController.h
//  Chufaba
//
//  Created by 张辛欣 on 13-2-28.
//  Copyright (c) 2013年 ChufabaAPP团队. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Location.h"
#import "LocationAnnotation.h"
#import "JsonFetcher.h"

@class AddLocationViewController;

@protocol AddLocationViewControllerDelegate <NSObject>
@optional
-(void) AddLocationViewController:(AddLocationViewController *) addLocationViewController didFinishEdit:(Location *) location name:(BOOL)nameChanged coordinate:(BOOL) coordinateChanged;
-(void) AddLocationViewController:(AddLocationViewController *) addLocationViewController didFinishAdd:(Location *) location;

@end

@interface AddLocationViewController : UIViewController <MKMapViewDelegate, UIActionSheetDelegate, UITextFieldDelegate, UISearchBarDelegate>

@property (nonatomic, copy) NSNumber *lastLatitude;
@property (nonatomic, copy) NSNumber *lastLongitude;

@property (nonatomic, assign) BOOL hasCoordinate;
@property (nonatomic, assign) BOOL addLocation;

@property (nonatomic, strong) NSArray *annotations;

@property (nonatomic, strong) Location *location;

@property (nonatomic,strong) MKMapView *mapView;

@property (nonatomic,weak) id<AddLocationViewControllerDelegate> editLocationDelegate;

@end
