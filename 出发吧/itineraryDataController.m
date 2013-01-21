//
//  itineraryDataController.m
//  出发吧
//
//  Created by kenzo on 13-1-16.
//  Copyright (c) 2013年 出发吧APP团队. All rights reserved.
//

#import "itineraryDataController.h"
#import "TravelLocation.h"

@interface itineraryDataController ()
- (void)initializeDefaultDataList;
@end

@implementation itineraryDataController

- (void)initializeDefaultDataList {
    /*NSMutableArray *dayList = [[NSMutableArray alloc] init];
    self.masterTravelDayList = dayList;
    
    TravelLocation *location;
    location = [[TravelLocation alloc] initWithName:@"白金汉宫" address:@"Buckingham Palace Road, London SWL098" transportation:@"地铁Green Park站" cost:@"门票17磅" schedule:@"游览3小时" detail:@"10月3日又换岗仪式"];
    
    NSMutableArray *locationListPerDay = [NSMutableArray arrayWithObjects:location,location,nil];

    [self addTravelDayListWithList:locationListPerDay];
    [self addTravelDayListWithList:locationListPerDay];*/
}

- (void)setMasterTravelDayList:(NSMutableArray *)newList {
    if (_masterTravelDayList != newList) {
        _masterTravelDayList = [newList mutableCopy];
    }
}

- (id)init {
    if (self = [super init]) {
        [self initializeDefaultDataList];
        return self;
    }
    return nil;
}

- (NSUInteger)countOfList {
    return [self.masterTravelDayList count];
}

- (NSMutableArray *)objectInListAtIndex:(NSUInteger)theIndex {
    return [self.masterTravelDayList objectAtIndex:theIndex];
}

- (void)addTravelDayListWithList:(NSMutableArray *)list {
    [self.masterTravelDayList addObject:list];
}

@end
