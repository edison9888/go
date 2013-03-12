//
//  SwipeableTableViewCell.m
//  Chufaba
//
//  Created by 张辛欣 on 13-3-7.
//  Copyright (c) 2013年 ChufabaAPP团队. All rights reserved.
//

#import "SwipeableTableViewCell.h"

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
	//[self setBackgroundColor:[UIColor clearColor]];

    contentView = [[SwipeableTableViewCellView alloc] initWithFrame:CGRectMake(0, 0, 320, 94)];
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
}

- (void)cellWasSwiped:(UISwipeGestureRecognizer *)recognizer
{	
	UITableView * tableView = (UITableView *)self.superview;
    
    CGPoint location = [recognizer locationInView:tableView];
    NSIndexPath *swipedIndexPath = [tableView indexPathForRowAtPoint:location];
    
    //UITableViewCell *swipedCell  = [tableView cellForRowAtIndexPath:swipedIndexPath];
    NSInteger yPosition = 94*swipedIndexPath.row + 24;
    
    UIView *maskView = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,480)];
    maskView.backgroundColor = [UIColor clearColor];
    maskView.tag = 10;
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(maskViewTapped:)];
    [maskView addGestureRecognizer:tapRecognizer];
    
    UIButton *editButton = [[UIButton alloc] initWithFrame:CGRectMake(232,yPosition,44,44)];
    [editButton setImage:[UIImage imageNamed:@"edit.png"] forState:UIControlStateNormal];
    [editButton addTarget:self action:@selector(editPlan:) forControlEvents:UIControlEventTouchDown];
	
	UIButton *deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(276,yPosition,44,44)];
    [deleteButton setImage:[UIImage imageNamed:@"delete.png"] forState:UIControlStateNormal];
    [deleteButton addTarget:self action:@selector(deletePlan:) forControlEvents:UIControlEventTouchDown];
    
    [maskView addSubview:editButton];
    [maskView addSubview:deleteButton];
    [tableView addSubview:maskView];
    
	id delegate = tableView.nextResponder; 
	
	NSIndexPath * myIndexPath = [tableView indexPathForCell:self];
    
    if ([delegate respondsToSelector:@selector(tableView:didSwipeCellAtIndexPath:)])
    {
        [delegate tableView:tableView didSwipeCellAtIndexPath:myIndexPath];
    }
}

- (IBAction)maskViewTapped:(id)sender
{
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
