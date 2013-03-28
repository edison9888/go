//
//  LocationMapViewController.h
//  Chufaba
//
//  Created by Perry on 13-2-21.
//  Copyright (c) 2013年 ChufabaAPP团队. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Location.h"
#import "LocationAnnotation.h"

@interface LocationMapViewController : UIViewController<MKMapViewDelegate>

@property (strong, nonatomic) Location *location;
@property int index;
@property (nonatomic, assign) BOOL normalMapMode;

@end
