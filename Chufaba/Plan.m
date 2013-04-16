//
//  TravelPlan.m
//  出发吧
//
//  Created by kenzo on 13-1-16.
//  Copyright (c) 2013年 出发吧APP团队. All rights reserved.
//

#import "Plan.h"
#import "Location.h"

@implementation Plan

-(id)initWithName:(NSString *)name destination:(NSString *)destination duration:(NSNumber *)duration date:(NSDate *)date image:(UIImage *)image
{
    self = [super init];
    if (self) {
        _name = name;
        _destination = destination;
        _duration = duration;
        _date = date;
        _image = image;
        
        _itineraryList = [[NSMutableArray alloc] init];
        
        return self;
    }
    return nil;
}

@end
