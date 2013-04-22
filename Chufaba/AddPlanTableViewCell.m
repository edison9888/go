//
//  AddPlanTableViewCell.m
//  Chufaba
//
//  Created by Perry on 13-4-14.
//  Copyright (c) 2013年 ChufabaAPP团队. All rights reserved.
//

#import "AddPlanTableViewCell.h"

@implementation AddPlanTableViewCell

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
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"kuang.png"] stretchableImageWithLeftCapWidth:8 topCapHeight:8]];
    imageView.frame = CGRectMake(10, 10, 300, self.frame.size.height - 20);
    self.backgroundView = imageView;
}

@end
