//
//  TravelLocation.h
//  出发吧
//
//  Created by kenzo on 13-1-16.
//  Copyright (c) 2013年 出发吧APP团队. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Location : NSObject

@property (nonatomic, copy) NSNumber *locationId;
@property (nonatomic, copy) NSNumber *planId;
@property (nonatomic, copy) NSNumber *whichday;
@property (nonatomic, copy) NSNumber *seqofday;

//server
@property (nonatomic, copy) NSNumber *poiId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *nameEn;
@property (nonatomic, copy) NSString *country;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *category;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSNumber *latitude;
@property (nonatomic, copy) NSNumber *longitude;
@property (nonatomic, copy) NSString *transportation;
@property (nonatomic, copy) NSString *opening;
@property (nonatomic, copy) NSString *fee;
@property (nonatomic, copy) NSString *website;

//user
@property (nonatomic, strong) NSString *visitBegin;
@property (nonatomic, copy) NSString *detail;

//hide
@property (nonatomic, copy) NSNumber *cost;
@property (nonatomic, copy) NSString *currency;

@property (nonatomic) BOOL useradd; 

+ (NSString *)getLocationCategoryByJiepangCategoryId:(NSString *)category;

- (BOOL)hasCoordinate;
- (NSString *)getTitle;
- (NSString *)getTitleWithCity;
- (NSString *)getSubtitle;

- (NSUInteger)numberOfSections;
- (NSUInteger)numberOfRowsInInfoSection;
- (NSString *)contentForRow:(NSInteger)row;
- (NSString *)imageNameForRow:(NSInteger)row;

- (void)setPoiData:(NSDictionary *)poi;
- (void)updatePoiData:(NSDictionary *)poi;
- (Boolean)save;
+ (NSMutableArray *)findAllByPlanId:(NSNumber *)planId;
+ (Boolean)deleteLocationsOfPlan:(NSNumber *)planId AfterDay:(NSNumber *)day;
+ (Boolean)deleteLocationsOfPlan:(NSNumber *)planId;
+ (int)countOfPlan:(NSNumber *)planId;

-(NSDictionary *)encode;
-(void)decode:(NSDictionary *)locationData;

@end