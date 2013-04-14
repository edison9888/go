//
//  CfbTextField.m
//  Chufaba
//
//  Created by 张辛欣 on 13-4-14.
//  Copyright (c) 2013年 ChufabaAPP团队. All rights reserved.
//

#import "CfbTextField.h"

@implementation CfbTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) drawPlaceholderInRect:(CGRect)rect {
    [[UIColor colorWithRed:227/255.0 green:219/255.0 blue:204/255.0 alpha:1.0] setFill];
    [[self placeholder] drawInRect:rect withFont:[UIFont systemFontOfSize:16]];
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
