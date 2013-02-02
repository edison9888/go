//
//  itineraryDataController.m
//  出发吧
//
//  Created by kenzo on 13-1-16.
//  Copyright (c) 2013年 出发吧APP团队. All rights reserved.
//

#import "ItineraryDataController.h"

@interface ItineraryDataController ()

@end

@implementation ItineraryDataController

- (void)setMasterTravelDayList:(NSMutableArray *)newList {
    if (_masterTravelDayList != newList) {
        _masterTravelDayList = [newList mutableCopy];
    }
}

- (id)init {
    if (self = [super init]) {
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
