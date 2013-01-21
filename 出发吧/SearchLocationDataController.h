//
//  SearchLocationDataController.h
//  出发吧
//
//  Created by 张 辛欣 on 13-1-20.
//  Copyright (c) 2013年 出发吧APP团队. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SearchLocation;

@interface SearchLocationDataController : NSObject

@property (nonatomic, copy) NSMutableArray *searchLocationList;

- (NSUInteger)countOfList;
- (SearchLocation *)objectInListAtIndex:(NSUInteger)theIndex;
- (void)addSearchLocationWithLocation:(SearchLocation *)location;

@end
