//
//  itineraryTransportViewController.h
//  出发吧
//
//  Created by Perry on 13-1-28.
//  Copyright (c) 2013年 出发吧APP团队. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol itineraryTransportViewDelegate<NSObject>

-(void) didEditTransport:(NSString *)transportation;

@end

@interface itineraryTransportViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextView *transportInput;
@property (nonatomic, copy) NSString *transportation;

@property (nonatomic,weak) id<itineraryTransportViewDelegate> delegate;

@end
