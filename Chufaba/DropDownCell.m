//
//  DropDownCell.m
//  Chufaba
//
//  Created by Perry on 13-4-11.
//  Copyright (c) 2013年 ChufabaAPP团队. All rights reserved.
//

#import "DropDownCell.h"

#define TAG_UP_LINE 1
#define TAG_BOTTOM_LINE 2

@interface DropDownCell ()
{
    BOOL showUpLine;
    BOOL showBottomLine;
}
@end

@implementation DropDownCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.font = [UIFont systemFontOfSize:15];
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        self.textLabel.textColor = [UIColor colorWithRed:196/255.0 green:230/255.0 blue:184/255.0 alpha:1.0];
        self.textLabel.font = [UIFont fontWithName:@"Heiti SC" size:16];
        self.textLabel.highlightedTextColor = self.textLabel.textColor;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    if (highlighted) {
        self.backgroundColor = [UIColor colorWithRed:30/255.0 green:133/255.0 blue:133/255.0 alpha:1.0];
        UIView *uplineView = [self.contentView viewWithTag:TAG_UP_LINE];
        if (uplineView) {
            [uplineView setHidden:true];
        }
        UIView *bottomlineView = [self.contentView viewWithTag:TAG_BOTTOM_LINE];
        if (bottomlineView) {
            [bottomlineView setHidden:true];
        }
    } else {
        self.backgroundColor = [UIColor colorWithRed:44/255.0 green:145/255.0 blue:144/255.0 alpha:1.0];
        if (showUpLine) {
            UIView *uplineView = [self.contentView viewWithTag:TAG_UP_LINE];
            if (uplineView) {
                [uplineView setHidden:NO];
            }
        }
        if (showBottomLine) {
            UIView *bottomlineView = [self.contentView viewWithTag:TAG_BOTTOM_LINE];
            if (bottomlineView) {
                [bottomlineView setHidden:NO];
            }
        }
    }
}

- (void)showUpLine:(BOOL)show
{
    showUpLine = show;
    UIView *uplineView = [self.contentView viewWithTag:TAG_UP_LINE];
    if (showUpLine) {
        if (uplineView) {
            [uplineView setHidden:false];
        } else {
            uplineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, 1)];
            uplineView.backgroundColor = [UIColor colorWithRed:56/255.0 green:154/255.0 blue:154/255.0 alpha:1.0];
            uplineView.tag = TAG_UP_LINE;
            [self.contentView addSubview:uplineView];
        }
    } else {
        if (uplineView){
            [uplineView setHidden:true];
        }
    }
}

- (void)showBottomLine:(BOOL)show
{
    showBottomLine = show;
    UIView *bottomlineView = [self.contentView viewWithTag:TAG_BOTTOM_LINE];
    if (showBottomLine) {
        if (bottomlineView) {
            [bottomlineView setHidden:false];
        } else {
            bottomlineView = [[UIView alloc] initWithFrame:CGRectMake(0, 39, self.contentView.frame.size.width, 1)];
            bottomlineView.backgroundColor = [UIColor colorWithRed:26/255.0 green:128/255.0 blue:128/255.0 alpha:1.0];
            bottomlineView.tag = TAG_BOTTOM_LINE;
            [self.contentView addSubview:bottomlineView];
        }
    } else {
        if (bottomlineView){
            [bottomlineView setHidden:true];
        }
    }
}

@end
