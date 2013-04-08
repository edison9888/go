//
//  itineraryDetailViewController.h
//  出发吧
//
//  Created by kenzo on 13-1-16.
//  Copyright (c) 2013年 出发吧APP团队. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "AddLocationViewController.h"
@class Location;

@protocol EditLocationDelegate<NSObject>

-(void) didEditScheduleWithStart:(NSDate *)start;
-(void) didEditDetail:(NSString *)detail;

@end

@protocol AddLocationDelegate <NSObject>

-(void) didAddLocation:(Location *)location;
-(void) didChangeLocation:(Location *)location;

@end

@protocol NavigateLocationDelegate <NSObject>

-(Location *) getPreviousLocation:(Location *)curLocation;
-(Location *) getNextLocation:(Location *)curLocation;

@end

@interface LocationViewController : UIViewController<EditLocationDelegate, UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate, AddLocationViewControllerDelegate>

@property (strong, nonatomic) Location *location;
@property int locationIndex;
@property int totalLocationCount;
@property (nonatomic,weak) id<AddLocationDelegate> delegate;
@property (nonatomic,weak) id<NavigateLocationDelegate> navDelegate;

@end
