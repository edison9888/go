//
//  AddLocationViewController.m
//  Chufaba
//
//  Created by 张辛欣 on 13-2-28.
//  Copyright (c) 2013年 ChufabaAPP团队. All rights reserved.
//

#import "AddLocationViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "JsonFetcher.h"


@interface AddLocationViewController ()
{
    BOOL nameChanged;
    BOOL coordinateChanged;
}

@end

@implementation AddLocationViewController

#define TAG_TOPVIEW 1
#define TAG_NAME_TEXTFIELD 2

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
    
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)] )
    {
        UIImage *image = [UIImage imageNamed:@"bar.png"];
        [self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    }
    
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    topView.tag = TAG_TOPVIEW;
    //[topView setBackgroundColor:[UIColor whiteColor]];
    topView.backgroundColor = [UIColor colorWithRed:244/255.0 green:241/255.0 blue:235/255.0 alpha:1.0];
    
    UITextField *nameOfAddLocation = [[UITextField alloc] initWithFrame:CGRectMake(10, 5, 300, 40)];
    [nameOfAddLocation setBorderStyle:UITextBorderStyleLine];
    nameOfAddLocation.layer.cornerRadius=5.0f;
    nameOfAddLocation.layer.masksToBounds=YES;
    nameOfAddLocation.layer.borderColor=[[UIColor grayColor]CGColor];
    nameOfAddLocation.layer.borderWidth= 1.0f;
    nameOfAddLocation.text = self.addLocationName;
    nameOfAddLocation.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [nameOfAddLocation setReturnKeyType:UIReturnKeyDone];
    nameOfAddLocation.backgroundColor = [UIColor whiteColor];
    nameOfAddLocation.delegate = self;
    
    [topView addSubview:nameOfAddLocation];
    [topView bringSubviewToFront:nameOfAddLocation];
    nameOfAddLocation.tag = TAG_NAME_TEXTFIELD;
    [self.view addSubview:topView];
    
	//MKMapView *mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 50, 320, 430)];
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 50, 320, 430)];
    self.mapView.delegate = self;
    
    UILabel *implyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20)];
    implyLabel.text = @"点击地图，为这个地点标注正确的位置";
    implyLabel.backgroundColor = [UIColor colorWithRed:0.239 green:0.239 blue:0.239 alpha:0.8];
    implyLabel.font = [UIFont systemFontOfSize:14];
    implyLabel.textColor = [UIColor whiteColor];
    implyLabel.textAlignment = NSTextAlignmentCenter;
    [self.mapView addSubview:implyLabel];
    
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [self.mapView addGestureRecognizer:tgr];
    
    [self.view addSubview:self.mapView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(confirmAddLocation:)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAddLocation:)];
    
    if ([self.lastLatitude intValue] != 10000 && [self.lastLatitude intValue] != 0)
    {
        CLLocationCoordinate2D customLoc2D_5 = CLLocationCoordinate2DMake([self.lastLatitude doubleValue], [self.lastLongitude doubleValue]);
        [self.mapView setCenterCoordinate:customLoc2D_5 animated:YES];
        MKCoordinateRegion region;
        region.center = customLoc2D_5;
        MKCoordinateSpan span;
        span.latitudeDelta = 0.4;
        span.longitudeDelta = 0.4;
        region.span=span;
        [self.mapView setRegion:region animated:false];
    }
}

- (void)handleGesture:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateEnded)
        return;
    
    [(UITextField *)[[self.view viewWithTag:TAG_TOPVIEW] viewWithTag:TAG_NAME_TEXTFIELD] resignFirstResponder];
    [self.mapView removeAnnotations:self.mapView.annotations];
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
    CLLocationCoordinate2D touchMapCoordinate = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    
    MKPointAnnotation *pa = [[MKPointAnnotation alloc] init];
    pa.coordinate = touchMapCoordinate;
    [self.mapView addAnnotation:pa];
}

- (IBAction)confirmAddLocation:(id)sender
{
    Location *addLocation = [[Location alloc] init];
    addLocation.category = self.addLocationCategory;
    
    NSString *textFieldValue = ((UITextField *)[[self.view viewWithTag:TAG_TOPVIEW] viewWithTag:TAG_NAME_TEXTFIELD]).text;
    
    if(![textFieldValue isEqual: self.addLocationName])
    {
        self.addLocationName = textFieldValue;
        nameChanged = YES;
    }
    
    addLocation.name = self.addLocationName;
    
    if ([self.mapView.annotations count] == 1)
    {
        id<MKAnnotation> tappedAnnotation = [self.mapView.annotations objectAtIndex:0];
        CLLocationCoordinate2D tappedPoint = tappedAnnotation.coordinate;
        addLocation.latitude = [NSNumber numberWithDouble:tappedPoint.latitude];
        addLocation.longitude = [NSNumber numberWithDouble:tappedPoint.longitude];
        //should check if the coordinate has changed
        coordinateChanged = YES;
    }
    
    [self saveLocationToServer:addLocation];
    if ([self.editLocationDelegate respondsToSelector:@selector(AddLocationViewController:didFinishEdit:name:coordinate:)])
    {
        [self.editLocationDelegate AddLocationViewController:self didFinishEdit:addLocation name:nameChanged coordinate:coordinateChanged];
    }
    if([self.editLocationDelegate respondsToSelector:@selector(AddLocationViewController:didFinishAdd:)])
    {
        [self.editLocationDelegate AddLocationViewController:self didFinishAdd:addLocation];
    }
}

- (IBAction)cancelAddLocation:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"坐标尚未保存，你确定放弃并返回吗？" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"确定", nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showInView:self.view];
}

-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 0)
    {
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}

- (void)saveLocationToServer:(Location *)location
{
    if (location.name) {
        NSString *name = (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                NULL,
                                                                                                (CFStringRef)location.name,
                                                                                                NULL,
                                                                                                CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                                                kCFStringEncodingUTF8));
        NSString *category = (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                NULL,
                                                                                                (CFStringRef)location.category,
                                                                                                NULL,
                                                                                                CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                                                kCFStringEncodingUTF8));
        JSONFetcher *fetcher = [[JSONFetcher alloc]
                                initWithURLString:[NSString stringWithFormat: @"http://localhost:3000/pois/useradd?useradd[name]=%@&useradd[category]=%@&useradd[user]=%@&useradd[latitude]=%f&useradd[longitude]=%f", name, category, @"", [location.latitude doubleValue], [location.longitude doubleValue]]
                                receiver:nil
                                action:nil];
        fetcher.showAlerts = NO;
        [fetcher start];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    [theTextField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
