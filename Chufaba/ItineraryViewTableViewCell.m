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

    // Configure the view for the selected state
}

- (void)initialSetup
{
	//[self setBackgroundColor:[UIColor clearColor]];
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
	[contentView setClipsToBounds:YES];
	[contentView setOpaque:NO];
    contentView.tag = 30;
    
    UIImageView *categoryIcon = [[UIImageView alloc] initWithFrame:CGRectMake(10, 12, 20, 20)];
    categoryIcon.tag = 1;
    [contentView addSubview:categoryIcon];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(40, 12, 200, 20)];
    title.tag = 2;
    title.backgroundColor = [UIColor clearColor];
    [contentView addSubview:title];
    
    UILabel *time = [[UILabel alloc] initWithFrame:CGRectMake(240, 12, 60, 20)];
    time.tag = 3;
    time.backgroundColor = [UIColor clearColor];
    [contentView addSubview:time];
    
    UIImageView *accessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(300, 16, 9, 12)];
    accessoryView.image = [UIImage imageNamed:@"detailsmall.png"];
    [contentView addSubview:accessoryView];
	
	UISwipeGestureRecognizer *swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(cellWasSwiped:)];
    [swipeRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
	[contentView addGestureRecognizer:swipeRecognizer];
    
    [self.contentView addSubview:contentView];
}

- (void)cellWasSwiped:(UISwipeGestureRecognizer *)recognizer
{
	UITableView * tableView = (UITableView *)self.superview;
    
    CGPoint location = [recognizer locationInView:tableView];
    NSIndexPath *swipedIndexPath = [tableView indexPathForRowAtPoint:location];
    
//    NSInteger yPosition = 0;
//    for(int i=0; i<swipedIndexPath.section; i++)
//    {
//        yPosition = yPosition + 44*[tableView numberOfRowsInSection:i];
//    }
//    yPosition = yPosition + 44*swipedIndexPath.row + 44*(swipedIndexPath.section+1);
    NSInteger yPosition = self.frame.origin.y - tableView.bounds.origin.y;
    
    //UIView *maskView = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,480)];
    UIView *maskView = [[UIView alloc] initWithFrame:CGRectMake(0,tableView.bounds.origin.y,320,480)];
    maskView.backgroundColor = [UIColor clearColor];
    maskView.tag = 10;
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(maskViewTapped:)];
    [maskView addGestureRecognizer:tapRecognizer];
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(maskViewTapped:)];
    [maskView addGestureRecognizer:panRecognizer];
    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(maskViewTapped:)];
    [maskView addGestureRecognizer:longPressRecognizer];
    
    UIView *deleteView = [[UIView alloc] initWithFrame:CGRectMake(320,yPosition,51,44)];
    //UIView *deleteView = [[UIView alloc] initWithFrame:CGRectMake(320,0,51,44)];
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
    [deleteButton setImage:[UIImage imageNamed:@"delete.png"] forState:UIControlStateNormal];
    [deleteButton addTarget:self action:@selector(notifyDeleteLocation:) forControlEvents:UIControlEventTouchDown];
    
    [deleteView addSubview:deleteButton];
    
    [maskView addSubview:deleteView];
    deleteView.tag = 11;
    //[self.contentView addSubview:deleteView];
    [tableView addSubview:maskView];
    
	id delegate = tableView.superview.nextResponder;
	
	NSIndexPath * myIndexPath = [tableView indexPathForCell:self];
    
    if ([delegate respondsToSelector:@selector(tableView:didSwipeCellAtIndexPath:)])
    {
        [delegate tableView:tableView didSwipeCellAtIndexPath:myIndexPath];
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    [[self.contentView viewWithTag:30] setFrame:CGRectMake(-51, 0, 320, 44)];
    if(swipedIndexPath.row == 0)
    {
        [deleteView setFrame:CGRectMake(279,yPosition+1,41,43)];
        //[deleteView setFrame:CGRectMake(279,1,41,43)];
    }
    else
    {
        [deleteView setFrame:CGRectMake(279,yPosition,41,44)];
        //[deleteView setFrame:CGRectMake(279,0,41,44)];
    }
    [UIView commitAnimations];
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
    [[self.contentView viewWithTag:30] setFrame:CGRectMake(0, 0, 320, 44)];
}

- (IBAction)maskViewTapped:(id)sender
{
    [[self.contentView viewWithTag:30] setFrame:CGRectMake(0, 0, 320, 44)];
    [[self.contentView viewWithTag:11] removeFromSuperview];
    UITableView * tableView = (UITableView *)self.superview;
    UIView *maskView = [tableView viewWithTag:10];
    [maskView removeFromSuperview];
}

@end
