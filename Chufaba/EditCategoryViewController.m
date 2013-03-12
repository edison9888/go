//
//  EditCategoryViewController.m
//  Chufaba
//
//  Created by Perry on 13-2-2.
//  Copyright (c) 2013年 ChufabaAPP团队. All rights reserved.
//

#import "EditCategoryViewController.h"

@interface EditCategoryViewController ()

@end

@implementation EditCategoryViewController

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
    
    self.view.backgroundColor = [UIColor colorWithRed:244/255.0 green:241/255.0 blue:235/255.0 alpha:1.0];
    self.title = @"地点类型";
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    self.navigationItem.rightBarButtonItem = doneButton;
    
    self.categoryOptions = [[NSArray alloc]initWithObjects:@"景点",@"美食",@"娱乐",@"住宿",@"交通",@"其它",nil];
    
    UIPickerView *categoryPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, 320, 216)];
    categoryPicker.showsSelectionIndicator = YES;
    [self.view addSubview:categoryPicker];
    categoryPicker.delegate = self;
    categoryPicker.dataSource = self;
    categoryPicker.frame = CGRectMake(0, 0, 320, 216);

    if(self.category){
        NSInteger selected = [self.categoryOptions indexOfObject:self.category];
        [categoryPicker selectRow:selected inComponent:0 animated:FALSE];
    }
    [categoryPicker becomeFirstResponder];
}

- (void)done
{
    [self.delegate didEditCategory:self.category];
    [self.navigationController popViewControllerAnimated:YES];
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}
-(NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [self.categoryOptions count];
}
-(NSString*) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [self.categoryOptions objectAtIndex:row];
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.category = [self.categoryOptions objectAtIndex:row];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
