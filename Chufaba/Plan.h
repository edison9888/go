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
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *destination;
@property (nonatomic, copy) NSNumber *duration;
@property (nonatomic) UIImage *image;
@property (nonatomic, assign) NSInteger locationCount;
@property (nonatomic, copy) NSMutableArray *itineraryList;
@property (nonatomic, strong) ItineraryDataController *itinerary;
@property (nonatomic, copy) NSNumber *uid;

-(id)initWithName:(NSString *)name destination:(NSString *)destination duration:(NSNumber *)duration date:(NSDate *)date image:(UIImage *)image;

+(NSMutableArray *)findAllByUid:(NSNumber *)uid;

-(NSString *)encode;
-(void)decode:(NSString *)planData;

-(Boolean)hasCover;
-(UIImage *)getCover;


@end