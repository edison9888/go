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
        [self initialSetup];
    }
    return self;
}

- (void)initialSetup
{
    UIImageView *category = [[UIImageView alloc] initWithFrame:CGRectMake(10, 11, 40, 40)];
    category.tag = 1;
    [self.contentView addSubview:category];
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    nameLabel.tag = 2;
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.textColor = [UIColor colorWithRed:72/255.0 green:70/255.0 blue:66/255.0 alpha:1.0];
    nameLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:16];
    [self.contentView addSubview:nameLabel];
    
    UILabel *eNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    eNameLabel.tag = 3;
    eNameLabel.backgroundColor = [UIColor clearColor];
    eNameLabel.textColor = [UIColor colorWithRed:153/255.0 green:150/255.0 blue:145/255.0 alpha:1.0];
    eNameLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:12];
    [self.contentView addSubview:eNameLabel];
    
    UILabel *locationLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    locationLabel.tag = 4;
    locationLabel.backgroundColor = [UIColor clearColor];
    locationLabel.textColor = [UIColor colorWithRed:153/255.0 green:150/255.0 blue:145/255.0 alpha:1.0];
    locationLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:12];
    [self.contentView addSubview:locationLabel];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.tag = 5;
    [btn setFrame:CGRectMake(260.0, 16.0, 50.0, 30.0)];
    [self.contentView addSubview:btn];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
