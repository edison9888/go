//
//  AddLocationViewController.h
//  Chufaba
//
//  Created by 张辛欣 on 13-2-28.
//  Copyright (c) 2013年 ChufabaAPP团队. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface AddLocationViewController : UIViewController <MKMapViewDelegate>

@property (copy, nonatomic) NSString *addLocationName;
@property (nonatomic, copy) NSNumber *lastLatitude;
@property (nonatomic, copy) NSNumber *lastLongitude;

@end
