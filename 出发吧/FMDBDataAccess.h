//
//  FMDBDataAccess.h
//  出发吧
//
//  Created by 张 辛欣 on 13-1-24.
//  Copyright (c) 2013年 出发吧APP团队. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "FMResultSet.h"
#import "Utility.h"
#import "TravelPlan.h"
#import "TravelLocation.h"

@interface FMDBDataAccess : NSObject
{
    
}

-(NSMutableArray *) getTravelPlans;
-(BOOL) insertTravelPlan:(TravelPlan *) plan;
-(BOOL) deleteTravelPlan:(TravelPlan *) plan;
-(BOOL) updateTravelPlan:(TravelPlan *) plan;

@end
