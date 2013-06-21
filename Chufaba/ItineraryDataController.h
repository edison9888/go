//
//  itineraryDataController.h
//  出发吧
//
//  Created by kenzo on 13-1-16.
//  Copyright (c) 2013年 出发吧APP团队. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Plan;

@interface ItineraryDataController : NSObject

@property (nonatomic, strong) NSDate *date;
@property (nonatomic,weak) NSNumber *itineraryDuration;
@property (nonatomic, copy) NSMutableArray *masterTravelDayList;
@property (nonatomic,strong) Plan *plan;
@property (nonatomic, assign) NSInteger locationCount;
@property (nonatomic, readonly) NSNumber *planId;

- (id)initWithPlanId:(NSNumber *)planId;
- (NSUInteger)countOfList;
- (NSMutableArray *)objectInListAtIndex:(NSUInteger)theIndex;

- (void) updatePois;

-(NSMutableArray *)encode;
-(void)decode:(NSMutableArray *)itineraryData;

@end
