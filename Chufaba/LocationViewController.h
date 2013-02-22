//
//  itineraryDetailViewController.h
//  出发吧
//
//  Created by kenzo on 13-1-16.
//  Copyright (c) 2013年 出发吧APP团队. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
@class Location;

@protocol EditLocationDelegate<NSObject>

-(void) didEditTransport:(NSString *)transportation;
-(void) didEditCostWithAmount:(NSNumber *)amount AndCurrency:(NSString *)currency;
-(void) didEditScheduleWithStart:(NSDate *)start AndEnd:(NSDate *)end;
-(void) didEditDetail:(NSString *)detail;
-(void) didEditCategory:(NSString *)category;

@end

@protocol AddLocationDelegate <NSObject>

-(void) didAddLocation:(Location *)location;
-(void) didChangeLocation:(Location *)location;

@end

@protocol NavigateLocationDelegate <NSObject>

-(Location *) getPreviousLocation:(Location *)curLocation;
-(Location *) getNextLocation:(Location *)curLocation;

@end

@interface LocationViewController : UITableViewController<EditLocationDelegate>

@property (strong, nonatomic) Location *location;
@property (strong, nonatomic) NSNumber *locationIndex;
@property (strong, nonatomic) NSNumber *totalLocationCount;
@property (nonatomic,weak) id<AddLocationDelegate> delegate;
@property (nonatomic,weak) id<NavigateLocationDelegate> navDelegate;


@property (weak, nonatomic) IBOutlet UIScrollView *addressScrollView;
@property (strong, nonatomic) UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *nameScrollView;
@property (strong, nonatomic) UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *transportationLabel;
@property (weak, nonatomic) IBOutlet UILabel *costLabel;
@property (weak, nonatomic) IBOutlet UILabel *scheduleLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UILabel *dayLabel;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end
