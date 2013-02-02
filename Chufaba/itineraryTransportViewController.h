//
//  itineraryTransportViewController.h
//  出发吧
//
//  Created by Perry on 13-1-28.
//  Copyright (c) 2013年 出发吧APP团队. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "itineraryDetailViewController.h"


@interface itineraryTransportViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextView *transportInput;
@property (nonatomic, copy) NSString *transportation;

@property (nonatomic,weak) id<locationEditDelegate> delegate;

@end
