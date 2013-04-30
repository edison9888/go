//
//  AddPlanViewController.m
//  出发吧
//
//  Created by kenzo on 13-1-16.
//  Copyright (c) 2013年 出发吧APP团队. All rights reserved.
//

#import "AddPlanViewController.h"
#import "Plan.h"
#import "QuartzCore/QuartzCore.h"

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

- (NSDateFormatter *)dateFormatter {
    if (! _dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [_dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    }
    return _dateFormatter;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UINavigationBar *navBar = self.navigationController.navigationBar;
    navBar.layer.shadowPath = [UIBezierPath bezierPathWithRect:navBar.bounds].CGPath;
    navBar.layer.masksToBounds = NO;
    navBar.layer.shadowOffset = CGSizeMake(0, 1);
    navBar.layer.shadowRadius = 2;
    navBar.layer.shadowColor = [[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.3] CGColor];
    navBar.layer.shadowOpacity = 1;
    navBar.layer.shouldRasterize = YES;
    navBar.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 7, 40, 30)];
    [cancelBtn setImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *cBtn = [[UIBarButtonItem alloc] initWithCustomView:cancelBtn];
    self.navigationItem.leftBarButtonItem = cBtn;
    
    UIButton *saveBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 7, 40, 30)];
    [saveBtn setImage:[UIImage imageNamed:@"done"] forState:UIControlStateNormal];
    [saveBtn addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *dBtn = [[UIBarButtonItem alloc] initWithCustomView:saveBtn];
    self.navigationItem.rightBarButtonItem = dBtn;
    
    //self.destinationInput
    UIImageView *accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"detailsmall"]];
    accessoryView.frame = CGRectMake(190, 16, 9, 12);
    [self.destinationInput addSubview:accessoryView];
    [self.destinationInput bringSubviewToFront:accessoryView];
    
    
    self.view.backgroundColor = [UIColor colorWithRed:244/255.0 green:241/255.0 blue:235/255.0 alpha:1.0];
    
    //choose cover image part
    if(self.plan.image)
    {
        self.coverImageView.image = self.plan.image;
    }
    else
    {
        defaultCover = [UIImage imageNamed:@"plan_cover"];
        self.coverImageView.image = defaultCover;
    }
    
    UITapGestureRecognizer *imgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleImageTap:)];
    imgTap.numberOfTapsRequired = 1;
    imgTap.numberOfTouchesRequired = 1;
    [self.coverImageView addGestureRecognizer:imgTap];

    _durationPick = [[NSMutableArray alloc] initWithCapacity:100];
    for (int i = 1; i < 101; i++)
    {
        [_durationPick addObject:[NSNumber numberWithInt:i]];
    }
    
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
    
//    self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height+44, 320, 216)];
//    self.datePicker.datePickerMode = UIDatePickerModeDate;
//    [self.view addSubview:self.datePicker];
//    self.dateInput.inputView = self.datePicker;
    
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
    self.datePicker.frame = CGRectMake(0, self.view.bounds.size.height+44, 320, 216);
    
    if(self.plan)
    {
        self.destinationInput.text = self.plan.destination;
        self.nameInput.text = self.plan.name;
        self.durationInput.text = [self.plan.duration stringValue];
        self.dateInput.text = [self.dateFormatter stringFromDate:self.plan.date];
    }
    
    self.dateInput.borderStyle = UITextBorderStyleNone;
    self.dateInput.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:16];
    self.dateInput.textColor = [UIColor colorWithRed:77/255.0 green:73/255.0 blue:69/255.0 alpha:1.0];
    
    self.durationInput.borderStyle = UITextBorderStyleNone;
    self.durationInput.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:16];
    self.durationInput.textColor = [UIColor colorWithRed:77/255.0 green:73/255.0 blue:69/255.0 alpha:1.0];
    
    self.nameInput.borderStyle = UITextBorderStyleNone;
    self.nameInput.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:16];
    self.nameInput.textColor = [UIColor colorWithRed:77/255.0 green:73/255.0 blue:69/255.0 alpha:1.0];
    
    self.destinationInput.borderStyle = UITextBorderStyleNone;
    self.destinationInput.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:16];
    self.destinationInput.textColor = [UIColor colorWithRed:77/255.0 green:73/255.0 blue:69/255.0 alpha:1.0];
}

