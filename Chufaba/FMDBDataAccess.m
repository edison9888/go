//
//  FMDBDataAccess.m
//  出发吧
//
//  Created by 张 辛欣 on 13-1-24.
//  Copyright (c) 2013年 出发吧APP团队. All rights reserved.
//

#import "FMDBDataAccess.h"

@implementation FMDBDataAccess


-(BOOL) updateTravelPlan:(TravelPlan *)plan
{
    FMDatabase *db = [FMDatabase databaseWithPath:[Utility getDatabasePath]];
    [db open];
    double temp = [plan.date timeIntervalSince1970];
    NSNumber *dateToWriteDB = [NSNumber numberWithDouble:temp];
    BOOL success = [db executeUpdate:@"UPDATE plan SET title = ?, startdate = ?, duration = ? WHERE id = ?",plan.name, dateToWriteDB, plan.duration, plan.planId];    
    [db close];
    return success;
}

-(BOOL) insertTravelPlan:(TravelPlan *)plan
{
    FMDatabase *db = [FMDatabase databaseWithPath:[Utility getDatabasePath]];
    [db open];
    double temp = [plan.date timeIntervalSince1970];
    NSNumber *dateToWriteDB = [NSNumber numberWithDouble:temp];
    BOOL success =  [db executeUpdate:@"INSERT INTO plan (title,startdate,duration) VALUES (?,?,?);",plan.name,dateToWriteDB,plan.duration,nil];    
    [db close];
    return success;
}

-(BOOL) deleteTravelPlan:(TravelPlan *)plan
{
    FMDatabase *db = [FMDatabase databaseWithPath:[Utility getDatabasePath]];    
    [db open];    
    BOOL success =  [db executeUpdate:@"DELETE FROM plan WHERE id = ?", plan.planId];    
    [db close];
    return success;
}

-(NSMutableArray *) getTravelPlans
{
    NSMutableArray *travelPlans = [[NSMutableArray alloc] init];
    FMDatabase *db = [FMDatabase databaseWithPath:[Utility getDatabasePath]];
    
    [db open];    
    FMResultSet *results = [db executeQuery:@"SELECT * FROM plan"];    
    while([results next])
    {
        TravelPlan *plan = [[TravelPlan alloc] init];
        plan.planId = [NSNumber numberWithInt:[results intForColumn:@"id"]];
        plan.date = [results dateForColumn:@"startdate"];
        plan.duration = [NSNumber numberWithInt:[results intForColumn:@"duration"]];
        plan.image = [UIImage imageNamed:@"photo_add.png"];
        plan.name = [results stringForColumn:@"title"];        
        [travelPlans addObject:plan];
    }    
    travelPlans = [[[travelPlans reverseObjectEnumerator] allObjects] mutableCopy];
    [db close];
    return travelPlans;    
}

@end

