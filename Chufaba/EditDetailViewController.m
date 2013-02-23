//
//  EditDetailViewController.m
//  Chufaba
//
//  Created by Perry on 13-2-2.
//  Copyright (c) 2013年 ChufabaAPP团队. All rights reserved.
//

#import "EditDetailViewController.h"

@interface EditDetailViewController ()

@end

@implementation EditDetailViewController

#define TAG_TEXTVIEW 1

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"备注";
    
    UITextView *textView = [[UITextView alloc] initWithFrame:self.view.bounds];
    textView.tag = TAG_TEXTVIEW;
    textView.delegate = self;
    textView.font = [UIFont systemFontOfSize:17];
    [self.view addSubview:textView];
	textView.text = self.detail;
    
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editDetail)];
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

- (void)editDetail
{
    [[self textView] becomeFirstResponder];
}

- (void)done
{
    [self.delegate didEditDetail:[self textView].text];
    [self.navigationController popViewControllerAnimated:YES];
}

- (UITextView *)textView
{
    return (UITextView *)[self.view viewWithTag:TAG_TEXTVIEW];
}

@end
