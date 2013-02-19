//
//  LocationAnnotation.h
//  Chufaba
//
//  Created by 张辛欣 on 13-2-2.
//  Copyright (c) 2013年 ChufabaAPP团队. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "Location.h"

@interface LocationAnnotation : NSObject <MKAnnotation>

+ (LocationAnnotation *)annotationForLocation:(Location *)location ShowTitle:(Boolean *)showTitle;

@property (nonatomic, strong) Location *location;
@property (nonatomic) Boolean *showTitle;

@end
