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
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 20, 300, 40)];
    imageView.image = [UIImage imageNamed:@"kuang.png"];
    self.backgroundView = imageView;
}

@end
