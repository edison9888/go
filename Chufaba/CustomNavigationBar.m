//
//  CustomNavigationBar.m
//  Chufaba
//
//  Created by 张辛欣 on 13-4-21.
//  Copyright (c) 2013年 ChufabaAPP团队. All rights reserved.
//

#import "CustomNavigationBar.h"

@implementation UINavigationBar (UINavigationBarCategory)

- (void)drawRect:(CGRect)rect {
    //UIColor *color = [UIColor darkGrayColor];
    UIImage *img  = [UIImage imageNamed: @"bar.png"];
    [img drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    //self.tintColor = color;
}

@end
