//
//  SearchTableViewCell.m
//  Chufaba
//
//  Created by Perry on 13-2-26.
//  Copyright (c) 2013年 ChufabaAPP团队. All rights reserved.
//

#import "SearchTableViewCell.h"

@implementation SearchTableViewCell

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
    imgFrame.origin = CGPointMake(self.bounds.size.width/2-20, self.bounds.size.height/2-20);
    [[self imageView] setFrame:imgFrame];
}
@end
