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

@class AddLocationViewController;

@protocol AddLocationViewControllerDelegate <NSObject>
@optional
-(void) AddLocationViewController:(AddLocationViewController *) addLocationViewController didFinishEdit:(Location *) location name:(BOOL) nameChanged coordinate:(BOOL) coordinateChanged;
-(void) AddLocationViewController:(AddLocationViewController *) addLocationViewController didFinishAdd:(Location *) location;

@end

@interface AddLocationViewController : UIViewController <MKMapViewDelegate, UIActionSheetDelegate, UITextFieldDelegate>

@property (copy, nonatomic) NSString *addLocationName;
@property (nonatomic, copy) NSNumber *lastLatitude;
@property (nonatomic, copy) NSNumber *lastLongitude;
@property (nonatomic, copy) NSNumber *locationID;

@property (nonatomic,strong) MKMapView *mapView;

@property (nonatomic,weak) id<AddLocationViewControllerDelegate> editLocationDelegate;

@end
