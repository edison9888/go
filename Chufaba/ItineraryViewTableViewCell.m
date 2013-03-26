//
//  ItineraryViewTableViewCell.m
//  Chufaba
//
//  Created by 张辛欣 on 13-3-26.
//  Copyright (c) 2013年 ChufabaAPP团队. All rights reserved.
//

#import "ItineraryViewTableViewCell.h"

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
    
    contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
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
    
    UILabel *time = [[UILabel alloc] initWithFrame:CGRectMake(240, 12, 50, 20)];
    time.tag = 3;
    time.backgroundColor = [UIColor clearColor];
    [contentView addSubview:time];
	
	UISwipeGestureRecognizer *swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(cellWasSwiped:)];
    [swipeRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
	[contentView addGestureRecognizer:swipeRecognizer];
    
    [self addSubview:contentView];
}

- (void)cellWasSwiped:(UISwipeGestureRecognizer *)recognizer
{
	UITableView * tableView = (UITableView *)self.superview;
    
    CGPoint location = [recognizer locationInView:tableView];
    NSIndexPath *swipedIndexPath = [tableView indexPathForRowAtPoint:location];
    
    NSLog(@"section:%d", swipedIndexPath.section);
    NSLog(@"row:%d", swipedIndexPath.row);
    
    NSInteger yPosition = 0;
    for(int i=0; i<swipedIndexPath.section; i++)
    {
        yPosition = yPosition + 44*[tableView numberOfRowsInSection:i];
    }
    yPosition = yPosition + 44*swipedIndexPath.row + 44*(swipedIndexPath.section+1);
    
    UIView *maskView = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,480)];
    maskView.backgroundColor = [UIColor clearColor];
    maskView.tag = 10;
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(maskViewTapped:)];
    [maskView addGestureRecognizer:tapRecognizer];
    
    UIView *deleteView = [[UIView alloc] initWithFrame:CGRectMake(279,yPosition,41,44)];
    deleteView.backgroundColor = [UIColor colorWithRed:233/255.0 green:227/255.0 blue:214/255.0 alpha:1.0];
	
	UIButton *deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(10,12,20,20)];
    [deleteButton setImage:[UIImage imageNamed:@"delete.png"] forState:UIControlStateNormal];
    [deleteButton addTarget:self action:@selector(notifyDeleteLocation:) forControlEvents:UIControlEventTouchDown];
    
    [deleteView addSubview:deleteButton];
    
    [maskView addSubview:deleteView];
    [tableView addSubview:maskView];
    
	id delegate = tableView.superview.nextResponder;
	
	NSIndexPath * myIndexPath = [tableView indexPathForCell:self];
    
    if ([delegate respondsToSelector:@selector(tableView:didSwipeCellAtIndexPath:)])
    {
        [delegate tableView:tableView didSwipeCellAtIndexPath:myIndexPath];
    }
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
}

- (IBAction)maskViewTapped:(id)sender
{
    UITableView * tableView = (UITableView *)self.superview;
    UIView *maskView = [tableView viewWithTag:10];
    [maskView removeFromSuperview];
}

@end
