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
#import "Utility.h"


@interface AddLocationViewController ()
{
    BOOL coordinateChanged;
    BOOL nameChanged;
    BOOL selfEditMode;
    JSONFetcher *fetcher;
}

@end

@implementation AddLocationViewController

#define TAG_TOPVIEW 1
#define TAG_NAME_TEXTFIELD 2
#define TAG_POSITION_VIEW 3
#define TAG_POSITIONNOW_BUTTON 4
#define TAG_POSITION_LABEL 5
#define TAG_SEARCHBAR 6
#define TAG_LOADINGVIEW 7

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (fetcher) {
        [fetcher cancel];
        fetcher = nil;
    }
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
    self.navigationItem.title = @"设定地点坐标";
    
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 7, 40, 30)];
    [cancelBtn setImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [cancelBtn setImage:[UIImage imageNamed:@"cancel_click"] forState:UIControlStateHighlighted];
    [cancelBtn addTarget:self action:@selector(cancelAddLocation:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *cBtn = [[UIBarButtonItem alloc] initWithCustomView:cancelBtn];
    self.navigationItem.leftBarButtonItem = cBtn;
    
    UIButton *saveBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 7, 40, 30)];
    [saveBtn setImage:[UIImage imageNamed:@"done"] forState:UIControlStateNormal];
    [saveBtn setImage:[UIImage imageNamed:@"done_click"] forState:UIControlStateHighlighted];
    [saveBtn addTarget:self action:@selector(confirmAddLocation:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *dBtn = [[UIBarButtonItem alloc] initWithCustomView:saveBtn];
    self.navigationItem.rightBarButtonItem = dBtn;
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    searchBar.placeholder = @"地点名称";
    searchBar.delegate = self;
    searchBar.tag = TAG_SEARCHBAR;
    searchBar.text = self.location.name;
    searchBar.tintColor = [UIColor colorWithRed:227/255.0 green:219/255.0 blue:204/255.0 alpha:1.0];
    searchBar.backgroundImage = [[UIImage imageNamed:@"bg_Search"] stretchableImageWithLeftCapWidth:2 topCapHeight:0];
    [self.view addSubview:searchBar];
    
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 44, 320, 430)];
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView];
    
    CLLocationCoordinate2D customLoc2D_5;
    if(self.hasCoordinate)
    {
        if(![self.view viewWithTag:TAG_POSITION_VIEW])
        {
            UIView *positionByMyself = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-84, self.view.frame.size.width, 40)];
            positionByMyself.backgroundColor = [UIColor colorWithRed:128/255.0 green:108/255.0 blue:77/255.0 alpha:0.8];
            positionByMyself.tag = TAG_POSITION_VIEW;
            UILabel *positionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 300, 30)];
            positionLabel.tag = TAG_POSITION_LABEL;
            positionLabel.backgroundColor = [UIColor clearColor];
            positionLabel.textColor = [UIColor whiteColor];
            positionLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:14];
            [positionByMyself addSubview:positionLabel];
            [self.view addSubview:positionByMyself];
            [self.view bringSubviewToFront:positionByMyself];
        }
        
        selfEditMode = YES;
        ((UILabel *)[self.view viewWithTag:TAG_POSITION_LABEL]).text = @"点击地图可以重设坐标";
        
        UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
        [self.mapView addGestureRecognizer:tgr];
        
        customLoc2D_5 = CLLocationCoordinate2DMake([self.location.latitude doubleValue], [self.location.longitude doubleValue]);
        [self.mapView setCenterCoordinate:customLoc2D_5 animated:YES];
        
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(customLoc2D_5, 1000, 1000);
        MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:region];
        [self.mapView setRegion:adjustedRegion animated:false];
        
        MKPointAnnotation *pa = [[MKPointAnnotation alloc] init];
        pa.coordinate = customLoc2D_5;
        [self.mapView addAnnotation:pa];

        ((MKAnnotationView *)[self.mapView viewForAnnotation:pa]).image = [UIImage imageNamed:@"pin_more"];
    }
    else
    {
        UIActivityIndicatorView *loadingView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        loadingView.tag = TAG_LOADINGVIEW;
        [loadingView setFrame:CGRectMake(140, 160, 40, 40)];
        
        if (self.lastLatitude && self.lastLongitude)
        {
            [self searchJiepangForKeyword:self.location.name AroundLocation:CGPointMake([self.lastLatitude floatValue], [self.lastLongitude floatValue])];
            [loadingView startAnimating];
            [self.mapView addSubview:loadingView];
        }
        else
        {
            [self searchJiepangForKeyword:self.location.name];
            [loadingView startAnimating];
            [self.mapView addSubview:loadingView];
        }
    }
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = YES;
    
    for (UIView *subView in searchBar.subviews) {
        if([subView isKindOfClass:[UIButton class]])
        {
            UIButton *cancelButton = (UIButton *)subView;
            [cancelButton setTitle:@"" forState:UIControlStateNormal];
            
            UIView *overlay = [[UIView alloc] initWithFrame:CGRectMake(2, 2, 40, 20)];
            [overlay setBackgroundColor:[UIColor clearColor]];
            [overlay setUserInteractionEnabled:NO]; 
            [cancelButton addSubview:overlay];
            
            UILabel *newLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, 40, 20)];
            newLabel.backgroundColor = [UIColor clearColor];
            newLabel.textColor = [UIColor colorWithRed:72/255.0 green:70/255.0 blue:66/255.0 alpha:1.0];
            newLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:12];
            [newLabel setText:@"取消"];
            [newLabel setTextAlignment:NSTextAlignmentCenter];
            [newLabel setUserInteractionEnabled:NO];
            [overlay addSubview:newLabel];
        }
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = NO;
    [searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	searchBar.showsCancelButton = NO;
    [searchBar resignFirstResponder];
    
    UIActivityIndicatorView *loadingView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    loadingView.tag = TAG_LOADINGVIEW;
    [loadingView setFrame:CGRectMake(140, 160, 40, 40)];
    
	if (self.lastLatitude && self.lastLongitude)
    {
        [self searchJiepangForKeyword:searchBar.text AroundLocation:CGPointMake([self.lastLatitude floatValue], [self.lastLongitude floatValue])];
        [loadingView startAnimating];
        [self.mapView addSubview:loadingView];
    }
    else
    {
        [self searchJiepangForKeyword:searchBar.text];
        [loadingView startAnimating];
        [self.mapView addSubview:loadingView];
    }
}

