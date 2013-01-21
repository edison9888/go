//
//  SearchLocation.m
//  出发吧
//
//  Created by 张 辛欣 on 13-1-20.
//  Copyright (c) 2013年 出发吧APP团队. All rights reserved.
//

#import "SearchLocation.h"

@implementation SearchLocation

-(id)initWithName:(NSString *)name address:(NSString *)address
{
    self = [super init];
    if (self) {
        _name = name;
        _address = address;
        return self;
    }
    return nil;
}

@end
