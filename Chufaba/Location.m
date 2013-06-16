//
//  TravelLocation.m
//  出发吧
//
//  Created by kenzo on 13-1-16.
//  Copyright (c) 2013年 出发吧APP团队. All rights reserved.
//

#import "Location.h"
#import "FMDBDataAccess.h"

@interface Location()
{
    NSMutableArray *infoArray;
    NSMutableArray *imageArray;
}
@end

@implementation Location

- (BOOL)hasCoordinate
{
    if([self.latitude doubleValue] == 0 && [self.longitude doubleValue] == 0)
    {
        return NO;
    }
    return YES;
}

+ (NSString *)getLocationCategoryByJiepangCategoryId:(NSString *)category
{
    NSString *prefix = [category substringToIndex:2];
    if ([prefix isEqualToString:@"01"]) {
        return @"美食";
    }
    if ([prefix isEqualToString:@"03"]) {
        if ([category isEqualToString:@"0312"] || [category isEqualToString:@"0313"] || [category isEqualToString:@"0314"] || [category isEqualToString:@"0315"] || [category isEqualToString:@"0316"]) {
            return @"住宿";
        } else {
            return @"其它";
        }
    }
    if ([prefix isEqualToString:@"05"]) {
        return @"景点";
    }
    return @"其它";
}

- (NSString *)getNameAndCity
{
    return [self.city length] > 0 ? [NSString stringWithFormat:@"%@, %@", self.name, self.city] : self.name;
}

- (NSString *)name
{
    return [_name length] > 0 ? _name : _nameEn;
}

- (NSString *)nameEn
{
    return [_name length] > 0 ? _nameEn : @"";
}

- (NSString *)getRealName
{
    return _name;
}

- (NSString *)getRealNameEn
{
    return _nameEn;
}

- (NSUInteger)numberOfSections
{
    return [self numberOfRowsInInfoSection] > 0 ? 2 : 1;
}

- (NSUInteger)numberOfRowsInInfoSection
{
    if (infoArray == nil) {
        infoArray = [[NSMutableArray alloc] init];
        imageArray = [[NSMutableArray alloc] init];
        if (self.transportation.length > 0) {
            [infoArray addObject:self.transportation];
            [imageArray addObject:@"traffic.png"];
        }
        if (self.opening.length > 0) {
            [infoArray addObject:self.opening];
            [imageArray addObject:@"opentime.png"];
        }
        if (self.fee.length > 0) {
            [infoArray addObject:self.fee];
            [imageArray addObject:@"tickets.png"];
        }
        if (self.website.length > 0) {
            [infoArray addObject:self.website];
            [imageArray addObject:@"website.png"];
        }
    }
    return [infoArray count];
}

- (NSString *)contentForRow:(NSInteger)row
{
    if (infoArray == nil || [infoArray count] == 0) {
        return nil;
    }else{
        return (NSString *)[infoArray objectAtIndex:row];
    }
}

- (NSString *)imageNameForRow:(NSInteger)row
{
    if (imageArray == nil || [imageArray count] == 0) {
        return nil;
    }else{
        return (NSString *)[imageArray objectAtIndex:row];
    }
}

- (void)setPoiData:(NSDictionary *)poi
{
    self.poiId = [poi objectForKey: @"id"];
    self.name = [poi objectForKey: @"name"];
    self.nameEn = [poi objectForKey: @"name_en"];
    self.country = [poi objectForKey: @"country"];
    self.city = [poi objectForKey: @"city"];
    self.category = [poi objectForKey:@"category"];
    self.address = [poi objectForKey:@"address"];
    
    NSDictionary *point = [poi objectForKey:@"location"];
    self.latitude = [point objectForKey:@"lat"];
    self.longitude = [point objectForKey:@"lon"];
    
    if ([[poi objectForKey:@"status"] intValue] == 1) {
        self.transportation = [poi objectForKey:@"transport"];
        self.opening = [poi objectForKey:@"opening"];
        self.fee = [poi objectForKey:@"fee"];
        self.website = [poi objectForKey:@"website"];
    } else {
        self.transportation = nil;
        self.opening = nil;
        self.fee = nil;
        self.website = nil;
    }
}

- (Boolean)save
{
    Boolean result = NO;
    if (self.locationId == nil) {
        FMDatabase *db = [FMDatabase databaseWithPath:[Utility getDatabasePath]];
        [db open];
        result = [db executeUpdate:@"INSERT INTO location (plan_id,whichday,seqofday,name,name_en,country,city,address,transportation,category,latitude,longitude,useradd,poi_id,opening,fee,website) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);",self.planId,self.whichday,self.seqofday,self.name, self.nameEn,self.country,self.city,self.address,self.transportation,self.category,self.latitude,self.longitude,[NSNumber numberWithBool:self.useradd],self.poiId,self.opening,self.fee,self.website];
        if (!result) {
            NSLog([db lastErrorMessage]);
        }
        [db close];
    }else{
        FMDatabase *db = [FMDatabase databaseWithPath:[Utility getDatabasePath]];
        [db open];
        result = [db executeUpdate:@"UPDATE location set plan_id = ?, whichday = ?, seqofday = ?, name = ?, name_en = ?, country = ?, city = ?, address = ?, transportation = ?, category = ?, latitude = ?, longitude = ?, useradd = ?, poi_id = ?, opening = ?, fee = ?, website = ? WHERE id = ?", self.planId, self.whichday, self.seqofday, self.name, self.nameEn, self.country, self.city, self.address, self.transportation, self.category, self.latitude, self.longitude, self.useradd, self.poiId, self.opening, self.fee, self.website, self.locationId];
        if (!result) {
            NSLog([db lastErrorMessage]);
        }
        [db close];
    }
    return result;
}

@end
