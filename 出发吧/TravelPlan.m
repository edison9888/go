//
//  TravelPlan.m
//  出发吧
//
//  Created by kenzo on 13-1-16.
//  Copyright (c) 2013年 出发吧APP团队. All rights reserved.
//

#import "TravelPlan.h"
#import "TravelLocation.h"

@implementation TravelPlan

-(id)initWithName:(NSString *)name duration:(NSNumber *)duration date:(NSDate *)date image:(UIImage *)image
{
    self = [super init];
    if (self) {
        _name = name;
        _duration = duration;
        _date = date;
        _image = image;
        
        //initialize the itinerary list based on the duration value
        _itineraryList = [[NSMutableArray alloc] init];
//        for (int i = 0; i < [duration intValue]; i++) {
//            NSMutableArray *dayList = [[NSMutableArray alloc] init];
//            TravelLocation *location = [[TravelLocation alloc] initWithName:@"白金汉宫" address:@"Buckingham Palace Road, London SWL098" transportation:@"地铁Green Park站" cost:@"门票17磅" schedule:@"游览3小时" detail:@"10月3日又换岗仪式"];
//            [dayList addObject:location];
//            [dayList addObject:location];
//            [_itineraryList addObject:dayList];
//        }
        
        return self;
    }
    return nil;
}

/*-(id)initWithName:(NSString *)name duration:(NSString *)duration date:(NSDate *)date
{
    self = [super init];
    if (self) {
        _name = name;
        _duration =duration;
        _date = date;
        return self;
    }
    return nil;
}*/

@end
