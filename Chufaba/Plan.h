//
//  TravelPlan.h
//  出发吧
//
//  Created by kenzo on 13-1-16.
//  Copyright (c) 2013年 出发吧APP团队. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Plan : NSObject

@property (nonatomic, copy) NSNumber *planId;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSNumber *duration;
@property (nonatomic) UIImage *image;

@property (nonatomic, copy) NSMutableArray *itineraryList;

-(id)initWithName:(NSString *)name duration:(NSNumber *)duration date:(NSDate *)date image:(UIImage *)image;
//-(id)initWithName:(NSString *)name duration:(NSString *)duration date:(NSDate *)date;

@end
