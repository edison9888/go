//
//  itineraryDetailViewController.h
//  出发吧
//
//  Created by kenzo on 13-1-16.
//  Copyright (c) 2013年 出发吧APP团队. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TravelLocation;

@protocol locationEditDelegate<NSObject>

-(void) didEditTransport:(NSString *)transportation;
-(void) didEditCostWithAmount:(NSNumber *)amount AndCurrency:(NSString *)currency;
-(void) didEditScheduleWithStart:(NSDate *)start AndEnd:(NSDate *)end;
-(void) didEditDetail:(NSString *)detail;
-(void) didEditCategory:(NSString *)category;

@end

@interface itineraryDetailViewController : UITableViewController<locationEditDelegate>

@property (strong, nonatomic) TravelLocation *location;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *transportationLabel;
@property (weak, nonatomic) IBOutlet UILabel *costLabel;
@property (weak, nonatomic) IBOutlet UILabel *scheduleLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;

@end
