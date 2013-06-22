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
        [btn setTitle:@"地图模式" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor colorWithRed:36/255.0 green:71/255.0 blue:113/255.0 alpha:1.0] forState:UIControlStateNormal];
        btn.backgroundColor = [UIColor clearColor];
        [[btn layer] setBorderWidth:1.0f];
        [[btn layer] setBorderColor:[UIColor grayColor].CGColor];
        [btn addTarget:self action:@selector(showMap:) forControlEvents:UIControlEventTouchDown];
        mapBtn = btn;
        [self addSubview:btn];
        
        btn = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width/3, frame.size.height - 40.0f, self.frame.size.width/3, 40.0f)];
        [btn setTitle:@"地点排序" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor colorWithRed:36/255.0 green:71/255.0 blue:113/255.0 alpha:1.0] forState:UIControlStateNormal];
        btn.backgroundColor = [UIColor clearColor];
        [[btn layer] setBorderWidth:1.0f];
        [[btn layer] setBorderColor:[UIColor grayColor].CGColor];
        [btn addTarget:self action:@selector(showEditSeq:) forControlEvents:UIControlEventTouchDown];
        editBtn = btn;
        [self addSubview:btn];
        
        btn = [[UIButton alloc] initWithFrame:CGRectMake(2*self.frame.size.width/3, frame.size.height - 40.0f, self.frame.size.width/3, 40.0f)];
        [btn setTitle:@"同步行程" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor colorWithRed:36/255.0 green:71/255.0 blue:113/255.0 alpha:1.0] forState:UIControlStateNormal];
        btn.backgroundColor = [UIColor clearColor];
        [[btn layer] setBorderWidth:1.0f];
        [[btn layer] setBorderColor:[UIColor grayColor].CGColor];
        [btn addTarget:self action:@selector(synchronizeItinerary:) forControlEvents:UIControlEventTouchDown];
        syncBtn = btn;
        [self addSubview:btn];		
    }
	
    return self;	
}

//- (IBAction)pushAddPlanViewController:(id)sender
//{
//    [self.delegate showEditTravelPlan:self];
//}

- (IBAction)showMap:(id)sender
{
    [self.delegate switchToMapMode:self];
}

- (IBAction)showEditSeq:(id)sender
{
    [self.delegate editLocationsSequence:self];
}

//- (IBAction)showMenu:(id)sender
//{
//    [self.delegate showShareMenu:self];
//}

- (IBAction)synchronizeItinerary:(id)sender
{
    [self.delegate startSynchronize:self];
}

- (void)setState:(PullDownMenuState)aState
{
    state = aState;
}

- (void)pdmScrollViewDidScroll:(UIScrollView *)scrollView
{
    if (state == PullDownMenuDisplay) {		
		CGFloat offset = MAX(scrollView.contentOffset.y * -1, 0);
		offset = MIN(offset, 40);
		scrollView.contentInset = UIEdgeInsetsMake(offset, 0.0f, 0.0f, 0.0f);		
	}
    else if (scrollView.isDragging){	
		if (state == PullDownMenuPulling && scrollView.contentOffset.y > -45.0f && scrollView.contentOffset.y < 0.0f) {
			[self setState:PullDownMenuHide];
		} else if (state == PullDownMenuHide && scrollView.contentOffset.y < -45.0f) {
			[self setState:PullDownMenuPulling];
		}
		
		if (scrollView.contentInset.top != 0) {
			scrollView.contentInset = UIEdgeInsetsZero;
		}
    }
}

- (void)pdmScrollViewDidEndDragging:(UIScrollView *)scrollView
{	
	if (scrollView.contentOffset.y <= - 45.0f) {				
		[self setState:PullDownMenuDisplay];
		scrollView.contentInset = UIEdgeInsetsMake(40.0f, 0.0f, 0.0f, 0.0f);
	}
    else if (scrollView.contentOffset.y > - 45.0f && scrollView.contentOffset.y < 0.0f)
    {
        scrollView.contentInset = UIEdgeInsetsZero;
    }
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