- (IBAction)positionNow:(id)sender
{
    ((UILabel *)[self.view viewWithTag:TAG_POSITION_LABEL]).text = @"点击地图可以重设坐标";
    [self.mapView removeAnnotations:self.mapView.annotations];
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [self.mapView addGestureRecognizer:tgr];
    selfEditMode = YES;
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
    if (fetcher) {
        [fetcher cancel];
    }
    
    if(coordinateChanged || self.addLocation)
    {
        Location *addLocation = [[Location alloc] init];
        addLocation.useradd = YES;
        //addLocation.category = self.location.category;
        addLocation.category = @"其它";
        addLocation.name = self.location.name;
        addLocation.city = self.location.city;
        
        if (!selfEditMode)
        {
            LocationAnnotation *selectedAnnotation = [self.mapView.selectedAnnotations objectAtIndex:0];
            if(selectedAnnotation)
            {
                addLocation.latitude = selectedAnnotation.location.latitude;
                addLocation.longitude = selectedAnnotation.location.longitude;
                addLocation.name = selectedAnnotation.title;
                nameChanged = YES;
            }
            else
            {
                addLocation.latitude = nil;
                addLocation.longitude = nil;
                nameChanged = NO;
            }
        }
        else
        {
            id<MKAnnotation> tappedAnnotation = [self.mapView.annotations objectAtIndex:0];
            CLLocationCoordinate2D tappedPoint = tappedAnnotation.coordinate;
            addLocation.latitude = [NSNumber numberWithDouble:tappedPoint.latitude];
            addLocation.longitude = [NSNumber numberWithDouble:tappedPoint.longitude];
            nameChanged = NO;
        }
        
        [self saveLocationToServer:addLocation];
        if ([self.editLocationDelegate respondsToSelector:@selector(AddLocationViewController:didFinishEdit:name:coordinate:)])
        {
            [self.editLocationDelegate AddLocationViewController:self didFinishEdit:addLocation name:(BOOL)nameChanged coordinate:coordinateChanged];
        }
        if([self.editLocationDelegate respondsToSelector:@selector(AddLocationViewController:didFinishAdd:)])
        {
            [self.editLocationDelegate AddLocationViewController:self didFinishAdd:addLocation];
        }
    }
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)cancelAddLocation:(id)sender
{
    if (fetcher) {
        [fetcher cancel];
    }
    
    if(coordinateChanged)
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
        NSString *city = (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                    NULL,
                                                                                                    (CFStringRef)location.city,
                                                                                                    NULL,
                                                                                                    CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                                                    kCFStringEncodingUTF8));
        JSONFetcher *saveFetcher = [[JSONFetcher alloc]
                                initWithURLString:[NSString stringWithFormat: @"http://chufaba.me:3000/pois/useradd?useradd[name]=%@&useradd[category]=%@&useradd[user]=%@&useradd[latitude]=%f&useradd[longitude]=%f&useradd[city]=%@", name, category, @"", [location.latitude doubleValue], [location.longitude doubleValue], city]
                                receiver:nil
                                action:nil];
        saveFetcher.showAlerts = NO;
        [saveFetcher start];
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
    if (fetcher) {
        [fetcher cancel];
    }
    fetcher = [[JSONFetcher alloc]
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
    if (fetcher) {
        [fetcher cancel];
    }
    fetcher = [[JSONFetcher alloc]
                            initWithURLString:[NSString stringWithFormat:@"http://api.jiepang.com/v1/locations/search?q=%@&source=100743&count=5", encodedString]
                            receiver:self
                            action:@selector(receiveResponse:)];
    fetcher.showAlerts = NO;
    [fetcher start];
}

