//
//  FMDBDataAccess.h
//  出发吧
//
//  Created by 张 辛欣 on 13-1-24.
//  Copyright (c) 2013年 出发吧APP团队. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "FMResultSet.h"
#import "Utility.h"
#import "Plan.h"

@interface FMDBDataAccess : NSObject
{
    
}

-(NSMutableArray *) getTravelPlans;
-(BOOL) insertTravelPlan:(Plan *) plan;
-(BOOL) deleteTravelPlan:(Plan *) plan;
-(BOOL) updateTravelPlan:(Plan *) plan;

-(BOOL) userExist:(NSString *) service_uid logintype:(NSInteger) type;
-(BOOL) createUser:(NSString *) service_uid accesstoken:(NSString *)token mainAccountType:(NSInteger) type;

@end
