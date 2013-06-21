//
//  User.m
//  Chufaba
//
//  Created by Perry on 13-6-19.
//  Copyright (c) 2013年 ChufabaAPP团队. All rights reserved.
//

#import "User.h"
#import "Plan.h"
#import "ItineraryDataController.h"

@implementation User

-(void)sync
{
    NSMutableArray *plans = [Plan findAllByUid:self.uid];
    for (Plan *plan in plans) {
        NSLog([plan encode]);
    }
}

@end
