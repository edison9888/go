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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.navigationItem.rightBarButtonItem.action = @selector(done);
    [self configureView];
    
    UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height+44, 320, 216)];
    datePicker.tag = 13;
    datePicker.datePickerMode = UIDatePickerModeTime;
    [self.view addSubview:datePicker];
    datePicker.frame = CGRectMake(0, self.view.bounds.size.height+44, 320, 216);
    [datePicker addTarget:self action:@selector(timeChanged:) forControlEvents:UIControlEventValueChanged];
    
    self.startInput.inputView = datePicker;
    self.endInput.inputView = datePicker;
    self.startInput.delegate = self;
    self.endInput.delegate = self;
    
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
    if (self.end){
        self.endInput.text = [formatter stringFromDate:self.end];
    }else if(self.start){
        self.end = [self.start dateByAddingTimeInterval:3600];
        self.endInput.text = [formatter stringFromDate:self.end];
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
    }else if (textField == self.endInput){
        self.selectedRow = 1;
        if (self.end) {
            [datePicker setDate:self.end];
        }
    }
    return YES;
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
    if ((textField == self.startInput) || (textField == self.endInput)) {
        [textField resignFirstResponder];
    }
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
