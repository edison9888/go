//
//  SearchLocation.h
//  出发吧
//
//  Created by 张 辛欣 on 13-1-20.
//  Copyright (c) 2013年 出发吧APP团队. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SearchLocation : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *address;

-(id)initWithName:(NSString *)name address:(NSString *)address;

@end
