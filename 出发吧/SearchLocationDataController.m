//
//  SearchLocationDataController.m
//  出发吧
//
//  Created by 张 辛欣 on 13-1-20.
//  Copyright (c) 2013年 出发吧APP团队. All rights reserved.
//

#import "SearchLocationDataController.h"
#import "SearchLocation.h"

@interface SearchLocationDataController ()
- (void)initializeDefaultDataList;
@end

@implementation SearchLocationDataController

-(void)initializeDefaultDataList
{
    NSMutableArray *locationList = [[NSMutableArray alloc] init];
    self.searchLocationList = locationList;
    SearchLocation *location1 = [[SearchLocation alloc] initWithName:@"London Tower" address:@"London tower road 333"];
    [self addSearchLocationWithLocation:location1];
    SearchLocation *location2 = [[SearchLocation alloc] initWithName:@"Windsor Carsle" address:@"Windsor road 333"];
    [self addSearchLocationWithLocation:location2];
}

- (void)setSearchLocationList:(NSMutableArray *)newList {
    if (_searchLocationList != newList) {
        _searchLocationList = [newList mutableCopy];
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
    return [self.searchLocationList count];
}

- (SearchLocation *)objectInListAtIndex:(NSUInteger)theIndex {
    return [self.searchLocationList objectAtIndex:theIndex];
}

- (void)addSearchLocationWithLocation:(SearchLocation *)location
{
    [self.searchLocationList addObject:location];
}

@end
