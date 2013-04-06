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

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//
//}

@end

@implementation SwipeableTableViewCellView
- (void)drawRect:(CGRect)rect
{
    //[(SwipeableTableViewCell *)self.superview drawContentView:rect];
}
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
    contentView = [[SwipeableTableViewCellView alloc] initWithFrame:CGRectMake(0, 0, 320, 92)];
	[contentView setClipsToBounds:YES];
	[contentView setOpaque:NO];
    contentView.tag = 22;
    
    UIImageView *planCover = [[UIImageView alloc] initWithFrame:CGRectMake(20, 16, 100, 60)];
    planCover.image = [UIImage imageNamed:@"sydney.png"];
    planCover.tag = 1;
    [contentView addSubview:planCover];
    
    UILabel *planTitle = [[UILabel alloc] initWithFrame:CGRectMake(140, 20, 160, 20)];
    planTitle.tag = 2;
    planTitle.backgroundColor = [UIColor clearColor];
    [contentView addSubview:planTitle];
    
    UILabel *planDate = [[UILabel alloc] initWithFrame:CGRectMake(140, 42, 120, 20)];
    planDate.tag = 3;
    planDate.backgroundColor = [UIColor clearColor];
    [contentView addSubview:planDate];
    
    UILabel *planInfo = [[UILabel alloc] initWithFrame:CGRectMake(140, 56, 120, 20)];
    planInfo.tag = 4;
    planInfo.backgroundColor = [UIColor clearColor];
    [contentView addSubview:planInfo];
    
    UIImageView *accessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(300, 38, 12, 16)];
    accessoryView.image = [UIImage imageNamed:@"detailinfo.png"];
    [contentView addSubview:accessoryView];
	
	UISwipeGestureRecognizer *swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(cellWasSwiped:)];
    [swipeRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
	[contentView addGestureRecognizer:swipeRecognizer];
    
    [self addSubview:contentView];
    //self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (IBAction)editPlan:(id)sender
{
    UITableView * tableView = (UITableView *)self.superview;
    UIView *maskView = [tableView viewWithTag:10];
    [maskView removeFromSuperview];
    
    id delegate = tableView.nextResponder;
    if ([delegate respondsToSelector:@selector(didEditPlan)]){
        [delegate didEditPlan];
    }
    [contentView setFrame:CGRectMake(0, 0, 320, 92)];
}

- (IBAction)deletePlan:(id)sender
{
    UITableView * tableView = (UITableView *)self.superview;
    UIView *maskView = [tableView viewWithTag:10];
    [maskView removeFromSuperview];
    
    id delegate = tableView.nextResponder;
    if ([delegate respondsToSelector:@selector(didDeletePlan)]){
        [delegate didDeletePlan];
    }
    [contentView setFrame:CGRectMake(0, 0, 320, 92)];
}

- (void)cellWasSwiped:(UISwipeGestureRecognizer *)recognizer
{	
	UITableView * tableView = (UITableView *)self.superview;
    
//    CGPoint location = [recognizer locationInView:tableView];
//    NSIndexPath *swipedIndexPath = [tableView indexPathForRowAtPoint:location];
    
    //UITableViewCell *swipedCell  = [tableView cellForRowAtIndexPath:swipedIndexPath];
    //NSInteger yPosition = 92*swipedIndexPath.row;
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
    
    UIView *editView = [[UIView alloc] initWithFrame:CGRectMake(320,yPosition,102,92)];
    editView.backgroundColor = [UIColor colorWithRed:233/255.0 green:227/255.0 blue:214/255.0 alpha:1.0];
    
    CALayer *leftBorder = [CALayer layer];
    leftBorder.frame = CGRectMake(0, 0, 1, 92);
    leftBorder.backgroundColor = [UIColor colorWithRed:227/255.0 green:219/255.0 blue:204/255.0 alpha:1.0].CGColor;
    [editView.layer addSublayer:leftBorder];
    
    UIButton *editButton = [[UIButton alloc] initWithFrame:CGRectMake(20,35,21,21)];
    [editButton setImage:[UIImage imageNamed:@"edit.png"] forState:UIControlStateNormal];
    [editButton addTarget:self action:@selector(editPlan:) forControlEvents:UIControlEventTouchDown];
	
	UIButton *deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(61,35,21,21)];
    [deleteButton setImage:[UIImage imageNamed:@"delete.png"] forState:UIControlStateNormal];
    [deleteButton addTarget:self action:@selector(deletePlan:) forControlEvents:UIControlEventTouchDown];
    
    [editView addSubview:editButton];
    [editView addSubview:deleteButton];
    
    [maskView addSubview:editView];
    [tableView addSubview:maskView];
    
	id delegate = tableView.nextResponder; 
	
	NSIndexPath * myIndexPath = [tableView indexPathForCell:self];
    
    if ([delegate respondsToSelector:@selector(tableView:didSwipeCellAtIndexPath:)])
    {
        [delegate tableView:tableView didSwipeCellAtIndexPath:myIndexPath];
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    [contentView setFrame:CGRectMake(-102, 0, 320, 92)];
    [editView setFrame:CGRectMake(218,yPosition,102,92)];
    [UIView commitAnimations];
}

- (IBAction)maskViewTapped:(id)sender
{
    [contentView setFrame:CGRectMake(0, 0, 320, 92)];
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

- (void)setNeedsDisplay
{
	[super setNeedsDisplay];
	if (!contentView.hidden)
        [contentView setNeedsDisplay];
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
