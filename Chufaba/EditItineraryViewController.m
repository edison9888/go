//
//  EditItineraryViewController.m
//  Chufaba
//
//  Created by 张辛欣 on 13-6-24.
//  Copyright (c) 2013年 ChufabaAPP团队. All rights reserved.
//

#import "EditItineraryViewController.h"
#import "Location.h"
#import <QuartzCore/QuartzCore.h>

@interface EditItineraryViewController ()
{
    BOOL sequenceChanged;
}

@end

@implementation EditItineraryViewController

#define TAG_LINE_VIEW 10000
#define TAG_DETAIL_INDICATOR 10001

- (NSDateFormatter *)dateFormatter {
    if (! _dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = @"YYYY-MM-d EEEE";
        NSLocale *cnLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
        _dateFormatter.locale = cnLocale;
    }
    return _dateFormatter;
}

- (NSCalendar *)gregorian {
    if (! _gregorian) {
        _gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    }
    return _gregorian;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.categoryImage = [NSDictionary dictionaryWithObjectsAndKeys:@"sight40", @"景点", @"food40", @"美食", @"hotel40", @"住宿", @"more40", @"其它", nil];
    
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 7, 40, 30)];
    [backBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backBtn setImage:[UIImage imageNamed:@"back_click"] forState:UIControlStateHighlighted];
    [backBtn addTarget:self action:@selector(backToPrevious:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = btn;
    
    self.navigationItem.title = @"地点排序";
    
    self.tableView.rowHeight = 44.0f;
    self.tableView.sectionHeaderHeight = 44.0f;
    self.tableView.backgroundColor = [UIColor colorWithRed:244/255.0 green:241/255.0 blue:235/255.0 alpha:1.0];

    self.tableView.editing = YES;
}

- (IBAction)backToPrevious:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    
    if(sequenceChanged)
    {
        [self.delegate notifyItinerayToReload];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.singleDayMode ? 1 : [_plan.duration integerValue];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_plan getLocationCountFromDay:[self getDayBySection:section]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TravelLocationCell";
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:16];
        cell.textLabel.textColor = [UIColor colorWithRed:72/255.0 green:70/255.0 blue:66/255.0 alpha:1.0];
        cell.detailTextLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:12];
        cell.detailTextLabel.textColor = [UIColor colorWithRed:153/255.0 green:150/255.0 blue:145/255.0 alpha:1.0];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    Location *locationAtIndex = [self getLocationAtIndexPath:indexPath];
    cell.textLabel.text = [locationAtIndex getTitle];
    if (locationAtIndex.visitBegin)
    {
        cell.detailTextLabel.text = locationAtIndex.visitBegin;
    }
    else
    {
        cell.detailTextLabel.text = @"";
    }
    cell.imageView.image = [UIImage imageNamed:[self.categoryImage objectForKey: locationAtIndex.category]];
    
    if([cell.contentView viewWithTag:TAG_DETAIL_INDICATOR])
    {
        [[cell.contentView viewWithTag:TAG_DETAIL_INDICATOR] removeFromSuperview];
    }
    
    if(locationAtIndex.detail.length)
    {
        CGSize expectedLabelSize = [cell.textLabel.text sizeWithFont:cell.textLabel.font constrainedToSize:CGSizeMake(200,18) lineBreakMode:cell.textLabel.lineBreakMode];
        
        UIImageView *detailIndicator = [[UIImageView alloc] initWithFrame:CGRectMake(expectedLabelSize.width+44, 8, 12, 12)];
        detailIndicator.image = [UIImage imageNamed:@"detail_indi"];
        detailIndicator.tag = TAG_DETAIL_INDICATOR;
        [cell.contentView addSubview:detailIndicator];
    }
    
    if([cell.contentView viewWithTag:TAG_LINE_VIEW])
    {
        [[cell.contentView viewWithTag:TAG_LINE_VIEW] removeFromSuperview];
    }
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
    lineView.backgroundColor = [UIColor whiteColor];
    lineView.opaque = YES;
    [cell.contentView addSubview:lineView];
    if(locationAtIndex.whichday.integerValue == ([_plan.duration integerValue] - 1) || [_plan hasNextLocation:locationAtIndex])
    {
        lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 43, 320, 1)];
        lineView.opaque = YES;
        lineView.tag = TAG_LINE_VIEW;
        lineView.backgroundColor = [UIColor colorWithRed:227/255.0 green:219/255.0 blue:204/255.0 alpha:1.0];
        [cell.contentView addSubview:lineView];
    }
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSInteger dayValue = self.singleDayMode ? [self.daySelected intValue] : section;
    
    NSDateComponents *dayComponents = [self.gregorian components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:_plan.date];
    NSInteger theDay = [dayComponents day];
    NSInteger theMonth = [dayComponents month];
    NSInteger theYear = [dayComponents year];
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:theDay];
    [components setMonth:theMonth];
    [components setYear:theYear];
    NSDate *thisDate = [self.gregorian dateFromComponents:components];
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setDay:dayValue];
    NSDate *sectionDate = [self.gregorian dateByAddingComponents:offsetComponents toDate:thisDate options:0];
    
    UIView *myView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)];
    UIColor *background = [[UIColor alloc] initWithPatternImage:[[UIImage imageNamed:@"bar_h"] stretchableImageWithLeftCapWidth:8 topCapHeight:0]];
    myView.backgroundColor = background;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 6.0, 250.0, 20.0)] ;
    label.textColor = [UIColor colorWithRed:72/255.0 green:70/255.0 blue:66/255.0 alpha:1.0];
    label.shadowColor = [UIColor colorWithRed:244/255.0 green:241/255.0 blue:235/255.0 alpha:1.0];
    label.shadowOffset = CGSizeMake(0, 1);
    label.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:16];
    label.backgroundColor = [UIColor clearColor];
    
    UILabel *wLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 24.0, 250.0, 20.0)] ;
    wLabel.textColor = [UIColor colorWithRed:153/255.0 green:150/255.0 blue:145/255.0 alpha:1.0];
    wLabel.shadowColor = [UIColor colorWithRed:244/255.0 green:241/255.0 blue:235/255.0 alpha:1.0];
    wLabel.shadowOffset = CGSizeMake(0, 1);
    wLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:12];
    wLabel.backgroundColor = [UIColor clearColor];
    wLabel.text = [self.dateFormatter stringFromDate:sectionDate];;
    
    label.text = [NSString stringWithFormat:@"第%d天", dayValue+1];
    
    myView.layer.shadowPath = [UIBezierPath bezierPathWithRect:myView.bounds].CGPath;
    myView.layer.shadowOffset = CGSizeMake(0, 1);
    myView.layer.shadowRadius = 0.4;
    myView.layer.shadowColor = [[UIColor colorWithRed:189/255.0 green:176/255.0 blue:153/255.0 alpha:1.0] CGColor];
    myView.layer.shadowOpacity = 1;
    myView.layer.shouldRasterize = YES;
    myView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    [myView addSubview:label];
    [myView addSubview:wLabel];
    return myView;
}

