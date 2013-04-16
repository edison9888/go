//
//  SearchDestinationViewController.h
//  Chufaba
//
//  Created by Perry on 13-4-14.
//  Copyright (c) 2013年 ChufabaAPP团队. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Location.h"
#import "JsonFetcher.h"

@protocol SearchDestinationViewControllerDelegate<NSObject>
-(void) updateDestination:(NSString *)destination;
@end

@interface SearchDestinationViewController : UIViewController <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>
{
    JSONFetcher *fetcher;
    NSMutableArray *allDestinationList;
}

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, copy) NSString *destination;

@property (nonatomic,weak) id<SearchDestinationViewControllerDelegate> delegate;


@end
