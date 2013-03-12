//
//  itineraryTransportViewController.m
//  出发吧
//
//  Created by Perry on 13-1-28.
//  Copyright (c) 2013年 出发吧APP团队. All rights reserved.
//

#import "EditTransportViewController.h"

@interface EditTransportViewController ()

@end

@implementation EditTransportViewController

#define TAG_TEXTVIEW 1

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"交通";
    
    UITextView *textView = [[UITextView alloc] initWithFrame:self.view.bounds];
    textView.backgroundColor = [UIColor colorWithRed:244/255.0 green:241/255.0 blue:235/255.0 alpha:1.0];
    textView.tag = TAG_TEXTVIEW;
    textView.delegate = self;
    textView.font = [UIFont systemFontOfSize:17];
    [self.view addSubview:textView];
	textView.text = self.transportation;
    
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editTransport)];
    self.navigationItem.rightBarButtonItem = editButton;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    self.navigationItem.rightBarButtonItem = doneButton;
}

- (void)editTransport
{
    [[self textView] becomeFirstResponder];
}

- (void)done
{
    [self.delegate didEditTransport:[self textView].text];
    [self.navigationController popViewControllerAnimated:YES];
}

- (UITextView *)textView
{
    return (UITextView *)[self.view viewWithTag:TAG_TEXTVIEW];
}

@end
