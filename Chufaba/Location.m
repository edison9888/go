//
//  TravelLocation.m
//  出发吧
//
//  Created by kenzo on 13-1-16.
//  Copyright (c) 2013年 出发吧APP团队. All rights reserved.
//

#import "Location.h"

@implementation Location

+ (NSString *)getLocationCategoryByJiepangCategoryId:(NSString *)category
{
    NSString *prefix = [category substringToIndex:2];
    if ([prefix isEqualToString:@"01"]) {
        return @"美食";
    }
    if ([prefix isEqualToString:@"03"]) {
        if ([category isEqualToString:@"0312"] || [category isEqualToString:@"0313"] || [category isEqualToString:@"0314"] || [category isEqualToString:@"0315"] || [category
                                                                                                                                                                     isEqualToString:@"0316"]) {
            return @"住宿";
        } else {
            return @"交通";
        }
    }
    if ([prefix isEqualToString:@"04"]) {
        return @"娱乐";
    }
    if ([prefix isEqualToString:@"05"]) {
        return @"景点";
    }
    return @"其它";
}

+ (UIImage *)getCategoryIcon:(NSString *)category
{
    if ([category isEqualToString:@"景点"]) {
        return [UIImage imageNamed:@"scene.jpg"];
    } else if([category isEqualToString:@"美食"]) {
        return [UIImage imageNamed:@"food.gif"];
    } else if([category isEqualToString:@"住宿"]) {
        return [UIImage imageNamed:@"hotel.gif"];
    } else if([category isEqualToString:@"交通"]) {
        return [UIImage imageNamed:@"transport.gif"];
    } else if([category isEqualToString:@"娱乐"]) {
        return [UIImage imageNamed:@"entertainment.gif"];
    } else {
        return [UIImage imageNamed:@"other.gif"];
    }
}

- (NSString *)getNameAndCity
{
    return [self.city length] > 0 ? [NSString stringWithFormat:@"%@, %@", self.name, self.city] : self.name;
}

- (NSString *)name
{
    return [_name length] > 0 ? _name : _nameEn;
}

- (NSString *)nameEn
{
    return [_name length] > 0 ? _nameEn : @"";
}

- (NSString *)getRealName
{
    return _name;
}

- (NSString *)getRealNameEn
{
    return _nameEn;
}

@end
