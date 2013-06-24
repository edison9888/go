//
//  EditItineraryViewController.h
//  Chufaba
//
//  Created by 张辛欣 on 13-6-24.
//  Copyright (c) 2013年 ChufabaAPP团队. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMDBDataAccess.h" 

@protocol EditItineraryViewControllerDelegate <NSObject>

@optional
-(void) notifyItinerayToReload;

@end

@interface EditItineraryViewController : UITableViewController

@property (nonatomic,strong) Plan *plan;

@property (nonatomic,weak) NSNumber *daySelected;
@property (nonatomic, strong) NSDictionary *categoryImage;

@property (nonatomic, assign) BOOL singleDayMode;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSCalendar *gregorian;

@property (nonatomic,weak) id<EditItineraryViewControllerDelegate> delegate;

@end