- (void) viewDidAppear:(BOOL)animated
{
    if(!self.datePicker)
    {
        self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height+44, 320, 216)];
        self.datePicker.datePickerMode = UIDatePickerModeDate;
        [self.view addSubview:self.datePicker];
        self.dateInput.inputView = self.datePicker;
    }
    NSInteger defaultDuration;
    if(self.plan)
    {
        defaultDuration = [self.plan.duration intValue]-1;
        self.datePicker.date = self.plan.date;
    }
    else
    {
        defaultDuration = 2;
    }
    [(UIPickerView *)[self.view viewWithTag:10] selectRow:defaultDuration inComponent:0 animated:NO];
}

- (NSInteger) daysToDelete
{
    NSInteger days = 0;
    NSDate *date = [(UIDatePicker *)self.dateInput.inputView date];
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber *duration = [f numberFromString:self.durationInput.text];
    
    if([date compare: self.plan.date] == NSOrderedSame)
    {
        if([duration intValue] < [self.plan.duration intValue])
            days =  [self.plan.duration intValue] - [duration intValue];
    }
    else if([date compare: self.plan.date] == NSOrderedDescending)
    {
        NSInteger daysBetween = [Utility daysBetweenDate:self.plan.date andDate:date];
        if(daysBetween >= [self.plan.duration intValue])
        {
            days = [self.plan.duration intValue];
        }
        else
        {
            days = daysBetween;
            int offset = daysBetween + [duration intValue] - [self.plan.duration intValue];
            if(offset < 0)
            {
                days = days - offset;
            }
        }
    }
    else
    {
        NSInteger daysBetween = [Utility daysBetweenDate:date andDate:self.plan.date];
        if(daysBetween >= [duration intValue])
        {
            days = [self.plan.duration intValue];
        }
        else
        {
            days = [self.plan.duration intValue] - [duration intValue] + daysBetween;
        }
    }
    
    return days;
}

