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
    
    [self.feedbackTextView becomeFirstResponder];
    
    [self setTitle:@"建议反馈"];
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
    [self.navigationController popViewControllerAnimated:YES];
}

@end