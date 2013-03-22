//
//  FMDBDataAccess.m
//  出发吧
//
//  Created by 张 辛欣 on 13-1-24.
//  Copyright (c) 2013年 出发吧APP团队. All rights reserved.
//

#import "FMDBDataAccess.h"

@implementation FMDBDataAccess


-(BOOL) updateTravelPlan:(Plan *)plan
{
    FMDatabase *db = [FMDatabase databaseWithPath:[Utility getDatabasePath]];
    [db open];
    double temp = [plan.date timeIntervalSince1970];
    NSNumber *dateToWriteDB = [NSNumber numberWithDouble:temp];
    BOOL success = [db executeUpdate:@"UPDATE plan SET title = ?, startdate = ?, duration = ? WHERE id = ?",plan.name, dateToWriteDB, plan.duration, plan.planId];    
    [db close];
    return success;
}

-(BOOL) insertTravelPlan:(Plan *)plan
{
    FMDatabase *db = [FMDatabase databaseWithPath:[Utility getDatabasePath]];
    [db open];
    double temp = [plan.date timeIntervalSince1970];
    NSNumber *dateToWriteDB = [NSNumber numberWithDouble:temp];
    BOOL success =  [db executeUpdate:@"INSERT INTO plan (title,startdate,duration) VALUES (?,?,?);",plan.name,dateToWriteDB,plan.duration,nil];    
    [db close];
    return success;
}

-(BOOL) deleteTravelPlan:(Plan *)plan
{
    FMDatabase *db = [FMDatabase databaseWithPath:[Utility getDatabasePath]];    
    [db open];    
    BOOL success =  [db executeUpdate:@"DELETE FROM plan WHERE id = ?", plan.planId];
    [db executeUpdate:@"DELETE FROM location WHERE plan_id = ?", plan.planId];   
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
        Plan *plan = [[Plan alloc] init];
        plan.planId = [NSNumber numberWithInt:[results intForColumn:@"id"]];
        plan.date = [results dateForColumn:@"startdate"];
        plan.duration = [NSNumber numberWithInt:[results intForColumn:@"duration"]];
        plan.image = [UIImage imageNamed:@"photo_add.png"];
        plan.name = [results stringForColumn:@"title"];
        
        FMResultSet *locationResults = [db executeQuery:@"SELECT count(*) as 'count' FROM location WHERE plan_id = ?",plan.planId];
        if([locationResults next])
            plan.locationCount = [locationResults intForColumn:@"count"];
        
        [travelPlans addObject:plan];
    }    
    travelPlans = [[[travelPlans reverseObjectEnumerator] allObjects] mutableCopy];
    [db close];
    return travelPlans;    
}

-(BOOL) userExist:(NSString *) service_uid logintype:(NSInteger) type
{
    BOOL flag = NO;
    
    FMDatabase *db = [FMDatabase databaseWithPath:[Utility getDatabasePath]];    
    [db open];
    
    if (type == 1) {
        //if([db stringForQuery:@"SELECT weibo_uid FROM user WHERE weibo_uid = ?", service_uid] != @"")
        FMResultSet *results = [db executeQuery:@"SELECT weibo_uid FROM user WHERE weibo_uid = ?", service_uid];
        if ([results next])
            flag = YES;
    }
    else if(type == 2)
    {
        FMResultSet *results = [db executeQuery:@"SELECT weibo_uid FROM user WHERE qq_uid = ?", service_uid];
        if ([results next])
            flag = YES;
    }
    else
    {
        FMResultSet *results = [db executeQuery:@"SELECT weibo_uid FROM user WHERE douban_uid = ?", service_uid];
        if ([results next])
            flag = YES;
    }
    
    [db close];
    return flag;
}

-(BOOL) createUser:(NSString *) service_uid accesstoken:(NSString *)token mainAccountType:(NSInteger) type
{
    BOOL success;
    FMDatabase *db = [FMDatabase databaseWithPath:[Utility getDatabasePath]];
    [db open];
    
    double temp = [[NSDate date] timeIntervalSince1970];
    NSNumber *dateToWriteDB = [NSNumber numberWithDouble:temp];
    
    NSNumber *typeToInsert = [NSNumber numberWithInt:type];
    
    if (type == 1)
    {
        success =  [db executeUpdate:@"INSERT INTO user (weibo_uid,weibo_token,register_time,main_account) VALUES (?,?,?,?);",service_uid,token,dateToWriteDB,typeToInsert,nil];
    }
    else if(type == 2)
    {
        success =  [db executeUpdate:@"INSERT INTO user (qq_uid,qq_token,register_time,main_account) VALUES (?,?,?,?);",service_uid,token,dateToWriteDB,typeToInsert,nil];
    }
    else
    {
        success =  [db executeUpdate:@"INSERT INTO user (douban_uid,douban_token,register_time,main_account) VALUES (?,?,?,?);",service_uid,token,dateToWriteDB,typeToInsert,nil];
    }
    
    [db close];
    return success;
}

//-(BOOL) unbindWeibo:(NSNumber *)weibo_id
//{
//    BOOL success;
//    FMDatabase *db = [FMDatabase databaseWithPath:[Utility getDatabasePath]];
//    [db open];
//    
//    success = [db executeUpdate:@"UPDATE user SET weibo_token = '' WHERE weibo_id = ?", weibo_id];
//    
//    [db close];
//    return success;
//}

@end

