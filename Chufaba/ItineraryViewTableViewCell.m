//
//  ItineraryViewTableViewCell.m
//  Chufaba
//
//  Created by 张辛欣 on 13-3-26.
//  Copyright (c) 2013年 ChufabaAPP团队. All rights reserved.
//

#import "ItineraryViewTableViewCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation SwipeableViewController

- (void)tableView:(UITableView *)tableView didSwipeCellAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void) deleteLocation
{
    
}

@end

@implementation ItineraryViewTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initialSetup];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)initialSetup
{
    self.textLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:16];
    self.textLabel.textColor = [UIColor colorWithRed:72/255.0 green:70/255.0 blue:66/255.0 alpha:1.0];
    self.textLabel.highlightedTextColor = [UIColor colorWithRed:72/255.0 green:70/255.0 blue:66/255.0 alpha:1.0];
    
    self.detailTextLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:12];
    self.detailTextLabel.textColor = [UIColor colorWithRed:153/255.0 green:150/255.0 blue:145/255.0 alpha:1.0];
    self.detailTextLabel.highlightedTextColor = [UIColor colorWithRed:153/255.0 green:150/255.0 blue:145/255.0 alpha:1.0];
    
    //self.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"detailsmall"]];
	
	UISwipeGestureRecognizer *swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(cellWasSwiped:)];
    [swipeRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
	[self addGestureRecognizer:swipeRecognizer];
    
    UIView *bgColorView = [[UIView alloc] init];
    [bgColorView setBackgroundColor:[UIColor colorWithRed:233/255.0 green:227/255.0 blue:214/255.0 alpha:1.0]];
    [self setSelectedBackgroundView:bgColorView];
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    CGRect frame = self.textLabel.frame;
    frame.size.width = 200;
    self.textLabel.frame = frame;
    [self.detailTextLabel sizeToFit];
    CGRect dFrame = self.detailTextLabel.frame;
    dFrame.origin.x = 295 - dFrame.size.width;
    self.detailTextLabel.frame = dFrame;
}

- (void)cellWasSwiped:(UISwipeGestureRecognizer *)recognizer
{
	UITableView * tableView = (UITableView *)self.superview;
    
    CGPoint location = [recognizer locationInView:tableView];
    NSIndexPath *swipedIndexPath = [tableView indexPathForRowAtPoint:location];
    
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
    
    UIView *deleteView = [[UIView alloc] initWithFrame:CGRectMake(320,yPosition,46,44)];
    deleteView.backgroundColor = [UIColor colorWithRed:233/255.0 green:227/255.0 blue:214/255.0 alpha:1.0];
    
    CALayer *leftBorder = [CALayer layer];
    if(swipedIndexPath.row == 0)
    {
        leftBorder.frame = CGRectMake(0, 0, 1, 43);
    }
    else
    {
        leftBorder.frame = CGRectMake(0, 0, 1, 44);
    }
    leftBorder.backgroundColor = [UIColor colorWithRed:227/255.0 green:219/255.0 blue:204/255.0 alpha:1.0].CGColor;
    [deleteView.layer addSublayer:leftBorder];
	
	UIButton *deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(0,0,46,44)];
    [deleteButton setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
    [deleteButton addTarget:self action:@selector(notifyDeleteLocation:) forControlEvents:UIControlEventTouchDown];
    
    [deleteView addSubview:deleteButton];
    
    [maskView addSubview:deleteView];
    deleteView.tag = 11;
    [tableView addSubview:maskView];
    
	id delegate = tableView.superview.nextResponder;
	
	NSIndexPath * myIndexPath = [tableView indexPathForCell:self];
    
    if ([delegate respondsToSelector:@selector(tableView:didSwipeCellAtIndexPath:)])
    {
        [delegate tableView:tableView didSwipeCellAtIndexPath:myIndexPath];
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        if(swipedIndexPath.row == 0)
        {
            [deleteView setFrame:CGRectMake(274,yPosition+1,46,43)];
        }
        else
        {
            [deleteView setFrame:CGRectMake(274,yPosition,46,44)];
        }
        CGRect cellFrame = self.frame;
        self.frame = CGRectMake(cellFrame.origin.x-44,cellFrame.origin.y,320,44);
    } completion:NULL];
}


- (IBAction)notifyDeleteLocation:(id)sender
{
    UITableView * tableView = (UITableView *)self.superview;
    UIView *maskView = [tableView viewWithTag:10];
    [maskView removeFromSuperview];
    
    id delegate = tableView.superview.nextResponder;
    if ([delegate respondsToSelector:@selector(deleteLocation)])
    {
        [delegate deleteLocation];
    }
    CGRect cellFrame = self.frame;
    self.frame = CGRectMake(0,cellFrame.origin.y,320,44);
}

- (IBAction)maskViewTapped:(id)sender
{
    CGRect cellFrame = self.frame;
    self.frame = CGRectMake(0,cellFrame.origin.y,320,44);
    [[self.contentView viewWithTag:11] removeFromSuperview];
    UITableView * tableView = (UITableView *)self.superview;
    UIView *maskView = [tableView viewWithTag:10];
    [maskView removeFromSuperview];
}

@end
