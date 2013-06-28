//
//  TravelPlan.m
//  出发吧
//
//  Created by kenzo on 13-1-16.
//  Copyright (c) 2013年 出发吧APP团队. All rights reserved.
//

#import "Plan.h"
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
        _locationCount++;
        if (_changedSinceLastSync == NO) {
            _changedSinceLastSync = YES;
            [self save];
        }
    }
}

-(void)moveLocationFromDay:(NSUInteger)fromDay AtIndex:(NSUInteger)fromIndex ToDay:(NSUInteger)toDay AtIndex:(NSUInteger)toIndex
{
    if (fromDay < _duration.integerValue && toDay < _duration.integerValue) {
        NSMutableArray *fromLocations = [_itinerary objectAtIndex:fromDay];
        NSMutableArray *toLocations = [_itinerary objectAtIndex:toDay];
        if (fromIndex < fromLocations.count && toIndex <= toLocations.count) {
            Location *fromLocation = [self getLocationFromDay:fromDay AtIndex:fromIndex];
            [fromLocations removeObjectAtIndex:fromIndex];
            fromLocation.whichday = [NSNumber numberWithInteger:toDay];
            [toLocations insertObject:fromLocation atIndex:toIndex];
            
            if (fromDay == toDay) {
                [self reindexLocationsOfDay:fromDay SinceIndex:MIN(fromIndex, toIndex)];
            } else {
                [self reindexLocationsOfDay:fromDay SinceIndex:fromIndex];
                [self reindexLocationsOfDay:toDay SinceIndex:toIndex];
            }
            if (_changedSinceLastSync == NO) {
                _changedSinceLastSync = YES;
                [self save];
            }
        }
    }
}

-(void)reindexLocationsOfDay:(NSUInteger)day SinceIndex:(NSUInteger) index
{
    if (day < [_duration integerValue]) {
        NSMutableArray *locations = [_itinerary objectAtIndex:day];
        for (; index < locations.count; index++) {
            Location *location = [locations objectAtIndex:index];
            location.seqofday = [NSNumber numberWithInteger:index];
            [location save];
        }
    }
}

-(void)removeLocation:(Location *)location
{
    if (location != nil) {
        NSMutableArray *locations = [_itinerary objectAtIndex:location.whichday.integerValue];
        [locations removeObjectAtIndex:location.seqofday.integerValue];
        [self reindexLocationsOfDay:location.whichday.integerValue SinceIndex:location.seqofday.integerValue];
        [location destroy];
        _locationCount--;
        if (_changedSinceLastSync == NO) {
            _changedSinceLastSync = YES;
            [self save];
        }
    }
}

-(Boolean)hasNextLocation:(Location *)location FomeSameDay:(Boolean)sameDay NeedCoordinate:(Boolean)needCoordinate
{
    return [self getNextLocation:location FomeSameDay:sameDay NeedCoordinate:needCoordinate] != nil;
}

-(Boolean)hasPreviousLocation:(Location *)location FomeSameDay:(Boolean)sameDay NeedCoordinate:(Boolean)needCoordinate
{
    return [self getPreviousLocation:location FomeSameDay:sameDay NeedCoordinate:needCoordinate] != nil;
}

-(Location *)getNextLocation:(Location *)location FomeSameDay:(Boolean)sameDay NeedCoordinate:(Boolean)needCoordinate
{
    if (location != nil) {
        if (sameDay) {
            NSMutableArray *locations = [_itinerary objectAtIndex:location.whichday.integerValue];
            for (NSUInteger i=location.seqofday.integerValue + 1; i<locations.count; i++) {
                Location *nextLocation = [locations objectAtIndex:i];
                if (needCoordinate) {
                    if ([nextLocation hasCoordinate]) {
                        return nextLocation;
                    }
                } else {
                    return nextLocation;
                }
            }
            return nil;
        } else {
            Location *nextLocation = [self getNextLocation:location FomeSameDay:YES NeedCoordinate:needCoordinate];
            if (nextLocation != nil) {
                return nextLocation;
            } else {
                for (NSUInteger day=location.whichday.integerValue+1 ; day < _duration.integerValue; day++) {
                    NSMutableArray *locations = [_itinerary objectAtIndex:day];
                    for (NSUInteger i=0; i<locations.count; i++) {
                        nextLocation = [locations objectAtIndex:i];
                        if ([nextLocation hasCoordinate]) {
                            return nextLocation;
                        }
                    }
                }
                return nil;
            }
        }
    }
    return nil;
}

-(Location *)getPreviousLocation:(Location *)location FomeSameDay:(Boolean)sameDay NeedCoordinate:(Boolean)needCoordinate
{
    if (location != nil) {
        if (sameDay) {
            NSMutableArray *locations = [_itinerary objectAtIndex:location.whichday.integerValue];
            for (NSInteger i=location.seqofday.integerValue - 1; i>=0; i--) {
                Location *previousLocation = [locations objectAtIndex:i];
                if (needCoordinate) {
                    if ([previousLocation hasCoordinate]) {
                        return previousLocation;
                    }
                } else {
                    return previousLocation;
                }
            }
            return nil;
        } else {
            Location *previousLocation = [self getPreviousLocation:location FomeSameDay:YES NeedCoordinate:needCoordinate];
            if (previousLocation != nil) {
                return previousLocation;
            } else {
                for (NSInteger day=location.whichday.integerValue - 1 ; day >= 0; day--) {
                    NSMutableArray *locations = [_itinerary objectAtIndex:day];
                    for (NSInteger i=locations.count-1; i>=0; i--) {
                        previousLocation = [locations objectAtIndex:i];
                        if ([previousLocation hasCoordinate]) {
                            return previousLocation;
                        }
                    }
                }
                return nil;
            }
        }
    }
    return nil;
}

-(NSUInteger)getIndexOfLocation:(Location *)location
{
    if (location == nil) {
        return 0;
    }
    NSUInteger count = 0;
    for (NSUInteger day=0; day<location.whichday.integerValue; day++) {
        count += [self getLocationCountFromDay:day];
    }
    return count + location.seqofday.integerValue;
}

-(Boolean)hasPoi:(NSUInteger)poiId AtDay:(NSUInteger)day
{
    if (day < _duration.integerValue) {
        NSMutableArray *locations = [_itinerary objectAtIndex:day];
        for (Location *location in locations) {
            if (location.poiId.integerValue == poiId) {
                return YES;
            }
        }
    }
    return NO;
}

-(void)removePoi:(NSUInteger)poiId AtDay:(NSUInteger)day
{
    if (day < _duration.integerValue) {
        NSMutableArray *locations = [_itinerary objectAtIndex:day];
        for (Location *location in locations) {
            if (location.poiId.integerValue == poiId) {
                [self removeLocation:location];
                break;
            }
        }
    }
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
