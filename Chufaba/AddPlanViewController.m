//
//  AddPlanViewController.m
//  出发吧
//
//  Created by kenzo on 13-1-16.
//  Copyright (c) 2013年 出发吧APP团队. All rights reserved.
//

#import "AddPlanViewController.h"
#import "Plan.h"

@interface AddPlanViewController ()

@end

@implementation AddPlanViewController

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
    
    //choose cover image part
    [self.coverImageView setImage:[UIImage imageNamed:@"photo_add.png"]];
    self.imgPickerController = [[UIImagePickerController alloc] init];
    UITapGestureRecognizer *imgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleImageTap:)];
    imgTap.numberOfTapsRequired = 1;
    imgTap.numberOfTouchesRequired = 1;
    self.imgPickerController.delegate = self;
    [self.coverImageView addGestureRecognizer:imgTap];
    
    //show duration picker part
    _durationPick = [[NSArray alloc]initWithObjects:@"1",@"2",@"3",@"4",@"5",@"6",@"7",nil];
    
    UIPickerView *durationPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height+44, 320, 216)];
    durationPicker.tag = 10;
    durationPicker.showsSelectionIndicator = YES;
    [self.view addSubview:durationPicker];
    
    self.durationInput.inputView = durationPicker;
    
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, 320, 44)];
    toolBar.tag = 11;
    toolBar.barStyle = UIBarStyleBlackTranslucent;
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissDurationPicker:)];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissDurationPicker:)];
    [toolBar setItems:[NSArray arrayWithObjects:cancelButton, spacer, doneButton, nil]];
    [self.view addSubview:toolBar];
    self.durationInput.inputAccessoryView = toolBar;
    
    self.durationInput.delegate = self;
    durationPicker.delegate = self;
    durationPicker.dataSource = self;
    durationPicker.frame = CGRectMake(0, self.view.bounds.size.height+44, 320, 216);
    
    //show datepicker part
    //CGRect toolbarTargetFrame = CGRectMake(0, self.view.bounds.size.height-216-44, 320, 44);
    //CGRect datePickerTargetFrame = CGRectMake(0, self.view.bounds.size.height-216, 320, 216);
    
    /*UIView *darkView = [[UIView alloc] initWithFrame:self.view.bounds];
    darkView.alpha = 0;
    darkView.backgroundColor = [UIColor blackColor];
    darkView.tag = 12;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissDatePicker:)];
    [darkView addGestureRecognizer:tapGesture];
    [self.view addSubview:darkView];*/
    
    UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height+44, 320, 216)];
    datePicker.tag = 13;
    datePicker.datePickerMode = UIDatePickerModeDate;
    [self.view addSubview:datePicker];
    self.dateInput.inputView = datePicker;
    
    UIToolbar *dateToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, 320, 44)];
    dateToolBar.tag = 14;
    dateToolBar.barStyle = UIBarStyleBlackTranslucent;
    UIBarButtonItem *dateSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *dateCancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissDatePicker:)];
    UIBarButtonItem *dateDoneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissDatePicker:)];
    [dateToolBar setItems:[NSArray arrayWithObjects:dateCancelButton, dateSpacer, dateDoneButton, nil]];
    [self.view addSubview:dateToolBar];
    self.dateInput.inputAccessoryView = dateToolBar;
    
    self.dateInput.delegate = self;
    datePicker.frame = CGRectMake(0, self.view.bounds.size.height+44, 320, 216);
    
    if(self.plan)
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        self.nameInput.text = self.plan.name;
        self.durationInput.text = [self.plan.duration stringValue];
        self.dateInput.text = [dateFormatter stringFromDate:self.plan.date];
    }
    
    //darkView.alpha = 0.5;
    

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void) viewDidAppear:(BOOL)animated {
    NSInteger defaultDuration;
    if(self.plan)
    {
        defaultDuration = [self.plan.duration intValue]-1;
        ((UIDatePicker *)[self.view viewWithTag:13]).date = self.plan.date;
    }
    else
    {
        defaultDuration = 2;
    }
    [(UIPickerView *)[self.view viewWithTag:10] selectRow:defaultDuration inComponent:0 animated:NO];
}

-(IBAction) done:(id) sender
{
    if ([self.dateInput.text length] == 0 || [self.durationInput.text length] == 0)
    {
        [Utility showAlert:@"Error" message:@"Validation Failed!"];
        return;
    }
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    if(self.plan != nil)
    {
        self.plan.name = self.nameInput.text;
        self.plan.duration = [f numberFromString:self.durationInput.text];
        //add something to prevent updating date if
        NSInteger daysBetween = [Utility daysBetweenDate:self.plan.date andDate:[(UIDatePicker *)self.dateInput.inputView date]];
        if(daysBetween)
        {
            self.plan.date = [(UIDatePicker *)self.dateInput.inputView date];
        }
        self.plan.image = self.coverImageView.image;
        [self.delegate addPlanViewController:self didEditTravelPlan:self.plan];
    }
    
    else
    {
        Plan *plan = [[Plan alloc] init];
        plan.name = self.nameInput.text;
        plan.duration = [f numberFromString:self.durationInput.text];
        plan.date = [(UIDatePicker *)self.dateInput.inputView date];
        plan.image = self.coverImageView.image;
        [self.delegate addPlanViewController:self didAddTravelPlan:plan];
    }
    
}

