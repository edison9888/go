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
    
    if(self.hasCoordinate)
    {
        self.navigationItem.title = @"编辑旅行地点";
    }
    else
    {
        self.navigationItem.title = @"创建旅行地点";
    }
    
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    topView.tag = TAG_TOPVIEW;
    topView.backgroundColor = [UIColor colorWithRed:244/255.0 green:241/255.0 blue:235/255.0 alpha:1.0];
    
    UITextField *nameOfAddLocation = [[UITextField alloc] initWithFrame:CGRectMake(10, 5, 300, 40)];
    [nameOfAddLocation setBorderStyle:UITextBorderStyleNone];
    nameOfAddLocation.layer.masksToBounds=YES;
    nameOfAddLocation.text = self.location.name;
    nameOfAddLocation.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [nameOfAddLocation setReturnKeyType:UIReturnKeyDone];
    nameOfAddLocation.backgroundColor = [UIColor clearColor];
    nameOfAddLocation.font = [UIFont fontWithName:@"Heiti SC" size:16];
    nameOfAddLocation.delegate = self;
    
    nameOfAddLocation.borderStyle = UITextBorderStyleNone;
    nameOfAddLocation.background = [UIImage imageNamed:@"kuang.png"];
    
    //add padding to the UITextfield
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 40)];
    nameOfAddLocation.leftView = paddingView;
    nameOfAddLocation.leftViewMode = UITextFieldViewModeAlways;
    
    [topView addSubview:nameOfAddLocation];
    [topView bringSubviewToFront:nameOfAddLocation];
    nameOfAddLocation.tag = TAG_NAME_TEXTFIELD;
    [self.view addSubview:topView];
    
	//MKMapView *mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 50, 320, 430)];
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 50, 320, 430)];
    self.mapView.delegate = self;
    
    UILabel *implyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20)];
    implyLabel.text = @"点击地图，为这个地点标注正确的位置";
    implyLabel.backgroundColor = [UIColor colorWithRed:227/255.0 green:219/255.0 blue:204/255.0 alpha:0.9];
    implyLabel.font = [UIFont fontWithName:@"Heiti SC" size:12];
    implyLabel.textColor = [UIColor colorWithRed:128/255.0 green:108/255.0 blue:77/255.0 alpha:1.0];
    implyLabel.textAlignment = NSTextAlignmentCenter;
    [self.mapView addSubview:implyLabel];
    
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [self.mapView addGestureRecognizer:tgr];
    
    [self.view addSubview:self.mapView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(confirmAddLocation:)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAddLocation:)];
    
    CLLocationCoordinate2D customLoc2D_5;
    if(self.hasCoordinate)
    {
        customLoc2D_5 = CLLocationCoordinate2DMake([self.location.latitude doubleValue], [self.location.longitude doubleValue]);
        [self.mapView setCenterCoordinate:customLoc2D_5 animated:YES];
        
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(customLoc2D_5, 1500, 1500);
        MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:region];
        
        [self.mapView setRegion:adjustedRegion animated:false];
        MKPointAnnotation *pa = [[MKPointAnnotation alloc] init];
        pa.coordinate = customLoc2D_5;
        [self.mapView addAnnotation:pa];
    }
    else
    {
        if (self.lastLatitude && self.lastLongitude)
        {
            customLoc2D_5 = CLLocationCoordinate2DMake([self.lastLatitude doubleValue], [self.lastLongitude doubleValue]);
            [self.mapView setCenterCoordinate:customLoc2D_5 animated:YES];
            
            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(customLoc2D_5, 1500, 1500);
            MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:region];
            
            [self.mapView setRegion:adjustedRegion animated:false];
            
            [self searchJiepangForKeyword:self.location.name AroundLocation:CGPointMake([self.lastLatitude floatValue], [self.lastLongitude floatValue])];
        }
        else
        {
            [self searchJiepangForKeyword:self.location.name];
        }
    }
}

