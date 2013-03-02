//
//  AddLocationViewController.h
//  Chufaba
//
//  Created by 张辛欣 on 13-2-28.
//  Copyright (c) 2013年 ChufabaAPP团队. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "SelectCategoryViewController.h"

@interface AddLocationViewController : UIViewController <MKMapViewDelegate, UIActionSheetDelegate>

@property (copy, nonatomic) NSString *addLocationName;
@property (nonatomic, copy) NSNumber *lastLatitude;
@property (nonatomic, copy) NSNumber *lastLongitude;

@property (nonatomic,strong) MKMapView *mapView;

@property (nonatomic,weak) id<SelectCategoryViewControllerDelegate> delegate;

@end
