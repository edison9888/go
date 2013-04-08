//
//  EditScheduleViewController.m
//  Chufaba
//
//  Created by Perry on 13-2-2.
//  Copyright (c) 2013年 ChufabaAPP团队. All rights reserved.
//

#import "EditScheduleViewController.h"

@interface EditScheduleViewController ()

@property NSInteger selectedRow;

@end

@implementation EditScheduleViewController

- (void)setTitle:(NSString *)title
{
    [super setTitle:title];
    UILabel *titleView = (UILabel *)self.navigationItem.titleView;
    if (!titleView) {
        titleView = [[UILabel alloc] initWithFrame:CGRectZero];
        titleView.backgroundColor = [UIColor clearColor];
        titleView.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:20];
        titleView.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        
        titleView.textColor = [UIColor colorWithRed:196/255.0 green:230/255.0 blue:184/255.0 alpha:1.0];
        
        self.navigationItem.titleView = titleView;
    }
    titleView.text = title;
    [titleView sizeToFit];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

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
    self.startInput.background = [UIImage imageNamed:@"kuang.png"];
    self.startInput.font = [UIFont fontWithName:@"Heiti SC" size:16];
    
    UIView *sPaddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 40)];
    self.startInput.leftView = sPaddingView;
    self.startInput.leftViewMode = UITextFieldViewModeAlways;
   
    UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height+44, 320, 216)];
    datePicker.tag = 13;
    datePicker.datePickerMode = UIDatePickerModeTime;
    datePicker.minuteInterval = 15;
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
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterNoStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    if (self.start) {
        self.startInput.text = [formatter stringFromDate:self.start];
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    UIDatePicker *datePicker = (UIDatePicker *)textField.inputView;
    if(textField == self.startInput){
        //self.selectedRow = 0;
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
//    if (self.selectedRow == 0) {
//        self.start = picker.date;
//    }else if(self.selectedRow == 1){
//        self.end = picker.date;
//    }
    self.start = picker.date;
    [self configureView];
}

-(IBAction)done:(id) sender
{
    [self.delegate didEditScheduleWithStart:self.start AndEnd:self.end];
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
