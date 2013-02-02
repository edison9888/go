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
    self.transportInput.text = self.transportation;
    
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
    [self.transportInput becomeFirstResponder];
}

- (void)done
{
    [self.delegate didEditTransport:self.transportInput.text];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
