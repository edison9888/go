//
//  SearchViewController.h
//  Chufaba
//
//  Created by 张辛欣 on 13-4-13.
//  Copyright (c) 2013年 ChufabaAPP团队. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JsonFetcher.h"
#import "AddLocationViewController.h"
#import "SearchTableViewCell.h"

@protocol SearchViewControllerDelegate<NSObject>

-(void) notifyItinerayToReload:(NSNumber *)lastDay withSeq:(NSNumber *)lastSeq;

@end

@interface SearchViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, AddLocationViewControllerDelegate, UISearchBarDelegate>
{
    JSONFetcher *fetcher;
    UIButton *addLocationBtn;
    NSMutableArray *allLocationList;
    BOOL shouldUpdateItinerary;
}

@property (nonatomic, copy) NSString *category;

@property (nonatomic, copy) NSString *nameKeyword;
@property (nonatomic, copy) NSString *locationKeyword;

//@property (nonatomic, strong) UITextField *nameInput;
//@property (nonatomic, strong) UITextField *locationInput;
@property (nonatomic, strong) UIScrollView *dayScroll;
@property (nonatomic, strong) UISearchBar *nameInput;
@property (nonatomic, strong) UISearchBar *locationInput;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic,weak) NSNumber *dayToAdd;
@property (nonatomic,weak) NSNumber *seqToAdd;

@property (nonatomic, copy) NSNumber *lastLatitude;
@property (nonatomic, copy) NSNumber *lastLongitude;
@property (nonatomic, copy) NSNumber *planId;

@property (nonatomic, strong) NSMutableArray *dayLocationCount;

@property (nonatomic, strong) NSDictionary *categoryImage;

@property (nonatomic,weak) id<SearchViewControllerDelegate> searchDelegate;

@end
