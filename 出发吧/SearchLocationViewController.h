//
//  SearchLocationViewController.h
//  出发吧
//
//  Created by 张 辛欣 on 13-1-20.
//  Copyright (c) 2013年 出发吧APP团队. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SearchLocationDataController;

@interface SearchLocationViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) SearchLocationDataController *dataController;

@end