-(IBAction)cancel:(id)sender
{
    [self.delegate addPlanViewControllerDidCancel:self];
}

- (void)dismissDurationPicker:(id)sender {
    CGRect toolbarTargetFrame = CGRectMake(0, self.view.bounds.size.height, 320, 44);
    CGRect durationPickerTargetFrame = CGRectMake(0, self.view.bounds.size.height+44, 320, 216);
    [UIView beginAnimations:@"MoveOut" context:nil];
    [self.view viewWithTag:10].frame = durationPickerTargetFrame;
    [self.view viewWithTag:11].frame = toolbarTargetFrame;
    [UIView setAnimationDelegate:self];
    //[UIView setAnimationDuration:2.0];
    
    if([sender isKindOfClass:[UIBarButtonItem class]])
    {
        UIBarButtonItem *btn = (UIBarButtonItem *)sender;
        UIToolbar *toolbar = (UIToolbar *)self.durationInput.inputAccessoryView;
        if(btn == [toolbar.items objectAtIndex:2])
        {
            UIPickerView *currentPicker = (UIPickerView *)self.durationInput.inputView;
            NSInteger row = [currentPicker selectedRowInComponent:0];
            self.durationInput.text = [_durationPick objectAtIndex:row];
        }
    }
    
    [UIView setAnimationDidStopSelector:@selector(removeDurationPickerViews:)];
    [self.view endEditing:TRUE];
    [UIView commitAnimations];
}

- (void)removeDurationPickerViews:(id)object {
    //[UIView beginAnimations:@"curldown" context:nil];
    [self.durationInput.inputView removeFromSuperview];
    [self.durationInput.inputAccessoryView removeFromSuperview];
}

- (void)dismissDatePicker:(id)sender {
    CGRect toolbarTargetFrame = CGRectMake(0, self.view.bounds.size.height, 320, 44);
    CGRect datePickerTargetFrame = CGRectMake(0, self.view.bounds.size.height+44, 320, 216);
    [UIView beginAnimations:@"MoveOut" context:nil];
    [self.view viewWithTag:13].frame = datePickerTargetFrame;
    [self.view viewWithTag:14].frame = toolbarTargetFrame;
    [UIView setAnimationDelegate:self];
    //[UIView setAnimationDuration:2.0];
    
    if([sender isKindOfClass:[UIBarButtonItem class]])
    {
        UIBarButtonItem *btn = (UIBarButtonItem *)sender;
        UIToolbar *toolbar = (UIToolbar *)self.dateInput.inputAccessoryView;
        if(btn == [toolbar.items objectAtIndex:2])
        {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
            [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
            UIDatePicker *currentDatePicker = (UIDatePicker *)self.dateInput.inputView;
            NSDate *pickedDate = currentDatePicker.date;
            self.dateInput.text = [dateFormatter stringFromDate:pickedDate];
        }
    }
    
    [UIView setAnimationDidStopSelector:@selector(removeViews:)];
    [self.view endEditing:TRUE];
    [UIView commitAnimations];
}

- (void)removeViews:(id)object {
    //[[self.view viewWithTag:12] removeFromSuperview];
    [self.dateInput.inputView removeFromSuperview];
    [self.dateInput.inputAccessoryView removeFromSuperview];
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}
-(NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [_durationPick count];
}
-(NSString*) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [_durationPick objectAtIndex:row];
}

-(void)handleImageTap:(UITapGestureRecognizer *)sender{
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum])
    {
        NSArray *availableMediaTypeArr = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
        
        self.imgPickerController.mediaTypes = availableMediaTypeArr;
        [self presentViewController:self.imgPickerController animated:YES completion:NULL];
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *selectedImg = [info valueForKey:UIImagePickerControllerOriginalImage];
    self.coverImageView.image = selectedImg;
    [self dismissViewControllerAnimated:YES completion:NULL];
    //[self dismissModalViewControllerAnimated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ((textField == self.dateInput) || (textField == self.durationInput) || (textField == self.nameInput)) {
        [textField resignFirstResponder];
    }
    return YES;
}

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    if ([[segue identifier] isEqualToString:@"ReturnInput"]) {
//        if ([self.dateInput.text length] || [self.durationInput.text length]) {
//            TravelPlan *plan;
//            NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
//            [f setNumberStyle:NSNumberFormatterDecimalStyle];
//            NSNumber * myNumber = [f numberFromString:self.durationInput.text];
//            NSDate *startDate = [(UIDatePicker *)self.dateInput.inputView date];
//            plan = [[TravelPlan alloc] initWithName:self.nameInput.text duration:myNumber date:startDate image:self.coverImageView.image];
//            self.plan = plan;
//        }
//    }
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
