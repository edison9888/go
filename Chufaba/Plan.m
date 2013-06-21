//
//  TravelPlan.m
//  出发吧
//
//  Created by kenzo on 13-1-16.
//  Copyright (c) 2013年 出发吧APP团队. All rights reserved.
//

#import "Plan.h"
#import "ItineraryDataController.h"
#import "Utility.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "FMResultSet.h"

@implementation Plan

-(id)initWithName:(NSString *)name destination:(NSString *)destination duration:(NSNumber *)duration date:(NSDate *)date image:(UIImage *)image
{
    self = [super init];
    if (self) {
        _name = name;
        _destination = destination;
        _duration = duration;
        _date = date;
        _image = image;
        
        _itineraryList = [[NSMutableArray alloc] init];
        
        return self;
    }
    return nil;
}

-(NSString *)getCoverName
{
    return [[_planId stringValue] stringByAppendingString:@"planCover.png"];
}

-(Boolean)hasCover
{ 
    return [Utility fileExists:[self getCoverName]];
}

-(UIImage *)getCover
{
    return [UIImage imageWithContentsOfFile:[Utility getFullPath:[self getCoverName]]];
}

+(NSMutableArray *)findAllByUid:(NSNumber *)uid
{
    NSMutableArray *plans = [[NSMutableArray alloc] init];
    FMDatabase *db = [FMDatabase databaseWithPath:[Utility getDatabasePath]];
    [db open];
    FMResultSet *results = [db executeQuery:@"SELECT * FROM plan limit 1"];
    //FMResultSet *results = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM plan where uid = %d", uid.intValue]];
    while([results next])
    {
        Plan *plan = [[Plan alloc] init];
        plan.uid = [NSNumber numberWithInt:[results intForColumn:@"uid"]];
        plan.planId = [NSNumber numberWithInt:[results intForColumn:@"id"]];
        plan.date = [results dateForColumn:@"startdate"];
        plan.duration = [NSNumber numberWithInt:[results intForColumn:@"duration"]];
        plan.image = [UIImage imageNamed:@"photo_add.png"];
        plan.name = [results stringForColumn:@"title"];
        plan.destination = [results stringForColumn:@"destination"];
        plan.itinerary = [[ItineraryDataController alloc] initWithPlanId:plan.planId];
        
        [plans addObject:plan];
    }
    [db close];
    return plans;
}

-(NSString *)encode
{
    NSData *imageData = nil;
    if ([self hasCover]) {
        imageData = UIImagePNGRepresentation([self getCover]);
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:
        _uid, @"uid",
        _planId, @"id",
        _name, @"name",
        _destination, @"destination",
        _duration, @"duration",
        [formatter stringFromDate:_date], @"date",
        _duration, @"duration",
        [_itinerary encode], @"itinerary",
        [imageData base64EncodedString], @"image",
            nil];
    NSError *error;
    NSData *encodeData = [NSJSONSerialization dataWithJSONObject:data options:nil error:&error];
    if (error == nil) {
        return [[NSString alloc] initWithData:encodeData encoding:NSUTF8StringEncoding];
    }else{
        NSLog(@"error: %@", [error localizedDescription]);
        return nil;
    }
}

-(void)decode:(NSString *)planData
{
}

@end
