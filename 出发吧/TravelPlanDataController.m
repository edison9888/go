//
//  TravelPlanDataController.m
//  出发吧
//
//  Created by kenzo on 13-1-16.
//  Copyright (c) 2013年 出发吧APP团队. All rights reserved.
//

#import "TravelPlanDataController.h"
#import "TravelPlan.h"

@interface TravelPlanDataController ()
- (void)initializeDefaultDataList;
@end

@implementation TravelPlanDataController

- (void)initializeDefaultDataList {
    NSMutableArray *planList = [[NSMutableArray alloc] init];
    self.masterTravelPlanList = planList;
    TravelPlan *plan;
    NSDate *today = [NSDate date];
    UIImage *image = [UIImage imageNamed:@"travel.png"];
    plan = [[TravelPlan alloc] initWithName:@"英伦自由行" duration:[NSNumber numberWithInt:5] date:today image:image];
    [self addTravelPlanWithPlan:plan];
}

- (void)setMasterTravelPlanList:(NSMutableArray *)newList {
    if (_masterTravelPlanList != newList) {
        _masterTravelPlanList = [newList mutableCopy];
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
    return [self.masterTravelPlanList count];
}

- (TravelPlan *)objectInListAtIndex:(NSUInteger)theIndex {
    return [self.masterTravelPlanList objectAtIndex:theIndex];
}

- (void)addTravelPlanWithPlan:(TravelPlan *)plan {
    [self.masterTravelPlanList addObject:plan];
}

@end
