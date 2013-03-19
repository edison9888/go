//
//  itineraryTransportViewController.m
//  出发吧
//
//  Created by Perry on 13-1-28.
//  Copyright (c) 2013年 出发吧APP团队. All rights reserved.
//

#import "ShowLocationInfoController.h"

@interface ShowLocationInfoController ()

@end

@implementation ShowLocationInfoController

#define TAG_TEXTVIEW 1

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITextView *textView = [[UITextView alloc] initWithFrame:self.view.bounds];
    textView.backgroundColor = [UIColor colorWithRed:244/255.0 green:241/255.0 blue:235/255.0 alpha:1.0];
    textView.tag = TAG_TEXTVIEW;
    textView.editable = false;
    textView.font = [UIFont systemFontOfSize:17];
    [self.view addSubview:textView];
	textView.text = self.content;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