- (void)handleGesture:(UIGestureRecognizer *)gestureRecognizer
{
    coordinateChanged = YES;
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
    NSString *textFieldValue = ((UITextField *)[[self.view viewWithTag:TAG_TOPVIEW] viewWithTag:TAG_NAME_TEXTFIELD]).text;
    
    if(![textFieldValue isEqual: self.location.name])
    {
        self.location.name = textFieldValue;
        nameChanged = YES;
    }
    
    if(nameChanged || coordinateChanged || self.addLocation)
    {
        Location *addLocation = [[Location alloc] init];
        addLocation.useradd = YES;
        addLocation.category = self.location.category;
        addLocation.name = self.location.name;
        
        if ([self.mapView.annotations count] == 1)
        {
            id<MKAnnotation> tappedAnnotation = [self.mapView.annotations objectAtIndex:0];
            CLLocationCoordinate2D tappedPoint = tappedAnnotation.coordinate;
            addLocation.latitude = [NSNumber numberWithDouble:tappedPoint.latitude];
            addLocation.longitude = [NSNumber numberWithDouble:tappedPoint.longitude];
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
    }else{
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}

- (IBAction)cancelAddLocation:(id)sender
{
    NSString *textFieldValue = ((UITextField *)[[self.view viewWithTag:TAG_TOPVIEW] viewWithTag:TAG_NAME_TEXTFIELD]).text;
    
    if(![textFieldValue isEqual: self.location.name])
    {
        self.location.name = textFieldValue;
        nameChanged = YES;
    }
    
    if(nameChanged || coordinateChanged)
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"修改尚未保存，你确定放弃并返回吗？" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"确定", nil];
        actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
        [actionSheet showInView:self.view];
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
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
                                initWithURLString:[NSString stringWithFormat: @"http://chufaba.me:3000/pois/useradd?useradd[name]=%@&useradd[category]=%@&useradd[user]=%@&useradd[latitude]=%f&useradd[longitude]=%f", name, category, @"", [location.latitude doubleValue], [location.longitude doubleValue]]
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

- (void)searchJiepangForKeyword:(NSString *)keyword AroundLocation:(CGPoint)location
{
    NSString *encodedString = (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                     NULL,
                                                                                                     (CFStringRef)keyword,
                                                                                                     NULL,
                                                                                                     CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                                                     kCFStringEncodingUTF8));
    JSONFetcher *fetcher = [[JSONFetcher alloc]
               initWithURLString:[NSString stringWithFormat:@"http://api.jiepang.com/v1/locations/search?q=%@&source=100743&count=5&lat=%f&lon=%f", encodedString, location.x, location.y]
               receiver:self
               action:@selector(receiveResponse:)];
    fetcher.showAlerts = NO;
    [fetcher start];
}

- (void)searchJiepangForKeyword:(NSString *)keyword
{
    NSString *encodedString = (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                     NULL,
                                                                                                     (CFStringRef)keyword,
                                                                                                     NULL,
                                                                                                     CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                                                     kCFStringEncodingUTF8));
    JSONFetcher *fetcher = [[JSONFetcher alloc]
                            initWithURLString:[NSString stringWithFormat:@"http://api.jiepang.com/v1/locations/search?q=%@&source=100743&count=5", encodedString]
                            receiver:self
                            action:@selector(receiveResponse:)];
    fetcher.showAlerts = NO;
    [fetcher start];
}

- (void)receiveResponse:(JSONFetcher *)aFetcher
{
    NSArray *items = [(NSDictionary *)aFetcher.result objectForKey:@"items"];
    if (items.count > 0) {
        [self showAnnotations:items];
    }
}

- (void)showAnnotations:(NSArray *)locations
{
    int count = MAX(locations.count, 3);
    NSMutableArray *sAnnotations = [[NSMutableArray alloc] init];
    Location *sLocation = [[Location alloc] init];
    for (int i=0; i < count; i++) {
        sLocation.name = [(NSDictionary *)[locations objectAtIndex:i] objectForKey:@"name"];
        sLocation.latitude = (NSNumber *)[(NSDictionary *)[locations objectAtIndex:i] objectForKey:@"lat"];
        sLocation.longitude = (NSNumber *)[(NSDictionary *)[locations objectAtIndex:i] objectForKey:@"lon"];
        [sAnnotations addObject:[LocationAnnotation annotationForLocation:sLocation ShowTitle:YES]];
    }
    self.annotations = sAnnotations;
}

- (void)updateMapView
{
    if (self.mapView.annotations)
        [self.mapView removeAnnotations:self.mapView.annotations];
    if (self.annotations)
        [self.mapView addAnnotations:self.annotations];
    LocationAnnotation *firstAnnotation = [self.annotations objectAtIndex:0];
    CLLocationCoordinate2D selectedLocationCoordinate = CLLocationCoordinate2DMake([firstAnnotation.location.latitude doubleValue], [firstAnnotation.location.longitude doubleValue]);
    
    [self.mapView setCenterCoordinate:selectedLocationCoordinate animated:YES];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(selectedLocationCoordinate, 500, 500);
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:region];
    
    [self.mapView setRegion:adjustedRegion animated:TRUE];
    [self.mapView selectAnnotation:firstAnnotation animated:YES];
}

- (void)setMapView:(MKMapView *)mapView
{
    _mapView = mapView;
    [self updateMapView];
}

- (void)setAnnotations:(NSArray *)annotations
{
    _annotations = annotations;
    [self updateMapView];
}

#define SEARCH_ANNOTATION_VIEWS @"SearchAnnotationViews"

- (MKAnnotationView *)mapView:(MKMapView *)sender viewForAnnotation:(id <MKAnnotation>)annotation
{
    MKAnnotationView *aView = [sender dequeueReusableAnnotationViewWithIdentifier:SEARCH_ANNOTATION_VIEWS];
    
	if (!aView)
    {
		aView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:SEARCH_ANNOTATION_VIEWS];
	}
    
	aView.annotation = annotation;
	return aView;
}

@end
