//
//  SwipeableTableViewCell.m
//  Chufaba
//
//  Created by 张辛欣 on 13-3-7.
//  Copyright (c) 2013年 ChufabaAPP团队. All rights reserved.
//

#import "SwipeableTableViewCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation SwipeableTableViewController

- (void)tableView:(UITableView *)tableView didSwipeCellAtIndexPath:(NSIndexPath *)indexPath
{

}

- (void) didEditPlan
{
    
}

- (void) didDeletePlan;
{
    
}

@end

@implementation SwipeableTableViewCellView
@end


@interface SwipeableTableViewCell (Private)
- (void)initialSetup;
- (void)resetViews:(BOOL)animated;
@end

@implementation SwipeableTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self initialSetup];
    }
    return self;
}

- (void)initialSetup
{
    self.textLabel.textColor = [UIColor colorWithRed:72/255.0 green:70/255.0 blue:66/255.0 alpha:1.0];
    self.textLabel.highlightedTextColor = [UIColor colorWithRed:72/255.0 green:70/255.0 blue:66/255.0 alpha:1.0];
    self.textLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:16];
    
    self.detailTextLabel.textColor = [UIColor colorWithRed:153/255.0 green:150/255.0 blue:145/255.0 alpha:1.0];
    self.detailTextLabel.highlightedTextColor = [UIColor colorWithRed:153/255.0 green:150/255.0 blue:145/255.0 alpha:1.0];
    self.detailTextLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:12];
    
    self.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"detailinfo"]];
    UIView *bgColorView = [[UIView alloc] init];
    [bgColorView setBackgroundColor:[UIColor colorWithRed:233/255.0 green:227/255.0 blue:214/255.0 alpha:1.0]];
    [self setSelectedBackgroundView:bgColorView];
	
	UISwipeGestureRecognizer *swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(cellWasSwiped:)];
    [swipeRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
	[self addGestureRecognizer:swipeRecognizer];
    
    UILabel *planInfo = [[UILabel alloc] initWithFrame:CGRectMake(140, 56, 120, 20)];
    planInfo.tag = 4;
    planInfo.backgroundColor = [UIColor clearColor];
    planInfo.textColor = [UIColor colorWithRed:153/255.0 green:150/255.0 blue:145/255.0 alpha:1.0];
    planInfo.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:12];
    [self.contentView addSubview:planInfo];
    
    self.imageView.layer.cornerRadius = 3.0;
    self.imageView.layer.masksToBounds = YES;
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 91, 320, 1)];
    lineView.backgroundColor = [UIColor colorWithRed:227/255.0 green:219/255.0 blue:204/255.0 alpha:1.0];
    [self.contentView addSubview:lineView];
    
    lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
    lineView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:lineView];
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    self.textLabel.frame = CGRectMake(140, 20, 160, 20);
    self.detailTextLabel.frame = CGRectMake(140, 42, 120, 20);
    self.imageView.frame = CGRectMake(20, 16, 100, 60);
}

- (IBAction)editPlan:(id)sender
{
    UITableView * tableView = (UITableView *)self.superview;
    id delegate = tableView.nextResponder;
    if ([delegate respondsToSelector:@selector(didEditPlan)])
    {
        [delegate didEditPlan];
    }
}

- (IBAction)deletePlan:(id)sender
{
    UITableView * tableView = (UITableView *)self.superview;
    
    id delegate = tableView.nextResponder;
    if ([delegate respondsToSelector:@selector(didDeletePlan)]){
        [delegate didDeletePlan];
    }
}

- (void)cellWasSwiped:(UISwipeGestureRecognizer *)recognizer
{
	UITableView * tableView = (UITableView *)self.superview;
    NSInteger yPosition = self.frame.origin.y - tableView.bounds.origin.y;
    
    UIView *maskView = [[UIView alloc] initWithFrame:CGRectMake(0,tableView.bounds.origin.y,320,480)];
    maskView.backgroundColor = [UIColor clearColor];
    maskView.tag = 10;
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(maskViewTapped:)];
    [maskView addGestureRecognizer:tapRecognizer];
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(maskViewTapped:)];
    [maskView addGestureRecognizer:panRecognizer];
    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(maskViewTapped:)];
    [maskView addGestureRecognizer:longPressRecognizer];
    
    UIView *editView = [[UIView alloc] initWithFrame:CGRectMake(0,0,51,92)];
    editView.backgroundColor = [UIColor colorWithRed:233/255.0 green:227/255.0 blue:214/255.0 alpha:1.0];
    UITapGestureRecognizer *editTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editPlan:)];
    [editView addGestureRecognizer:editTapRecognizer];
    UIImageView *editImgView = [[UIImageView alloc] initWithFrame:CGRectMake(15,35,21,21)];
    editImgView.image = [UIImage imageNamed:@"edit"];
    [editView addSubview:editImgView];
    
    UIView *deleteView = [[UIView alloc] initWithFrame:CGRectMake(51,0,51,92)];
    deleteView.backgroundColor = [UIColor colorWithRed:233/255.0 green:227/255.0 blue:214/255.0 alpha:1.0];
    UITapGestureRecognizer *delTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deletePlan:)];
    [deleteView addGestureRecognizer:delTapRecognizer];
    UIImageView *deleteImgView = [[UIImageView alloc] initWithFrame:CGRectMake(15,35,21,21)];
    deleteImgView.image = [UIImage imageNamed:@"delete"];
    [deleteView addSubview:deleteImgView];
    
    UIView *allView = [[UIView alloc] initWithFrame:CGRectMake(320,yPosition,102,92)];
    allView.backgroundColor = [UIColor colorWithRed:233/255.0 green:227/255.0 blue:214/255.0 alpha:1.0];
    CALayer *leftBorder = [CALayer layer];
    leftBorder.frame = CGRectMake(0, 0, 1, 92);
    leftBorder.backgroundColor = [UIColor colorWithRed:227/255.0 green:219/255.0 blue:204/255.0 alpha:1.0].CGColor;
    [allView.layer addSublayer:leftBorder];
    
    [allView addSubview:editView];
    [allView addSubview:deleteView];
    
    [maskView addSubview:allView];
    [tableView addSubview:maskView];
    
	id delegate = tableView.nextResponder;
	
	NSIndexPath * myIndexPath = [tableView indexPathForCell:self];
    
    if ([delegate respondsToSelector:@selector(tableView:didSwipeCellAtIndexPath:)])
    {
        [delegate tableView:tableView didSwipeCellAtIndexPath:myIndexPath];
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    CGRect cellFrame = self.frame;
    self.frame = CGRectMake(cellFrame.origin.x-102,cellFrame.origin.y,320,92);
    [allView setFrame:CGRectMake(218,yPosition,102,92)];
    [UIView commitAnimations];
}

- (IBAction)maskViewTapped:(id)sender
{
    CGRect cellFrame = self.frame;
    self.frame = CGRectMake(0,cellFrame.origin.y,320,92);
    UITableView * tableView = (UITableView *)self.superview;
    UIView *maskView = [tableView viewWithTag:10];
    [maskView removeFromSuperview];
}

- (void)prepareForReuse {
	
	[self resetViews:NO];
	[super prepareForReuse];
}

- (void)resetViews:(BOOL)animated
{

}

- (void)setSelected:(BOOL)flag {
	[self setSelected:flag animated:NO];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
	[self setNeedsDisplay];
}

- (void)setHighlighted:(BOOL)highlighted {
	[self setHighlighted:highlighted animated:NO];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
	[super setHighlighted:highlighted animated:animated];
	[self setNeedsDisplay];
}

@end
