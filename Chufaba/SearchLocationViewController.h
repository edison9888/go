//
//  SearchLocationViewController.h
//  出发吧
//
//  Created by 张 辛欣 on 13-1-20.
//  Copyright (c) 2013年 出发吧APP团队. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Location.h"
//#import "LocationViewController.h"
#import "JsonFetcher.h"
#import "SearchTableViewCell.h"
#import "AddLocationViewController.h"

@protocol SearchLocationViewControllerDelegate<NSObject>

-(void) notifyItinerayView:(Location *) location;

@end

@interface SearchLocationViewController : UIViewController <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, AddLocationViewControllerDelegate>
{
    JSONFetcher *fetcher;
    UIButton *addLocationBtn;
    BOOL showAddLocationBtn;
    NSMutableArray *allLocationList;
}

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,weak) id<SearchLocationViewControllerDelegate> searchDelegate;

@property (nonatomic, copy) NSNumber *lastLatitude;
@property (nonatomic, copy) NSNumber *lastLongitude;
@property (nonatomic, copy) NSString *category;


@end
