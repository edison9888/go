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

    [self setTitle:@"备注"];
    
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 7, 40, 30)];
    [backBtn setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backToPrevious:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = btn;
    
    UITextView *textView = [[UITextView alloc] initWithFrame:self.view.bounds];
    textView.tag = TAG_TEXTVIEW;
    textView.backgroundColor = [UIColor colorWithRed:244/255.0 green:241/255.0 blue:235/255.0 alpha:1.0];
    textView.delegate = self;
    textView.font = [UIFont systemFontOfSize:17];
    [self.view addSubview:textView];
	textView.text = self.detail;
    
    UIButton *editBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 7, 40, 30)];
    [editBtn setImage:[UIImage imageNamed:@"edittext.png"] forState:UIControlStateNormal];
    [editBtn addTarget:self action:@selector(editDetail) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *eBtn = [[UIBarButtonItem alloc] initWithCustomView:editBtn];
    self.navigationItem.rightBarButtonItem = eBtn;
}

- (IBAction)backToPrevious:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    UIButton *doneBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 7, 40, 30)];
    [doneBtn setImage:[UIImage imageNamed:@"done.png"] forState:UIControlStateNormal];
    [doneBtn addTarget:self action:@selector(done) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *dBtn = [[UIBarButtonItem alloc] initWithCustomView:doneBtn];
    self.navigationItem.rightBarButtonItem = dBtn;
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
