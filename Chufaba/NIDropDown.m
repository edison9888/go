//
//  NIDropDown.m
//  出发吧
//
//  Created by 张辛欣 on 13-1-27.
//  Copyright (c) 2013年 出发吧APP团队. All rights reserved.
//

#import "NIDropDown.h"
#import "QuartzCore/QuartzCore.h"
#import "DropDownCell.h"

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
        self.layer.shadowOffset = CGSizeMake(0, 10);
        self.layer.shadowRadius = 8;
        self.layer.shadowOpacity = 0.3;
        
        table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, btn.size.width, 0)];
        table.delegate = self;
        table.dataSource = self;
        table.layer.cornerRadius = 5;
        table.backgroundColor = [UIColor colorWithRed:44/255.0 green:145/255.0 blue:144/255.0 alpha:1.0];
        table.separatorStyle = UITableViewCellSeparatorStyleNone;
        table.scrollEnabled = YES;
        
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, btn.size.width, 1)];
        headerView.backgroundColor = [UIColor colorWithRed:26/255.0 green:128/255.0 blue:128/255.0 alpha:1.0];
        table.tableHeaderView = headerView;
        
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, btn.size.width, 1)];
        footerView.backgroundColor = [UIColor colorWithRed:56/255.0 green:154/255.0 blue:154/255.0 alpha:1.0];
        table.tableFooterView = footerView;
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView setAnimationDuration:0.2];
        self.frame = CGRectMake(btn.origin.x, btn.origin.y+btn.size.height+18, btn.size.width, *height);
        
        table.frame = CGRectMake(0, 0, btn.size.width, *height>320 ? 320:*height);

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
    
    DropDownCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[DropDownCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text =[list objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self hideDropDownWithoutAnimation:btnSender];
    UITableViewCell *c = [tableView cellForRowAtIndexPath:indexPath];
    [btnSender setTitle:c.textLabel.text forState:UIControlStateNormal];
    [self.delegate niDropDownDelegateMethod:self selectRow:indexPath.row];
}

-(void)dealloc {

}

@end

