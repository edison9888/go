//
//  SearchLocationViewController.h
//  出发吧
//
//  Created by 张 辛欣 on 13-1-20.
//  Copyright (c) 2013年 出发吧APP团队. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Location.h"

@protocol SearchLocationViewControllerDelegate<NSObject>

-(void) didAddLocation:(Location *) locationSelected;

@end

@interface SearchLocationViewController : UITableViewController <UISearchBarDelegate>
{
    BOOL letUserSelectRow;
    BOOL searching;
    NSArray *allLocationList;
}

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic,weak) id<SearchLocationViewControllerDelegate> delegate;

@end
