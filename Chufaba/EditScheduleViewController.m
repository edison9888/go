//
//  EditScheduleViewController.m
//  Chufaba
//
//  Created by Perry on 13-2-2.
//  Copyright (c) 2013年 ChufabaAPP团队. All rights reserved.
//

#import "EditScheduleViewController.h"
#import "QuartzCore/QuartzCore.h"

@interface EditScheduleViewController ()

@end

@implementation EditScheduleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UINavigationBar *navBar = self.navigationController.navigationBar;
    navBar.layer.masksToBounds = NO;
    navBar.layer.shadowOffset = CGSizeMake(0, 1);
    navBar.layer.shadowRadius = 2;
    navBar.layer.shadowColor = [[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.3] CGColor];
    navBar.layer.shadowOpacity = 1;
    self.navigationItem.title = @"时间安排";

    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 7, 40, 30)];
    [backBtn setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backToPrevious:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = btn;
    
    UIButton *saveBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 7, 40, 30)];
    [saveBtn setImage:[UIImage imageNamed:@"done.png"] forState:UIControlStateNormal];
    [saveBtn addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *dBtn = [[UIBarButtonItem alloc] initWithCustomView:saveBtn];
    self.navigationItem.rightBarButtonItem = dBtn;
    
    //self.navigationItem.rightBarButtonItem.action = @selector(done);
    
    self.view.backgroundColor = [UIColor colorWithRed:244/255.0 green:241/255.0 blue:235/255.0 alpha:1.0];
    [self configureView];
    
    self.startInput.borderStyle = UITextBorderStyleNone;
    UIImage *sourceImage = [UIImage imageNamed:@"kuang.png"];
    UIImage *cappedImage = [sourceImage stretchableImageWithLeftCapWidth:8 topCapHeight:8];
    self.startInput.background = cappedImage;
    self.startInput.font = [UIFont fontWithName:@"Heiti SC" size:16];
    
    UIView *sPaddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 40)];
    self.startInput.leftView = sPaddingView;
    self.startInput.leftViewMode = UITextFieldViewModeAlways;
   
    UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height+44, 320, 216)];
    datePicker.tag = 13;
    datePicker.datePickerMode = UIDatePickerModeTime;
    datePicker.minuteInterval = 15;
    datePicker.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"];
    [self.view addSubview:datePicker];
    datePicker.frame = CGRectMake(0, self.view.bounds.size.height+44, 320, 216);
    [datePicker addTarget:self action:@selector(timeChanged:) forControlEvents:UIControlEventValueChanged];
    
    self.startInput.inputView = datePicker;
    
    [self.startInput becomeFirstResponder];
}

- (IBAction)backToPrevious:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)configureView
{
    if (self.start) {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"HH:mm"];
        self.startInput.text = [formatter stringFromDate:self.start];
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    UIDatePicker *datePicker = (UIDatePicker *)textField.inputView;
    if(textField == self.startInput){
        if (self.start) {
            [datePicker setDate:self.start];
        }
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return NO;
}

- (void)timeChanged:(id)sender
{
    UIDatePicker *picker = sender;
    
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:picker.date];
    NSInteger minutes = [components minute];
    
    // check if the minutes should be rounded
    NSInteger remainder = minutes % 15;
    if(remainder)
    {
        minutes += 15 - remainder;
        [components setMinute:minutes];
        picker.date = [calendar dateFromComponents:components];
    }
    
    self.start = picker.date;
    [self configureView];
}

-(IBAction)done:(id) sender
{
    [self.delegate didEditScheduleWithStart:self.start];
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.startInput) {
        [textField resignFirstResponder];
    }
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

@end