-(Location *)getLocationAtIndexPath:(NSIndexPath *)indexPath
{
    return [_plan getLocationFromDay:[self getDayBySection:indexPath.section] AtIndex:indexPath.row];
}

-(NSUInteger)getDayBySection:(NSInteger)section
{
    NSUInteger day = 0;
    if (self.singleDayMode) {
        day = [_daySelected integerValue];
    } else {
        day = section;
    }
    return day;
}

-(void) updateFooterView
{
    if([_plan getLocationCountFromDay:([_plan.duration integerValue] - 1)] > 0)
    {
        if(!self.tableView.tableFooterView)
        {
            UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 1)];
            footerView.backgroundColor = [UIColor whiteColor];
            self.tableView.tableFooterView = footerView;
        }
    }
    else
    {
        if(self.tableView.tableFooterView)
        {
            self.tableView.tableFooterView = NULL;
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    sequenceChanged = YES;
    [_plan moveThisLocation:[self getLocationAtIndexPath:fromIndexPath] ToThatLocation:[self getLocationAtIndexPath:toIndexPath]];
    [_plan persistentReorderFromThisLocation:[self getLocationAtIndexPath:fromIndexPath] ToThatLocation:[self getLocationAtIndexPath:toIndexPath]];
    [self updateFooterView];
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

@end
