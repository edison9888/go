//
//  itineraryDataController.h
//  出发吧
//
//  Created by kenzo on 13-1-16.
//  Copyright (c) 2013年 出发吧APP团队. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TravelLocation.h"
//@class TravelLocation;

@interface itineraryDataController : NSObject

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, copy) NSMutableArray *masterTravelDayList;

- (NSUInteger)countOfList;
- (NSMutableArray *)objectInListAtIndex:(NSUInteger)theIndex;

@end
