//
//  LocationAnnotation.m
//  Chufaba
//
//  Created by 张辛欣 on 13-2-2.
//  Copyright (c) 2013年 ChufabaAPP团队. All rights reserved.
//

#import "LocationAnnotation.h"

@implementation LocationAnnotation

+ (LocationAnnotation *)annotationForLocation:(Location *)location ShowTitle:(BOOL)showTitle
{
    LocationAnnotation *annotation = [[LocationAnnotation alloc] init];
    annotation.location = location;
    annotation.showTitle = showTitle;
    return annotation;
}

- (NSString *)title
{
    return self.showTitle ? self.location.name : nil;    
}

//- (NSString *)subtitle
//{
//    return self.showTitle ? self.location.category : nil;
//}

- (CLLocationCoordinate2D)coordinate
{
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [self.location.latitude doubleValue];
    coordinate.longitude = [self.location.longitude doubleValue];
    return coordinate;
}

@end
