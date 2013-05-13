//
//  FeedbackViewController.m
//  Chufaba
//
//  Created by 张辛欣 on 13-4-11.
//  Copyright (c) 2013年 ChufabaAPP团队. All rights reserved.
//

#import "FeedbackViewController.h"
#import "Utility.h"
#import "JsonFetcher.h"

@interface FeedbackViewController ()

@end

@implementation FeedbackViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 7, 40, 30)];
    [backBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backBtn setImage:[UIImage imageNamed:@"back_click"] forState:UIControlStateHighlighted];
    [backBtn addTarget:self action:@selector(backToPrevious:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    
    UIButton *addBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 7, 40, 30)];
    [addBtn setImage:[UIImage imageNamed:@"done.png"] forState:UIControlStateNormal];
    [addBtn addTarget:self action:@selector(feedback:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:addBtn];
    
    self.view.backgroundColor = [UIColor colorWithRed:244/255.0 green:241/255.0 blue:235/255.0 alpha:1.0];
    
    self.feedbackTextView.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:16];
    self.feedbackTextView.textColor = [UIColor colorWithRed:77/255.0 green:73/255.0 blue:69/255.0 alpha:1.0];
    
    self.emailTextField.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:16];
    self.emailTextField.textColor = [UIColor colorWithRed:77/255.0 green:73/255.0 blue:69/255.0 alpha:1.0];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.emailTextField.text = [userDefaults objectForKey:@"feedback_email"];
    
    [self.feedbackTextView becomeFirstResponder];
    self.navigationItem.title = @"建议反馈";
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

- (void)feedback:(id)sender
{
    if (self.feedbackTextView.text.length == 0) {
        [Utility showAlert:nil message:@"您还没有提任何意见哦..."];
        return;
    }
    JSONFetcher *fetcher = [[JSONFetcher alloc]
               initWithURLString:@"http://chufaba.me:3000/feedbacks" 
               body:[NSString stringWithFormat:@"feedback%%5Bcontent%%5D=%@&feedback%%5Bemail%%5D=%@", self.feedbackTextView.text, self.emailTextField.text]
               receiver:nil
               action:nil];
    fetcher.showAlerts = NO;
    [fetcher start];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:self.emailTextField.text forKey:@"feedback_email"];
    [userDefaults synchronize];

    [self.navigationController popViewControllerAnimated:YES];
}

@end