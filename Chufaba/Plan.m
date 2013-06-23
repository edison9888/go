//
//  TravelPlan.m
//  出发吧
//
//  Created by kenzo on 13-1-16.
//  Copyright (c) 2013年 出发吧APP团队. All rights reserved.
//

#import "Plan.h"
#import "ItineraryDataController.h"
#import "Location.h"
#import "Utility.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "FMResultSet.h"
#import "Base64.h"

@interface Plan(){
    UIImage *cover;
    Boolean coverChanged;
}

@end

@implementation Plan

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)theKey {
    BOOL automatic = NO;
    if ([theKey isEqualToString:@"destination"] || [theKey isEqualToString:@"name"] || [theKey isEqualToString:@"date"] || [theKey isEqualToString:@"duration"]) {
        automatic = NO;
    }
    else {
        automatic = [super automaticallyNotifiesObserversForKey:theKey];
    }
    return automatic;
}

- (void)setName:(NSString *)name {
    if (name != _name) {
        [self willChangeValueForKey:@"name"];
        _name = name;
        _changedSinceLastSync = YES;
        [self didChangeValueForKey:@"name"];
    }
}

- (void)setDestination:(NSString *)destination {
    if (destination != _destination) {
        [self willChangeValueForKey:@"destination"];
        _destination = destination;
        _changedSinceLastSync = YES;
        [self didChangeValueForKey:@"destination"];
    }
}

- (void)setDate:(NSDate *)date {
    if (date != _date) {
        [self willChangeValueForKey:@"date"];
        _date = date;
        _changedSinceLastSync = YES;
        [self didChangeValueForKey:@"date"];
    }
}

- (void)setDuration:(NSNumber *)duration {
    if (duration != _duration) {
        [self willChangeValueForKey:@"duration"];
        if ([duration intValue] < [_duration intValue]) {
            [_itinerary removeObjectsInRange:NSMakeRange([duration intValue], [_duration intValue] - [duration intValue])];
            [Location deleteLocationsOfPlan:_planId AfterDay:duration];
            _locationCount = [Location countOfPlan:_planId];
        } else {
            int count = [duration intValue] - [_duration intValue];
            for (int i=0; i<count; i++) {
                [_itinerary addObject:[[NSMutableArray alloc] init]];
            }
        }
        _duration = duration;
        _changedSinceLastSync = YES;
        [self didChangeValueForKey:@"duration"];
    }
}

