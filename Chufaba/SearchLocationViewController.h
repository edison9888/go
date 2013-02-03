//
//  SearchLocationViewController.h
//  出发吧
//
//  Created by 张 辛欣 on 13-1-20.
//  Copyright (c) 2013年 出发吧APP团队. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Location.h"
#import "LocationViewController.h"
#import "JsonFetcher.h"

@interface SearchLocationViewController : UITableViewController <UISearchBarDelegate>
{
    JSONFetcher *fetcher;
    NSArray *allLocationList;
}

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic,weak) id<AddLocationDelegate> delegate;

@property (nonatomic, copy) NSNumber *lastLatitude;
@property (nonatomic, copy) NSNumber *lastLongitude;


@end
