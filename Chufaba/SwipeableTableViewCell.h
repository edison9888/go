//
//  SwipeableTableViewCell.h
//  Chufaba
//
//  Created by 张辛欣 on 13-3-7.
//  Copyright (c) 2013年 ChufabaAPP团队. All rights reserved.
//

#import <UIKit/UIKit.h>

//==========================================================
// - SwipeableTableViewController
//==========================================================

@interface SwipeableTableViewController : UITableViewController

- (BOOL)tableView:(UITableView *)tableView shouldSwipeCellAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView didSwipeCellAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface SwipeableTableViewCellView : UIView
@end

@interface SwipeableTableViewCell : UITableViewCell <UIGestureRecognizerDelegate>
{
    UIView * contentView;
}

@property (nonatomic, strong) UIButton *editButton;
@property (nonatomic, strong) UIButton *deleteButton;

@property (nonatomic, copy) NSString * text;

//- (void)drawContentView:(CGRect)rect;

@end
