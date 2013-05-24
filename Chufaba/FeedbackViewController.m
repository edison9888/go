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
    
    self.feedbackTextView = [[UIPlaceHolderTextView alloc] initWithFrame:CGRectMake(10, 10, 300, 100)];
    self.feedbackTextView.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:16];
    self.feedbackTextView.textColor = [UIColor colorWithRed:77/255.0 green:73/255.0 blue:69/255.0 alpha:1.0];
    
    self.feedbackTextView.backgroundColor = [UIColor clearColor];
    UIImageView *borderView = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, 300, 100)];
    borderView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    UIImage *textViewImage = [[UIImage imageNamed:@"kuang"] stretchableImageWithLeftCapWidth:8 topCapHeight:8];
    borderView.image = textViewImage;
    [self.feedbackTextView addSubview: borderView];
    [self.feedbackTextView sendSubviewToBack: borderView];
    
    self.emailTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 120, 300, 40)];
    self.emailTextField.background = [[UIImage imageNamed:@"kuang"] stretchableImageWithLeftCapWidth:8 topCapHeight:8];
    self.emailTextField.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:16];
    self.emailTextField.textColor = [UIColor colorWithRed:77/255.0 green:73/255.0 blue:69/255.0 alpha:1.0];
    self.emailTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.emailTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 40)];
    leftView.backgroundColor = [UIColor clearColor];
    self.emailTextField.leftView = leftView;
    self.emailTextField.leftViewMode = UITextFieldViewModeAlways;
    self.emailTextField.placeholder = @"Email";
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.emailTextField.text = [userDefaults objectForKey:@"feedback_email"];
    
    [self.feedbackTextView becomeFirstResponder];
    [self.view addSubview:self.feedbackTextView];
    [self.view addSubview:self.emailTextField];
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
    
    if(self.emailTextField.text.length != 0 && ![self validateEmailWithString:self.emailTextField.text])
    {
        [Utility showAlert:nil message:@"Email格式不对哦..."];
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
    [Utility showAlert:nil message:@"您的宝贵意见已收到，感谢^_^"];
}

- (BOOL)validateEmailWithString:(NSString*)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

@end