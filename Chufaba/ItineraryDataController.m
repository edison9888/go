//
//  itineraryDataController.m
//  出发吧
//
//  Created by kenzo on 13-1-16.
//  Copyright (c) 2013年 出发吧APP团队. All rights reserved.
//

#import "ItineraryDataController.h"
#import "AFHTTPClient.h"

@interface ItineraryDataController ()

@end

@implementation ItineraryDataController

- (void)setMasterTravelDayList:(NSMutableArray *)newList {
    if (_masterTravelDayList != newList) {
        _masterTravelDayList = [newList mutableCopy];
    }
}

- (id)init {
    if (self = [super init]) {
        return self;
    }
    return nil;
}

- (NSUInteger)countOfList {
    return [self.masterTravelDayList count];
}

- (NSMutableArray *)objectInListAtIndex:(NSUInteger)theIndex {
    return [self.masterTravelDayList objectAtIndex:theIndex];
}

- (void)addTravelDayListWithList:(NSMutableArray *)list {
    [self.masterTravelDayList addObject:list];
}

-(void) updatePois
{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *defaultsKey = [NSString stringWithFormat:@"update_plan_%d", self.plan.planId.intValue];
    NSNumber *lastUpdate = (NSNumber *)[userDefaults objectForKey:defaultsKey];
    int now = (int)[[NSDate date] timeIntervalSince1970];
//    if(now < ([lastUpdate intValue] + 86400)){
//        return;
//    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
                                             (unsigned long)NULL), ^(void) {
        NSMutableArray *pois = [[NSMutableArray alloc] init];
        for (NSMutableArray *dayLocations in self.masterTravelDayList)
        {
            for (Location *location in dayLocations)
            {
                [pois addObject:location.poiId];
            }
        }
        if (pois.count == 0) {
            return;
        }
        
        NSURL *url = [NSURL URLWithString:@"http://chufaba.me:9200"];
        AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
        httpClient.parameterEncoding = AFJSONParameterEncoding;
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                pois, @"ids",
                                nil];
        [httpClient postPath:@"/cfb/poi/_mget" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSError *error = nil;
            NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&error];
            if (error) {
                NSLog(@"Error serializing %@", error);
            } else {
                NSArray *docs = [responseJSON objectForKey:@"docs"];
                if ([docs count] > 0) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
                                                             (unsigned long)NULL), ^(void) {
                        //两次循环，先用poi_id做key保存一个dict，再遍历所有location，复杂度为O(N)，空间换时间
                        NSMutableDictionary *updatedPois = [[NSMutableDictionary alloc] initWithCapacity:docs.count];
                        for (NSDictionary *doc in docs) {
                            BOOL exists = [doc objectForKey:@"exists"];
                            if (exists) {
                                NSDictionary *poi = [doc objectForKey:@"_source"];
                                [updatedPois setObject:poi forKey:[poi objectForKey:@"id"]];
                            }
                        }
                        //更新location
                        for (NSMutableArray *dayLocations in self.masterTravelDayList)
                        {
                            for (Location *location in dayLocations)
                            {
                                [location setPoiData:[updatedPois objectForKey:location.poiId]];
                                [location save];
                            }
                        }
                        [userDefaults setObject:[NSNumber numberWithInt:now] forKey:defaultsKey];
                        [userDefaults synchronize];
                    });
                }
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
        }];
    });
}

@end
