//
//  SelectCategoryViewController.h
//  Chufaba
//
//  Created by 张辛欣 on 13-2-26.
//  Copyright (c) 2013年 ChufabaAPP团队. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Location.h"
#import "LocationViewController.h"
#import "SearchLocationViewController.h"

@interface SelectCategoryViewController : UIViewController <SearchLocationViewControllerDelegate>

@property (nonatomic, copy) NSString *category;
@property (nonatomic, copy) NSNumber *lastLatitude;
@property (nonatomic, copy) NSNumber *lastLongitude;

@property (nonatomic,weak) id<AddLocationDelegate> delegate;

@end
