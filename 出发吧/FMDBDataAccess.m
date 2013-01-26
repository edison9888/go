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
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateToWriteDB = [dateFormatter stringFromDate:plan.date];
    dateFormatter = nil;
    
    BOOL success = [db executeUpdate:[NSString stringWithFormat:@"UPDATE plan SET title = '%@', startdate = '%@' where duration = %d",plan.name, dateToWriteDB, [plan.duration intValue]]];
    
    [db close];
    
    return success;
}

-(BOOL) insertTravelPlan:(TravelPlan *)plan
{
    FMDatabase *db = [FMDatabase databaseWithPath:[Utility getDatabasePath]];
    
    [db open];
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
//    NSString *dateToWriteDB = [dateFormatter stringFromDate:plan.date];
//    dateFormatter = nil;
    double temp = [plan.date timeIntervalSince1970];
    NSNumber *dateToWriteDB = [NSNumber numberWithDouble:temp];
    
    BOOL success =  [db executeUpdate:@"INSERT INTO plan (title,startdate,duration) VALUES (?,?,?);",
                     plan.name,dateToWriteDB,plan.duration,nil];
    
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
        //plan.itineraryList = [[NSMutableArray alloc] init];
        /*NSMutableArray *tempList = [[NSMutableArray alloc] init];

        for (int i = 0; i < [plan.duration intValue]; i++) {
            NSMutableArray *dayList = [[NSMutableArray alloc] init];
            TravelLocation *location = [[TravelLocation alloc] initWithName:@"白金汉宫" address:@"Buckingham Palace Road, London SWL098" transportation:@"地铁Green Park站" cost:@"门票17磅" schedule:@"游览3小时" detail:@"10月3日又换岗仪式"];
            [dayList addObject:location];
            [dayList addObject:location];
            [tempList addObject:dayList];
        }
        plan.itineraryList = tempList;*/
        
        [travelPlans addObject:plan];
        
    }
    
    travelPlans = [[[travelPlans reverseObjectEnumerator] allObjects] mutableCopy];
    
    [db close];
    
    return travelPlans;
    
}

@end

