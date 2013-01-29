//
//  PullDownMenuView.h
//  出发吧
//
//  Created by kenzo on 13-1-29.
//  Copyright (c) 2013年 出发吧APP团队. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface PullDownMenuView : UIView{
    UIButton *syncBtn;
    UIButton *editBtn;
    UIButton *shareBtn;
}

- (void)pdmScrollViewDidScroll:(UIScrollView *)scrollView;
- (void)pdmScrollViewDidEndDragging:(UIScrollView *)scrollView;

@end
