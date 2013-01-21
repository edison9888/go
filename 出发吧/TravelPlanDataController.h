//
//  TravelPlanDataController.h
//  出发吧
//
//  Created by kenzo on 13-1-16.
//  Copyright (c) 2013年 出发吧APP团队. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TravelPlan;

@interface TravelPlanDataController : NSObject

@property (nonatomic, copy) NSMutableArray *masterTravelPlanList;

- (NSUInteger)countOfList;
- (TravelPlan *)objectInListAtIndex:(NSUInteger)theIndex;
- (void)addTravelPlanWithPlan:(TravelPlan *)plan;

@end
