//
//  itineraryBudgetViewController.m
//  出发吧
//
//  Created by Perry on 13-1-29.
//  Copyright (c) 2013年 出发吧APP团队. All rights reserved.
//

#import "EditCostViewController.h"

@interface EditCostViewController ()

@end

@implementation EditCostViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.amountInput becomeFirstResponder];
    self.navigationItem.rightBarButtonItem.action = @selector(done);
    
    self.view.backgroundColor = [UIColor colorWithRed:244/255.0 green:241/255.0 blue:235/255.0 alpha:1.0];
    
    self.amountInput.borderStyle = UITextBorderStyleNone;
    self.amountInput.background = [UIImage imageNamed:@"kuang.png"];
    self.amountInput.font = [UIFont fontWithName:@"Heiti SC" size:16];
    self.currencyInput.borderStyle = UITextBorderStyleNone;
    self.currencyInput.background = [UIImage imageNamed:@"kuang.png"];
    self.currencyInput.font = [UIFont fontWithName:@"Heiti SC" size:16];
    
    UIView *aPaddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 40)];
    self.amountInput.leftView = aPaddingView;
    self.amountInput.leftViewMode = UITextFieldViewModeAlways;
    UIView *cPaddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 40)];
    self.currencyInput.leftView = cPaddingView;
    self.currencyInput.leftViewMode = UITextFieldViewModeAlways;
    
    if(self.amount && [self.amount intValue] != 0){
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        self.amountInput.text = [formatter stringFromNumber:self.amount];
    }
    
    //show duration picker part
    self.currencyOptions = [[NSArray alloc]initWithObjects:@"人民币 - RMB",@"美元 - USD",@"欧元 - EUR",@"英镑 - GBP",@"日元 - JPY",@"澳元 - AUD",@"泰铢 - THB",nil];
    
    NSInteger selected = 0;
    if(self.currency){
        for (NSString *currency in self.currencyOptions) {
            if ([[currency substringFromIndex:[currency length] - 3] isEqualToString:self.currency]) {
                self.currencyInput.text = currency;
                selected = [self.currencyOptions indexOfObject:currency];
                break;
            }
        }
    }else{
        self.currencyInput.text = [self.currencyOptions objectAtIndex:0];
    }
    
    UIPickerView *currencyPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height+44, 320, 216)];
    currencyPicker.tag = 10;
    currencyPicker.showsSelectionIndicator = YES;
    [self.view addSubview:currencyPicker];
    
    self.currencyInput.inputView = currencyPicker;
    
    currencyPicker.delegate = self;
    currencyPicker.dataSource = self;
    currencyPicker.frame = CGRectMake(0, self.view.bounds.size.height+44, 320, 216);
    [currencyPicker selectRow:selected inComponent:0 animated:FALSE];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)done
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber *amount = [formatter numberFromString:self.amountInput.text];
    NSString *currency = [self.currencyInput.text substringFromIndex:[self.currencyInput.text length] - 3];
    [self.delegate didEditCostWithAmount:amount AndCurrency:currency];
    [self.navigationController popViewControllerAnimated:YES];
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}
-(NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [self.currencyOptions count];
}
-(NSString*) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [self.currencyOptions objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.currencyInput.text = [self.currencyOptions objectAtIndex:row];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ((textField == self.amountInput) || (textField == self.currencyInput)) {
        [textField resignFirstResponder];
    }
    return YES;
}

@end