-(IBAction) done:(id) sender
{
    if ([self.destinationInput.text length] == 0) {
        [Utility showAlert:nil message:@"请设定目的地"];
        return;
    }
    if ([self.dateInput.text length] == 0 || [self.durationInput.text length] == 0)
    {
        [Utility showAlert:nil message:@"请设定旅行时间"];
        return;
    }
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    if(self.plan != nil)
    {
        NSInteger days = [self daysToDelete];
        if(days > 0)
        {
            NSString *alertText = [[NSString alloc] initWithString:[NSString stringWithFormat:@"你将从行程中删除%d天，这会同时删除该日期下的行程",days]];
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:alertText delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除" otherButtonTitles:nil, nil];
            actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
            [actionSheet showInView:self.view];
        }
        else
        {
            //需要检查那些做出了修改再去赋值，保存
            self.plan.destination = self.destinationInput.text;
            self.plan.name = self.nameInput.text;
            if (self.plan.name.length == 0) {
                self.plan.name = [NSString stringWithFormat:@"%@之旅", self.plan.destination];
            }
            self.plan.duration = [f numberFromString:self.durationInput.text];
            NSInteger daysBetween = [Utility daysBetweenDate:self.plan.date andDate:[(UIDatePicker *)self.dateInput.inputView date]];
            if(daysBetween)
            {
                self.plan.date = [(UIDatePicker *)self.dateInput.inputView date];
            }
            self.plan.image = self.coverImageView.image;
            [self saveImage:self.plan.image withName:[[self.plan.planId stringValue] stringByAppendingString:@"planCover"]];
            [self.delegate addPlanViewController:self didEditTravelPlan:self.plan];
        }
    }
    else
    {
        Plan *plan = [[Plan alloc] init];
        plan.name = self.nameInput.text;
        plan.destination = self.destinationInput.text;
        plan.duration = [f numberFromString:self.durationInput.text];
        plan.date = [(UIDatePicker *)self.dateInput.inputView date];
        plan.image = self.coverImageView.image;
        
        if(self.coverImageView.image != defaultCover)
        {
            self.coverChanged = YES;
        }

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
            self.durationInput.text = [[_durationPick objectAtIndex:row] stringValue];
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
    self.datePicker.frame = datePickerTargetFrame;
    [self.view viewWithTag:14].frame = toolbarTargetFrame;
    [UIView setAnimationDelegate:self];
    
    if([sender isKindOfClass:[UIBarButtonItem class]])
    {
        UIBarButtonItem *btn = (UIBarButtonItem *)sender;
        UIToolbar *toolbar = (UIToolbar *)self.dateInput.inputAccessoryView;
        if(btn == [toolbar.items objectAtIndex:2])
        {
            self.dateInput.text = [self.dateFormatter stringFromDate:self.datePicker.date];
        }
    }
    
    [UIView setAnimationDidStopSelector:@selector(removeViews:)];
    [self.view endEditing:TRUE];
    [UIView commitAnimations];
}

- (void)removeViews:(id)object {
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
    return [[_durationPick objectAtIndex:row] stringValue];
}

-(void)handleImageTap:(UITapGestureRecognizer *)sender
{
    if(!self.imgPickerController)
    {
        self.imgPickerController = [[UIImagePickerController alloc] init];
        self.imgPickerController.delegate = self;
    }
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

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == self.destinationInput) {
        [self showSearch];
        return NO;
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.nameInput && textField.text.length == 0 && self.destinationInput.text.length > 0) {
        textField.placeholder = [NSString stringWithFormat:@"%@之旅", self.destinationInput.text];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ((textField == self.dateInput) || (textField == self.durationInput) || (textField == self.nameInput)) {
        [textField resignFirstResponder];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == self.nameInput)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        self.plan.destination = self.destinationInput.text;
        self.plan.name = self.nameInput.text;
        if (self.plan.name.length == 0) {
            self.plan.name = [NSString stringWithFormat:@"%@之旅", self.plan.destination];
        }
        self.plan.duration = [f numberFromString:self.durationInput.text];
        //NSInteger daysBetween = [Utility daysBetweenDate:self.plan.date andDate:[(UIDatePicker *)self.dateInput.inputView date]];
        NSInteger daysBetween = [Utility daysBetweenDate:self.plan.date andDate:self.datePicker.date];
        if(daysBetween)
        {
            //self.plan.date = [(UIDatePicker *)self.dateInput.inputView date];
            self.plan.date = self.datePicker.date;
        }
        self.plan.image = self.coverImageView.image;
        
        [self saveImage:self.plan.image withName:[[self.plan.planId stringValue] stringByAppendingString:@"planCover"]];
        
        [self.delegate addPlanViewController:self didEditTravelPlan:self.plan];
    }
}

- (void)saveImage:(UIImage *)image withName:(NSString*)imageName
{
    NSData *imageData = UIImagePNGRepresentation(image); 
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", imageName]];
    
    [fileManager createFileAtPath:fullPath contents:imageData attributes:nil];
    
    NSLog(@"image saved");
    
}

- (void)removeImage:(NSString*)fileName {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", fileName]];
    
    [fileManager removeItemAtPath: fullPath error:NULL];
    
    NSLog(@"image removed");
    
}

- (UIImage*)loadImage:(NSString *)imageName
{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", imageName]];
    
    return [UIImage imageWithContentsOfFile:fullPath];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showSearch
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle: nil];
    SearchDestinationViewController *searchDestinationViewController = [storyboard instantiateViewControllerWithIdentifier:@"SearchDestinationStoryBoard"];
    searchDestinationViewController.delegate = self;
    searchDestinationViewController.destination = self.destinationInput.text;
    [searchDestinationViewController setTitle:@"搜索目的地"];
    [self.navigationController pushViewController:searchDestinationViewController animated:YES];
}

- (void)updateDestination:(NSString *)destination
{
    self.destinationInput.text = destination;
    if([self.nameInput.text length] == 0){
        self.nameInput.text = [NSString stringWithFormat:@"%@之旅", destination];
    }
}

@end
