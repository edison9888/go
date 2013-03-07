//
//  SwipeableTableViewCell.m
//  Chufaba
//
//  Created by 张辛欣 on 13-3-7.
//  Copyright (c) 2013年 ChufabaAPP团队. All rights reserved.
//

#import "SwipeableTableViewCell.h"

@implementation SwipeableTableViewController

- (BOOL)tableView:(UITableView *)tableView shouldSwipeCellAtIndexPath:(NSIndexPath *)indexPath
{
	return YES;
}

- (void)tableView:(UITableView *)tableView didSwipeCellAtIndexPath:(NSIndexPath *)indexPath
{
	//[self hideVisibleBackView:YES];
	//[self setIndexOfVisibleBackView:indexPath];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	//[self hideVisibleBackView:YES];
}

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
	[self setBackgroundColor:[UIColor clearColor]];
	
	CGRect newBounds = self.bounds;
    contentView = [[SwipeableTableViewCellView alloc] initWithFrame:newBounds];
	[contentView setClipsToBounds:YES];
	[contentView setOpaque:NO];
	
	UISwipeGestureRecognizer *swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(cellWasSwiped:)];
    [swipeRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
	[contentView addGestureRecognizer:swipeRecognizer];
    
    self.editButton = [[UIButton alloc] initWithFrame:CGRectMake(320,0,40,40)];
    [self.editButton setImage:[UIImage imageNamed:@"edit.png"] forState:UIControlStateNormal];
    [self.editButton addTarget:self action:@selector(editPlan:) forControlEvents:UIControlEventTouchDown];
	
	self.deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(360,0,40,40)];
    [self.deleteButton setImage:[UIImage imageNamed:@"delete.png"] forState:UIControlStateNormal];
    [self.deleteButton addTarget:self action:@selector(deletePlan:) forControlEvents:UIControlEventTouchDown];
    
	//[self.editButton setHidden:YES];
    //[self.deleteButton setHidden:YES];
	
	//[contentView addSubview:self.editButton];
	//[contentView addSubview:self.deleteButton];
    
    [self addSubview:self.editButton];
    [self addSubview:self.deleteButton];
    
    [self addSubview:contentView];
}

//- (void)setFrame:(CGRect)aFrame
//{
//	[super setFrame:aFrame];
//	CGRect newBounds = self.bounds;
//	newBounds.size.height -= 1;
//	[contentView setFrame:newBounds];
//}

- (IBAction)editPlan:(id)sender
{

}

- (IBAction)deletePlan:(id)sender
{
    
}

- (void)cellWasSwiped:(UISwipeGestureRecognizer *)recognizer
{	
	UITableView * tableView = (UITableView *)self.superview;
	id delegate = tableView.nextResponder; 
	
	if ([delegate respondsToSelector:@selector(tableView:shouldSwipeCellAtIndexPath:)]){
		
		NSIndexPath * myIndexPath = [tableView indexPathForCell:self];
		
		if ([delegate tableView:tableView shouldSwipeCellAtIndexPath:myIndexPath])
        {
			[self revealButtonAnimated:YES];
			if ([delegate respondsToSelector:@selector(tableView:didSwipeCellAtIndexPath:)]){
				[delegate tableView:tableView didSwipeCellAtIndexPath:myIndexPath];
			}
		}
	}
}

- (void)revealButtonAnimated:(BOOL)animated
{
    CGRect oldBounds = self.bounds;
    [contentView setFrame:CGRectMake(oldBounds.origin.x-80,oldBounds.origin.y,oldBounds.size.width,oldBounds.size.height)];
    [self.editButton setFrame:CGRectMake(240,0,40,40)];
    [self.deleteButton setFrame:CGRectMake(280,0,40,40)];
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

//- (void)drawContentView:(CGRect)rect
//{
//    UIColor * textColor = [UIColor blackColor];
//	if (self.selected || self.highlighted){
//		textColor = [UIColor whiteColor];
//	}
//	else
//	{
//		[[UIColor whiteColor] set];
//		UIRectFill(self.bounds);
//	}
//	
//	[textColor set];
//	
//	UIFont * textFont = [UIFont boldSystemFontOfSize:22];
//	
//	CGSize textSize = [self.text sizeWithFont:textFont constrainedToSize:rect.size];
//	[self.text drawInRect:CGRectMake((rect.size.width / 2) - (textSize.width / 2),
//								(rect.size.height / 2) - (textSize.height / 2),
//								textSize.width, textSize.height)
//			withFont:textFont];
//}

@end
