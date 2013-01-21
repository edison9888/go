//
//  TravelLocation.h
//  出发吧
//
//  Created by kenzo on 13-1-16.
//  Copyright (c) 2013年 出发吧APP团队. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TravelLocation : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *transportation;
@property (nonatomic, copy) NSString *cost;
@property (nonatomic, copy) NSString *schedule;
@property (nonatomic, copy) NSString *detail;
//@property (nonatomic, strong) NSDate *date;

-(id)initWithName:(NSString *)name address:(NSString *)address transportation:(NSString *)transportation cost:(NSString *)cost schedule:(NSString *)schedule detail:(NSString *)detail;

@end
