//
//  FadeScrollView.m
//  Chufaba
//
//  Created by Perry on 13-3-16.
//  Copyright (c) 2013年 ChufabaAPP团队. All rights reserved.
//

#import "FadeScrollView.h"
#import <QuartzCore/QuartzCore.h>

@implementation FadeScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)setContentOffset:(CGPoint)contentOffset
{
    [super setContentOffset:contentOffset];
}

- (void) layoutSubviews {
    [super layoutSubviews];
    CAGradientLayer *maskLayer = [[CAGradientLayer alloc] init];
    maskLayer.colors = [NSArray arrayWithObjects: (id)[UIColor colorWithWhite:1.0 alpha:1.0].CGColor,
                        (id)[UIColor colorWithWhite:1.0 alpha:1.0].CGColor,
                        (id)[UIColor colorWithWhite:1.0 alpha:0.0].CGColor, nil];
    maskLayer.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0],
                           [NSNumber numberWithFloat:0.8],
                           [NSNumber numberWithFloat:0.95], nil];
    [maskLayer setStartPoint:CGPointMake(0.0, 0.5)];
    [maskLayer setEndPoint:CGPointMake(1.0, 0.5)];
    maskLayer.frame = self.bounds;
    self.layer.mask = maskLayer;
}
@end
