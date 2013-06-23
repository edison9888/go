//
//  TravelPlan.h
//  出发吧
//
//  Created by kenzo on 13-1-16.
//  Copyright (c) 2013年 出发吧APP团队. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ItineraryDataController;

@interface Plan : NSObject

@property (nonatomic, copy) NSNumber *planId;
@property (nonatomic, copy) NSString *destination;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, copy) NSNumber *duration;
@property (nonatomic, copy) NSNumber *uid;
@property (readonly) Boolean changedSinceLastSync;
@property (nonatomic, readonly) NSNumber *serverId;
@property (nonatomic, readonly) NSString *version;
@property (readonly) int locationCount;
@property (nonatomic, readonly, strong) NSMutableArray *itinerary;

+(NSMutableArray *)findAll;
+(NSMutableArray *)findAllByUid:(NSNumber *)uid;

-(Boolean)save;

-(Boolean)destroy;

-(NSString *)encode;
-(void)decode:(NSString *)planData;

-(UIImage *)getCover;
-(void)setCover:(UIImage *)image;

-(void)loadItinerary;

-(void)sync;

-(Boolean)newPlan;


@end