- (void)receiveResponse:(JSONFetcher *)aFetcher
{
    if(![self.view viewWithTag:TAG_POSITION_VIEW])
    {
        UIView *positionByMyself = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-40, self.view.frame.size.width, 40)];
        positionByMyself.backgroundColor = [UIColor colorWithRed:128/255.0 green:108/255.0 blue:77/255.0 alpha:0.8];
        positionByMyself.tag = TAG_POSITION_VIEW;
        UILabel *positionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 300, 30)];
        positionLabel.tag = TAG_POSITION_LABEL;
        positionLabel.backgroundColor = [UIColor clearColor];
        positionLabel.textColor = [UIColor whiteColor];
        positionLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:14];
        [positionByMyself addSubview:positionLabel];
        [self.view addSubview:positionByMyself];
        [self.view bringSubviewToFront:positionByMyself];
    }
    
    NSArray *items = [(NSDictionary *)aFetcher.result objectForKey:@"items"];
    if (items.count > 0)
    {
        ((UILabel *)[self.view viewWithTag:TAG_POSITION_LABEL]).text = @"选一个准确的位置 或 清空自行设定";
        [self showAnnotations:items];
        
        if(self.mapView.gestureRecognizers.count)
        {
            [self.mapView removeGestureRecognizer:[self.mapView.gestureRecognizers objectAtIndex:0]];
        }
        
        UIButton *positionByMyself = [[UIButton alloc] initWithFrame:CGRectMake(260, 5, 50, 30)];
        positionByMyself.tag = TAG_POSITIONNOW_BUTTON;
        [positionByMyself setImage:[UIImage imageNamed:@"btn_empty"] forState:UIControlStateNormal];
        [positionByMyself setImage:[UIImage imageNamed:@"btn_empty_click"] forState:UIControlStateHighlighted];
        [positionByMyself addTarget:self action:@selector(positionNow:) forControlEvents:UIControlEventTouchDown];
        [[self.view viewWithTag:TAG_POSITION_VIEW] addSubview:positionByMyself];
    }
    else
    {
        UIButton *positionNowBtn = (UIButton *)[self.view viewWithTag:TAG_POSITIONNOW_BUTTON];
        if(positionNowBtn)
        {
            [positionNowBtn removeFromSuperview];
        }
        ((UILabel *)[self.view viewWithTag:TAG_POSITION_LABEL]).text = @"没找到相关地点，换个词搜或点击地图自己设定";
        
        UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
        [self.mapView addGestureRecognizer:tgr];
        selfEditMode = YES;
    }
    [[self.mapView viewWithTag:TAG_LOADINGVIEW] removeFromSuperview];
}

- (void)showAnnotations:(NSArray *)locations
{
    int count = MIN(locations.count, 5);
    NSMutableArray *sAnnotations = [[NSMutableArray alloc] init];
    Location *sLocation;
    for (int i=0; i < count; i++) {
        sLocation = [[Location alloc] init];
        sLocation.name = [(NSDictionary *)[locations objectAtIndex:i] objectForKey:@"name"];
        sLocation.category = @"";
        sLocation.latitude = (NSNumber *)[(NSDictionary *)[locations objectAtIndex:i] objectForKey:@"lat"];
        sLocation.longitude = (NSNumber *)[(NSDictionary *)[locations objectAtIndex:i] objectForKey:@"lon"];
        [sAnnotations addObject:[LocationAnnotation annotationForLocation:sLocation ShowTitle:YES]];
    }
    self.annotations = sAnnotations;
    
    LocationAnnotation *firstAnnotation = (LocationAnnotation *)[self.annotations objectAtIndex:0];
    CLLocationCoordinate2D selectedLocationCoordinate = CLLocationCoordinate2DMake([firstAnnotation.location.latitude doubleValue], [firstAnnotation.location.longitude doubleValue]);
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(selectedLocationCoordinate, 1000, 1000);
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:region];
    [self.mapView setRegion:adjustedRegion animated:NO];
    
    [self.mapView setCenterCoordinate:selectedLocationCoordinate animated:YES];
    selfEditMode = NO;
}

- (void)updateMapView
{
    if (self.mapView.annotations)
    {
        [self.mapView removeAnnotations:self.mapView.annotations];
    }
    if (self.annotations)
    {
        [self.mapView addAnnotations:self.annotations];
    }
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
		aView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:SEARCH_ANNOTATION_VIEWS];
	}
    if(selfEditMode)
    {
        aView.image = [UIImage imageNamed:@"pin_more"];
    }
    else
    {
        aView.image = [UIImage imageNamed:@"pin_empty"];
    }
    aView.canShowCallout = YES;
	aView.annotation = annotation;
	return aView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    coordinateChanged = YES;
    view.image = [UIImage imageNamed:@"pin_more"];
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    view.image = [UIImage imageNamed:@"pin_empty"];
}

@end