-(id)initWithResult:(FMResultSet *)result
{
    self = [super init];
    if (self) {
        _planId = [NSNumber numberWithInt:[result intForColumn:@"id"]];
        _uid = [NSNumber numberWithInt:[result intForColumn:@"uid"]];
        _name = [result stringForColumn:@"title"];
        _destination = [result stringForColumn:@"destination"];
        _date = [result dateForColumn:@"startdate"];
        _duration = [NSNumber numberWithInt:[result intForColumn:@"duration"]];
        _changedSinceLastSync = [result boolForColumn:@"changed"];
        _serverId = [NSNumber numberWithInt:[result intForColumn:@"server_id"]];
        _version = [result stringForColumn:@"version"];
        _locationCount = [Location countOfPlan:_planId];
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
    return ![self newPlan] && [Utility fileExists:[self getCoverName]];
}

-(UIImage *)getCover
{
    if (cover == nil) {
        if ([self hasCover]) {
            cover = [UIImage imageWithContentsOfFile:[Utility getFullPath:[self getCoverName]]];
        } else {
            cover = [UIImage imageNamed:@"plan_cover"];
        }
    }
    return cover;
}

-(void)setCover:(UIImage *)image
{
    NSData *old = UIImagePNGRepresentation([self getCover]);
    NSData *new = UIImagePNGRepresentation(image);
    if ([old isEqualToData:new]) {
        return;
    }
    cover = image;
    coverChanged = YES;
}

-(Boolean)newPlan
{
    return _planId == nil;
}

+(NSMutableArray *)findAll
{
    NSMutableArray *plans = [[NSMutableArray alloc] init];
    FMDatabase *db = [FMDatabase databaseWithPath:[Utility getDatabasePath]];
    [db open];
    FMResultSet *results = [db executeQuery:@"SELECT * FROM plan order by id desc"];
    while([results next])
    {
        Plan *plan = [[Plan alloc] initWithResult:results];
        [plans addObject:plan];
    }
    [db close];
    return plans;
}

+(NSMutableArray *)findAllByUid:(NSNumber *)uid
{
    NSMutableArray *plans = [[NSMutableArray alloc] init];
    FMDatabase *db = [FMDatabase databaseWithPath:[Utility getDatabasePath]];
    [db open];
    FMResultSet *results = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM plan where uid = %d order by id desc", uid.intValue]];
    while([results next])
    {
        Plan *plan = [[Plan alloc] initWithResult:results];
        [plans addObject:plan];
    }
    [db close];
    return plans;
}

-(Boolean)save
{
    NSNumber *startDate = [NSNumber numberWithDouble:[_date timeIntervalSince1970]];
    Boolean result = NO;
    if ([self newPlan]) {
        FMDatabase *db = [FMDatabase databaseWithPath:[Utility getDatabasePath]];
        [db open];
        result = [db executeUpdate:@"INSERT INTO plan (title,destination,startdate,duration,uid,changed) VALUES (?,?,?,?,?,?);",_name,_destination,startDate,_duration,_uid,[NSNumber numberWithBool:YES], nil];
        [db close];
        [self saveCover];
    } else {
        FMDatabase *db = [FMDatabase databaseWithPath:[Utility getDatabasePath]];
        [db open];
        result = [db executeUpdate:@"UPDATE plan set title = ?, destination = ?, startdate = ?, duration = ?, uid = ?, changed = ?, server_id = ?, version = ? WHERE id = ?",_name,_destination,[NSNumber numberWithDouble:[_date timeIntervalSince1970]],_duration,_uid,[NSNumber numberWithBool:_changedSinceLastSync], _serverId, _version, _planId];
        [db close];
        [self saveCover];
    }
    return result;
}

-(void)saveCover
{
    if (coverChanged) {
        NSData *imageData = UIImagePNGRepresentation([self getCover]);
        [Utility saveData:imageData ToFile:[self getCoverName]];
    }
}

-(Boolean)destroy
{
    FMDatabase *db = [FMDatabase databaseWithPath:[Utility getDatabasePath]];
    [db open];
    BOOL success =  [db executeUpdate:@"DELETE FROM plan WHERE id = ?", _planId];
    [db close];
    
    if (success) {
        [Location deleteLocationsOfPlan:_planId];
        [self removeCover];
    }
    
    return success;
}

- (void)removeCover {
    [Utility removeFile:[self getCoverName]];
}

- (void)loadItinerary {
    NSMutableArray *locations = [Location findAllByPlanId:_planId];
    _itinerary = [[NSMutableArray alloc] init];
    int day = 0;
    while (day++ < [_duration intValue]) {
        [_itinerary addObject:[[NSMutableArray alloc] init]];
    }
    for (Location *location in locations) {
        [[_itinerary objectAtIndex:[location.whichday integerValue]] addObject:location];
    }
}


-(NSUInteger)getLocationCountFromDay:(NSUInteger)day
{
    if (day < [_duration integerValue]) {
        return [[_itinerary objectAtIndex:day] count];
    } else {
        return 0;
    }
}

-(Location *)getLocationFromDay:(NSUInteger)day AtIndex:(NSUInteger)index
{
    if (day < [_duration integerValue]) {
        NSMutableArray *locations = [_itinerary objectAtIndex:day];
        if (index < locations.count) {
            return [locations objectAtIndex:index];
        }
    }
    return nil;
}

-(void)addLocation:(Location *)location ToDay:(NSUInteger)day
{
    if (day < [_duration integerValue]) {
        location.planId = _planId;
        location.whichday = [NSNumber numberWithInteger:day];
        location.seqofday = [NSNumber numberWithInteger:[[_itinerary objectAtIndex:day] count]];
        [[_itinerary objectAtIndex:day] addObject:location];
        
        [location save];
        if (_changedSinceLastSync == NO) {
            _changedSinceLastSync = YES;
            [self save];
        }
    }
}

-(void)moveThisLocation:(Location *)thisLocation ToThatLocation:(Location *)thatLocation
{
    if (thisLocation != nil && thatLocation != nil && thisLocation != thatLocation) {
        NSUInteger fromDay = thisLocation.whichday.integerValue;
        NSUInteger toDay = thatLocation.whichday.integerValue;
        NSUInteger fromSeq = thisLocation.seqofday.integerValue;
        NSUInteger toSeq = thatLocation.seqofday.integerValue;
        NSMutableArray *thisLocations = [_itinerary objectAtIndex:fromDay];
        NSMutableArray *thatLocations = [_itinerary objectAtIndex:toDay];
        [thisLocations removeObjectAtIndex:fromSeq];
        [thatLocations insertObject:thisLocation atIndex:toSeq];
        if (fromDay == toDay) {
            [self refreshLocationSeqsOfDay:fromDay AfterIndex:MIN(fromSeq, toSeq)];
        } else {
            thisLocation.whichday = [NSNumber numberWithInteger:toDay];
            [self refreshLocationSeqsOfDay:fromDay AfterIndex:fromSeq];
            [self refreshLocationSeqsOfDay:toDay AfterIndex:toSeq];
        }
        if (_changedSinceLastSync == NO) {
            _changedSinceLastSync = YES;
            [self save];
        }
    }
}

-(void)refreshLocationSeqsOfDay:(NSUInteger)day AfterIndex:(NSUInteger) index
{
    if (day < [_duration integerValue]) {
        NSMutableArray *locations = [_itinerary objectAtIndex:day];
        for (; index < locations.count; index++) {
            Location *location = [locations objectAtIndex:index];
            location.seqofday = [NSNumber numberWithInteger:index];
        }
    }
}

-(void)persistentReorderFromThisLocation:(Location *)thisLocation ToThatLocation:(Location *)thatLocation
{
    if (thisLocation != nil && thatLocation != nil && thisLocation != thatLocation) {
        NSUInteger fromDay = thisLocation.whichday.integerValue;
        NSUInteger toDay = thatLocation.whichday.integerValue;
        NSUInteger fromSeq = thisLocation.seqofday.integerValue;
        NSUInteger toSeq = thatLocation.seqofday.integerValue;
        if (fromDay == toDay) {
            [self persistentReorderOfDay:fromDay AfterIndex:MIN(fromSeq, toSeq)];
        } else {
            [self persistentReorderOfDay:fromDay AfterIndex:fromSeq];
            [self persistentReorderOfDay:toDay AfterIndex:toSeq];
        }
    }
}

-(void)persistentReorderOfDay:(NSUInteger)day AfterIndex:(NSUInteger) index
{
    if (day < [_duration integerValue]) {
        NSMutableArray *locations = [_itinerary objectAtIndex:day];
        for (; index < locations.count; index++) {
            Location *location = [locations objectAtIndex:index];
            [location save];
        }
    }
}

-(void)removeLocationFromDay:(NSUInteger)day AtIndex:(NSUInteger)index
{
    if (day < [_duration integerValue]) {
        NSMutableArray *locations = [_itinerary objectAtIndex:day];
        if (index < locations.count) {
            [locations removeObjectAtIndex:index];
            [self persistentReorderOfDay:day AfterIndex:index];
            if (_changedSinceLastSync == NO) {
                _changedSinceLastSync = YES;
                [self save];
            }
        }
    }
}

-(void)removeLocation:(Location *)location
{
    if (location != nil) {
        [self removeLocationFromDay:[location.whichday integerValue] AtIndex:[location.seqofday integerValue]];
    }
}

-(Boolean)hasNextLocation:(Location *)location
{
    if (location != nil) {
        if ([location.whichday integerValue] == ([_duration integerValue] - 1)) {
            NSMutableArray *locations = [_itinerary objectAtIndex:location.whichday];
            return [location.seqofday integerValue] < (locations.count - 1);
        } else {
            for (int day = [location.whichday integerValue] + 1; day < [_duration integerValue]; day++) {
                NSMutableArray *locations = [_itinerary objectAtIndex:day];
                if (locations.count > 0) {
                    return YES;
                }
            }
        }
    }
    return NO;
}

-(Boolean)hasPreviousLocation:(Location *)location
{
    if (location != nil) {
        if ([location.whichday integerValue] == 0) {
            return [location.seqofday integerValue] == 0;
        } else {
            for (int day = [location.whichday integerValue] - 1; day > 0; day--) {
                NSMutableArray *locations = [_itinerary objectAtIndex:day];
                if (locations.count > 0) {
                    return YES;
                }
            }
        }
    }
    return NO;
}

-(Location *)getNextLocation:(Location *)location
{
    if ([self hasNextLocation:location]) {
        NSUInteger day = [location.whichday integerValue];
        NSUInteger index = [location.seqofday integerValue];
        NSMutableArray *locations = [_itinerary objectAtIndex:day];
        return [locations objectAtIndex:(index + 1)];
    }
    return nil;
}

-(Location *)getPreviousLocation:(Location *)location
{
    if ([self hasNextLocation:location]) {
        NSUInteger day = [location.whichday integerValue];
        NSUInteger index = [location.seqofday integerValue];
        NSMutableArray *locations = [_itinerary objectAtIndex:day];
        return [locations objectAtIndex:(index + 1)];
    }
    return nil;
}

-(Boolean)hasSameDayNextLocation:(Location *)location
{
    return [self hasNextLocation:location];
}

-(Boolean)hasSameDayPreviousLocation:(Location *)location
{
    return [self hasPreviousLocation:location];
}

-(Location *)getSameDayNextLocation:(Location *)location
{
    return [self getNextLocation:location];
}

-(Location *)getSameDayPreviousLocation:(Location *)location
{
    return [self getPreviousLocation:location];
}

-(void)sync
{
    if (_changedSinceLastSync) {
        //同步
        NSString *data = [self encode];
    } else {
        //更新
    }
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
                          _destination, @"destination",
                          _name, @"name",
                          [formatter stringFromDate:_date], @"date",
                          _duration, @"duration",
                          _planId, @"id",
                          _uid, @"uid",
                          _serverId, @"serverId",
                          _version, @"version",
                          [self encodeItinerary], @"itinerary",
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

-(NSMutableArray *)encodeItinerary
{
    NSMutableArray *encoded = [[NSMutableArray alloc] init];
    for (NSMutableArray *dayLocations in self.itinerary)
    {
        NSMutableArray *dayEncoded = [[NSMutableArray alloc] init];
        for (Location *location in dayLocations)
        {
            [dayEncoded addObject:[location encode]];
        }
        [encoded addObject:dayEncoded];
    }
    return encoded;
}

-(void)decode:(NSString *)planData
{
}

@end
