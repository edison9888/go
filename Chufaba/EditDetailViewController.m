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
	// Do any additional setup after loading the view.
    self.detailInput.text = self.detail;
    
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
    [self.detailInput becomeFirstResponder];
}

- (void)done
{
    [self.delegate didEditDetail:self.detailInput.text];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
