//
//  LocationTableViewCell.m
//  Chufaba
//
//  Created by Perry on 13-2-23.
//  Copyright (c) 2013年 ChufabaAPP团队. All rights reserved.
//

#import "LocationTableViewCell.h"

@implementation LocationTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    //have the cell layout normally
    [super layoutSubviews];
    //get the bounding rectangle that defines the position and size of the image
    CGRect imgFrame = [[self imageView] frame];
    imgFrame.origin = CGPointMake(6, imgFrame.origin.y);
    [[self imageView] setFrame:imgFrame];
    
    CGRect labelFrame = [[self textLabel] frame];
    labelFrame.origin = CGPointMake(47, labelFrame.origin.y);
    [[self textLabel] setFrame:labelFrame];
    
    //reposition the other labels accordingly
}

@end
