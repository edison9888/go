//
//  ItineraryViewTableViewCell.h
//  Chufaba
//
//  Created by 张辛欣 on 13-3-26.
//  Copyright (c) 2013年 ChufabaAPP团队. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SwipeableViewController : UIViewController

- (void)tableView:(UITableView *)tableView didSwipeCellAtIndexPath:(NSIndexPath *)indexPath;
- (void)deleteLocation;

@end

@interface ItineraryViewTableViewCell : UITableViewCell <UIGestureRecognizerDelegate>
{
    UIView * contentView;
}

@end
