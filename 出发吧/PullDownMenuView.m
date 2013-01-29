//
//  PullDownMenuView.m
//  出发吧
//
//  Created by kenzo on 13-1-29.
//  Copyright (c) 2013年 出发吧APP团队. All rights reserved.
//

#import "PullDownMenuView.h"

@implementation PullDownMenuView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		self.backgroundColor = [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];
		
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 40.0f, self.frame.size.width/3, 40.0f)];
        [btn setTitle:@"同步" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor colorWithRed:36/255.0 green:71/255.0 blue:113/255.0 alpha:1.0] forState:UIControlStateNormal];
        btn.backgroundColor = [UIColor clearColor];
        [[btn layer] setBorderWidth:1.0f];
        [[btn layer] setBorderColor:[UIColor grayColor].CGColor];
        syncBtn = btn;
        [self addSubview:btn];
        
        btn = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width/3, frame.size.height - 40.0f, self.frame.size.width/3, 40.0f)];
        [btn setTitle:@"标题和日期" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor colorWithRed:36/255.0 green:71/255.0 blue:113/255.0 alpha:1.0] forState:UIControlStateNormal];
        btn.backgroundColor = [UIColor clearColor];
        [[btn layer] setBorderWidth:1.0f];
        [[btn layer] setBorderColor:[UIColor grayColor].CGColor];
        editBtn = btn;
        [self addSubview:btn];
        
        btn = [[UIButton alloc] initWithFrame:CGRectMake(2*self.frame.size.width/3, frame.size.height - 40.0f, self.frame.size.width/3, 40.0f)];
        [btn setTitle:@"分享" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor colorWithRed:36/255.0 green:71/255.0 blue:113/255.0 alpha:1.0] forState:UIControlStateNormal];
        btn.backgroundColor = [UIColor clearColor];
        [[btn layer] setBorderWidth:1.0f];
        [[btn layer] setBorderColor:[UIColor grayColor].CGColor];
        shareBtn = btn;
        [self addSubview:btn];		
    }
	
    return self;
	
}

- (void)pdmScrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.isDragging) {		
		
	}
}

- (void)pdmScrollViewDidEndDragging:(UIScrollView *)scrollView
{

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
