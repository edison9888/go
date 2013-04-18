//
//  CfbSearchBar.m
//  Chufaba
//
//  Created by 张辛欣 on 13-4-18.
//  Copyright (c) 2013年 ChufabaAPP团队. All rights reserved.
//

#import "CfbSearchBar.h"

@implementation CfbSearchBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self setShowsCancelButton:NO animated:NO];
    UITextField *searchField;
    NSUInteger numViews = [self.subviews count];
    for(int i = 0; i < numViews; i++) {
        if([[self.subviews objectAtIndex:i] isKindOfClass:[UITextField class]])
        {
            searchField = [self.subviews objectAtIndex:i];
        }
    }
    
    for (UIView *view in self.subviews)
    {
        if ([view isKindOfClass:NSClassFromString(@"UISearchBarBackground")])
        {
            [view removeFromSuperview];
            break;
        }
    }
    
    [self bringSubviewToFront:searchField];
    if(searchField) {
        searchField.textColor = [UIColor colorWithRed:72/255.0 green:70/255.0 blue:66/255.0 alpha:1.0];
        searchField.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:12];
        searchField.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
        [searchField setBorderStyle:UITextBorderStyleNone];
        [searchField setBackgroundColor:[UIColor clearColor]];
        searchField.background = [[UIImage imageNamed:@"skuang.png"] stretchableImageWithLeftCapWidth:3 topCapHeight:0];
        searchField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
}

//- (void)drawPlace

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
