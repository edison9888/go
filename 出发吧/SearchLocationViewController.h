//
//  SearchLocationViewController.h
//  出发吧
//
//  Created by 张 辛欣 on 13-1-20.
//  Copyright (c) 2013年 出发吧APP团队. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchLocation.h"

@class SearchLocationViewController;
@protocol SearchLocationViewControllerDelegate<NSObject>

//-(void) searchLocationViewController:(SearchLocationViewController *) controller didAddSearchLocation:(SearchLocation *) locationSelected atDay:(NSInteger)day atSequence:(NSInteger)sequence;
-(void) searchLocationViewController:(SearchLocationViewController *) controller didAddSearchLocation:(SearchLocation *) locationSelected;

@end

@interface SearchLocationViewController : UITableViewController <UISearchBarDelegate>
{
    BOOL searching;
    BOOL letUserSelectRow;
    NSMutableArray *allLocationList;
    NSMutableArray *filteredLocationList;
}
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic,weak) id<SearchLocationViewControllerDelegate> delegate;
//@property (strong, nonatomic) SearchLocationDataController *dataController;

@end
