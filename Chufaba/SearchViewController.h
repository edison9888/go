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

@interface SearchViewController : UIViewController <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>
{
    JSONFetcher *fetcher;
    UIButton *addLocationBtn;
    NSMutableArray *allLocationList;
}

@property (nonatomic, copy) NSString *category;

@property (nonatomic, copy) NSString *nameKeyword;
@property (nonatomic, copy) NSString *LocationKeyword;

@property (nonatomic, strong) UITextField *nameInput;
@property (nonatomic, strong) UITextField *locationInput;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, copy) NSNumber *lastLatitude;
@property (nonatomic, copy) NSNumber *lastLongitude;

@end
