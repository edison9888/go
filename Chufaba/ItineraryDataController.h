//
//  itineraryDataController.h
//  出发吧
//
//  Created by kenzo on 13-1-16.
//  Copyright (c) 2013年 出发吧APP团队. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Location.h"
//@class TravelLocation;

@interface ItineraryDataController : NSObject

@property (nonatomic, strong) NSDate *date;
@property (nonatomic,weak) NSNumber *itineraryDuration;
@property (nonatomic, copy) NSMutableArray *masterTravelDayList;

- (NSUInteger)countOfList;
- (NSMutableArray *)objectInListAtIndex:(NSUInteger)theIndex;

@end
