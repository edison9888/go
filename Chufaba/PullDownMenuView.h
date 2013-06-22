//
//  PullDownMenuView.h
//  出发吧
//
//  Created by kenzo on 13-1-29.
//  Copyright (c) 2013年 出发吧APP团队. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

typedef enum{
	PullDownMenuHide = 0,
	PullDownMenuPulling,
	PullDownMenuDisplay,
} PullDownMenuState;

@protocol PullDownMenuDelegate;
@interface PullDownMenuView : UIView{
    UIButton *mapBtn;
    UIButton *editBtn;
    UIButton *syncBtn;
    //UIButton *shareBtn;
    PullDownMenuState state;
}

@property(nonatomic,assign) id <PullDownMenuDelegate> delegate;

- (void)setState:(PullDownMenuState)aState;
- (void)pdmScrollViewDidScroll:(UIScrollView *)scrollView;
- (void)pdmScrollViewDidEndDragging:(UIScrollView *)scrollView;

@end

@protocol PullDownMenuDelegate
- (void) switchToMapMode:(PullDownMenuView *)view;
- (void)editLocationsSequence:(PullDownMenuView *)view;
- (void) startSynchronize:(PullDownMenuView *)view;
//- (void)showShareMenu:(PullDownMenuView *)view;
@end
