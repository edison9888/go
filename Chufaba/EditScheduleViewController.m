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

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.navigationItem.rightBarButtonItem.action = @selector(done);
    
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
    [self.view addSubview:datePicker];
    datePicker.frame = CGRectMake(0, self.view.bounds.size.height+44, 320, 216);
    [datePicker addTarget:self action:@selector(timeChanged:) forControlEvents:UIControlEventValueChanged];
    
    self.startInput.inputView = datePicker;
    
    [self.startInput becomeFirstResponder];
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
        self.selectedRow = 0;
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
    if (self.selectedRow == 0) {
        self.start = picker.date;
    }else if(self.selectedRow == 1){
        self.end = picker.date;
    }
    [self configureView];
}

- (void)done
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
