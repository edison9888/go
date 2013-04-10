//
//  NIDropDown.m
//  出发吧
//
//  Created by 张辛欣 on 13-1-27.
//  Copyright (c) 2013年 出发吧APP团队. All rights reserved.
//

#import "NIDropDown.h"
#import "QuartzCore/QuartzCore.h"

@interface NIDropDown ()
@property(nonatomic, strong) UITableView *table;
@property(nonatomic, strong) UIButton *btnSender;
@property(nonatomic, retain) NSArray *list;
@end

@implementation NIDropDown
@synthesize table;
@synthesize btnSender;
@synthesize list;
@synthesize delegate;


- (id)showDropDown:(UIButton *)b withHeight:(CGFloat *)height withDays:(NSMutableArray *)arr {
    btnSender = b;
    self.table = (UITableView *)[super init];
    if (self) {
        CGRect btn = b.frame;
        
        self.frame = CGRectMake(btn.origin.x, btn.origin.y+btn.size.height+18, btn.size.width, 0);
        self.list = [NSArray arrayWithArray:arr];
        self.layer.masksToBounds = NO;
        self.layer.cornerRadius = 8;
        self.layer.shadowOffset = CGSizeMake(0, 4);
        self.layer.shadowRadius = 8;
        self.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.layer.shadowOpacity = 0.3;
        
        table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, btn.size.width, 0)];
        table.delegate = self;
        table.dataSource = self;
        table.layer.cornerRadius = 5;
        table.backgroundColor = [UIColor colorWithRed:44/255.0 green:145/255.0 blue:144/255.0 alpha:1.0];
        table.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        table.scrollEnabled = YES;
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView setAnimationDuration:0.2];
        self.frame = CGRectMake(btn.origin.x, btn.origin.y+btn.size.height+18, btn.size.width, *height);
        
        table.frame = CGRectMake(0, 0, btn.size.width, *height>240 ? 240:*height);

        [UIView commitAnimations];
        
        [b.superview.superview addSubview:self];
        [self addSubview:table];
    }
    return self;
}

-(void)hideDropDown:(UIButton *)b {
    CGRect btn = b.frame;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.2];
    self.frame = CGRectMake(btn.origin.x, btn.origin.y+btn.size.height+18, btn.size.width, 0);
    table.frame = CGRectMake(0, 0, btn.size.width, 0);
    [UIView commitAnimations];
}

-(void)hideDropDownWithoutAnimation:(UIButton *)b {
    CGRect btn = b.frame;
    self.frame = CGRectMake(btn.origin.x, btn.origin.y+btn.size.height, btn.size.width, 0);
    table.frame = CGRectMake(0, 0, btn.size.width, 0);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.list count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.text =[list objectAtIndex:indexPath.row];
    cell.textLabel.textColor = [UIColor colorWithRed:196/255.0 green:230/255.0 blue:184/255.0 alpha:1.0];
    cell.textLabel.font = [UIFont fontWithName:@"Heiti SC" size:16];
    cell.textLabel.highlightedTextColor = cell.textLabel.textColor;
    
    UIView * v = [[UIView alloc] init];
    v.backgroundColor = [UIColor colorWithRed:26/255.0 green:128/255.0 blue:128/255.0 alpha:1.0];
    cell.selectedBackgroundView = v;
    
    //add separator line
    if (indexPath.row > 0) {
        UIView *uplineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 1)];
        uplineView.backgroundColor = [UIColor colorWithRed:56/255.0 green:154/255.0 blue:154/255.0 alpha:1.0];
        [cell.contentView addSubview:uplineView];
    }
    
    if(indexPath.row < [list count]-1){
        UIView *bottomlineView = [[UIView alloc] initWithFrame:CGRectMake(0, 39, tableView.bounds.size.width, 1)];
        bottomlineView.backgroundColor = [UIColor colorWithRed:26/255.0 green:128/255.0 blue:128/255.0 alpha:1.0];
        [cell.contentView addSubview:bottomlineView];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self hideDropDown:btnSender];
    UITableViewCell *c = [tableView cellForRowAtIndexPath:indexPath];
    [btnSender setTitle:c.textLabel.text forState:UIControlStateNormal];
    [self.delegate niDropDownDelegateMethod:self selectRow:indexPath.row];
}

-(void)dealloc {

}

@end

