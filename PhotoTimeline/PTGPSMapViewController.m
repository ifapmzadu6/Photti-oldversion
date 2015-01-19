//
//  PTGPSMapViewController.m
//  PhotoTimeline
//
//  Created by Karijuku Keisuke on 2013/04/27.
//  Copyright (c) 2013年 Keisuke Karijuku. All rights reserved.
//

#import "PTGPSMapViewController.h"

#import "PAPhotoViewController.h"

@interface PTGPSMapViewController ()
{
	UILabel *_navigationTopLabel;
	UILabel *_navigationBottomLabel;
	
	BOOL _isDisappear;
}

@end

@implementation PTGPSMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView
{
	[super loadView];
	
//	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];
	
	self.wantsFullScreenLayout = YES;
	
	//navigationbar
//	[self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
//	[self.navigationController.navigationBar setBarStyle:UIBarStyleBlackTranslucent];
	[self.navigationController.navigationBar setTranslucent:YES];
	[self.navigationController.navigationBar setHidden:NO];
	
//	[self.navigationController.toolbar setBarStyle:UIBarStyleBlackTranslucent];
	[self.navigationController.toolbar setTranslucent:YES];
	[self.navigationController setToolbarHidden:NO animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	
	UIView *navigationTitleView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 200.0f, 44.0f)];
	navigationTitleView.backgroundColor = [UIColor clearColor];
	_navigationTopLabel = [[UILabel alloc] init];
	_navigationTopLabel.backgroundColor = [UIColor clearColor];
	_navigationTopLabel.textColor = [UIColor colorWithRed:0.204f green:0.212f blue:0.239f alpha:1.0f];
	_navigationTopLabel.textAlignment = NSTextAlignmentCenter;
	_navigationTopLabel.text = _navigationTopLabelText;
	[navigationTitleView addSubview:_navigationTopLabel];
	_navigationBottomLabel = [[UILabel alloc] init];
	_navigationBottomLabel.backgroundColor = [UIColor clearColor];
	_navigationBottomLabel.textColor = [UIColor colorWithRed:0.204f green:0.212f blue:0.239f alpha:0.734f];
	_navigationBottomLabel.textAlignment = NSTextAlignmentCenter;
	_navigationBottomLabel.text = _navigationBottomLabelText;
	[navigationTitleView addSubview:_navigationBottomLabel];
	self.navigationItem.titleView = navigationTitleView;
	if (self.interfaceOrientation == UIInterfaceOrientationPortrait) {
		_navigationTopLabel.frame = CGRectMake(0.0f, 4.0f, 200.0f, 18.0f);
		_navigationTopLabel.font = [UIFont boldSystemFontOfSize:18.0f];
		_navigationBottomLabel.frame = CGRectMake(0.0f, 23.0f, 200.0f, 18.0f);
		_navigationBottomLabel.font = [UIFont boldSystemFontOfSize:16.0f];
	}
	else {
		_navigationTopLabel.frame = CGRectMake(0.0f, 6.0f, 200.0f, 18.0f);
		_navigationTopLabel.font = [UIFont boldSystemFontOfSize:16.0f];
		_navigationBottomLabel.frame = CGRectMake(0.0f, 21.0f, 200.0f, 16.0f);
		_navigationBottomLabel.font = [UIFont boldSystemFontOfSize:14.0f];
	}
	
	UIButton *customView = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 36.0f, 36.0f)];
	[customView setImage:[UIImage imageNamed:@"09-arrow-west.png"] forState:UIControlStateNormal];
	[customView setImage:[UIImage imageNamed:@"09-arrow-west_touched.png"] forState:UIControlStateHighlighted];
	customView.showsTouchWhenHighlighted = YES;
	customView.exclusiveTouch = YES;
	[customView addTarget:self action:@selector(backBarUIButton) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem* buttonItem = [[UIBarButtonItem alloc] initWithCustomView:customView];
	self.navigationItem.leftBarButtonItem = buttonItem;
	
	if (_photoDatas.count > 0) {
	UIButton *customView1 = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 36.0f, 36.0f)];
		customView1.imageEdgeInsets = UIEdgeInsetsMake(4.0f, 4.0f, 4.0f, 4.0f);
		PAPhotoData *photoData = [_photoDatas objectAtIndex:_indexOfPhotoDatas];
		UIImage *image = [photoData thumbnail];
		[customView1 setImage:image forState:UIControlStateNormal];
		customView1.showsTouchWhenHighlighted = YES;
		customView1.exclusiveTouch = YES;
		[customView1 addTarget:self action:@selector(returnPhotoViewController) forControlEvents:UIControlEventTouchUpInside];
		UIBarButtonItem* buttonItem1 = [[UIBarButtonItem alloc] initWithCustomView:customView1];
		self.navigationItem.rightBarButtonItem = buttonItem1;
	}
	
	
	//toolbar
	UIButton *customView2 = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 36.0f, 40.0f)];
	[customView2 setImage:[UIImage imageNamed:@"72-pin.png"] forState:UIControlStateNormal];
	[customView2 setImage:[UIImage imageNamed:@"72-pin_touched.png"] forState:UIControlStateHighlighted];
	customView2.showsTouchWhenHighlighted = YES;
	customView2.exclusiveTouch = YES;
	[customView2 addTarget:self action:@selector(zoomPinAction) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem* buttonItem2 = [[UIBarButtonItem alloc] initWithCustomView:customView2];
	
	NSString *string = NSLocalizedString(@"Swipe here\nright to back", @"PAPhotoViewController");
	NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:string];
	[attributeString addAttribute:NSFontAttributeName
							value:[UIFont boldSystemFontOfSize:10]
							range:(NSRange){0, [attributeString length]}];
	[attributeString addAttribute:NSForegroundColorAttributeName
							value:[UIColor colorWithRed:0.5f green:0.5f blue:0.5f alpha:1.0f]
							range:(NSRange){0, [attributeString length]}];
	UILabel *customView3 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 160, 40)];
	customView3.backgroundColor = [UIColor clearColor];
	customView3.lineBreakMode = NSLineBreakByWordWrapping;
	customView3.textAlignment = NSTextAlignmentCenter;
	customView3.numberOfLines = 2;
	[customView3 setAttributedText:attributeString];
	UISwipeGestureRecognizer* swipeRightGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(myPopViewController)];
	swipeRightGesture.direction = UISwipeGestureRecognizerDirectionRight;
	[customView3 addGestureRecognizer:swipeRightGesture];
	UIBarButtonItem* buttonItem3 = [[UIBarButtonItem alloc] initWithCustomView:customView3];
	customView3.userInteractionEnabled = YES;
	UIBarButtonItem *spacer = [[UIBarButtonItem alloc]
							   initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
							   target:nil action:nil];
	
	self.toolbarItems = @[buttonItem2, spacer, buttonItem3, spacer];
	
	
	//map
	NSMutableArray *annotations = [[NSMutableArray alloc] init];
	if (_isSingle) {
		PAPhotoData *photoData = [_photoDatas objectAtIndex:_indexOfPhotoDatas];
		if (photoData.location != nil) {
			CustomAnnotation *annotation = [[CustomAnnotation alloc] init];
			annotation.coordinate = photoData.location.coordinate;
			NSString *dateString = [photoData dateFullString];
			annotation.title = dateString;
			annotation.photoData = photoData;
			[annotations addObject:annotation];
		}
	}
	else {
		for (PAPhotoData *photoData in _photoDatas) {
			if (photoData.location != nil) {
				CustomAnnotation *annotation = [[CustomAnnotation alloc] init];
				annotation.coordinate = photoData.location.coordinate;
				NSString *dateString = [photoData dateFullString];
				annotation.title = dateString;
				annotation.photoData = photoData;
				[annotations addObject:annotation];
			}
		}
	}
	if (annotations.count > 0) {
		[_mapView addAnnotations:annotations];
		[self zoomToFitMapAnnotations:_mapView animated:NO];
		
		if (annotations.count == 1) {
			[_mapView selectAnnotation:[annotations objectAtIndex:0] animated:NO];
		}
	}
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	self.navigationItem.rightBarButtonItem.enabled = YES;
	self.navigationController.toolbar.userInteractionEnabled = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];	
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
		
	[_mapView removeFromSuperview];
	_mapView = nil;
	
	_isDisappear = YES;
	
//	NSLog(@"MapViewController did disappear!");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
		_navigationTopLabel.frame = CGRectMake(0.0f, 4.0f, 200.0f, 18.0f);
		_navigationTopLabel.font = [UIFont boldSystemFontOfSize:18.0f];
		_navigationBottomLabel.frame = CGRectMake(0.0f, 23.0f, 200.0f, 18.0f);
		_navigationBottomLabel.font = [UIFont boldSystemFontOfSize:16.0f];
	}
	else {
		_navigationTopLabel.frame = CGRectMake(0.0f, 6.0f, 200.0f, 18.0f);
		_navigationTopLabel.font = [UIFont boldSystemFontOfSize:16.0f];
		_navigationBottomLabel.frame = CGRectMake(0.0f, 21.0f, 200.0f, 16.0f);
		_navigationBottomLabel.font = [UIFont boldSystemFontOfSize:14.0f];
	}
}

- (void)zoomToFitMapAnnotations:(MKMapView *)mapView animated:(BOOL)animated
{
    if ([mapView.annotations count] == 0) return;
	
    CLLocationCoordinate2D topLeftCoord;
    topLeftCoord.latitude = -90;
    topLeftCoord.longitude = 180;
	
    CLLocationCoordinate2D bottomRightCoord;
    bottomRightCoord.latitude = 90;
    bottomRightCoord.longitude = -180;
	
    for(id<MKAnnotation> annotation in mapView.annotations) {
        topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude);
        topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude);
        bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude);
        bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude);
    }
	
    MKCoordinateRegion region;
    region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.3333f;
    region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5f;
	
	if (topLeftCoord.latitude == bottomRightCoord.latitude) {
		region.center.latitude += 0.0005f;
	}
    region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.3f;
    region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.3f;
	
	if (region.span.latitudeDelta < 0.01f) {
		region.span.latitudeDelta = 0.01f;
	}
	if (region.span.longitudeDelta < 0.01f) {
		region.span.longitudeDelta = 0.01f;
	}
	
    region = [mapView regionThatFits:region];
    [mapView setRegion:region animated:animated];
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
//	CustomAnnotation *customAnnotation = (CustomAnnotation *)view.annotation;
//	
//	PAPhotoViewController *photoViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PAPhotoViewController"];
//	
//	photoViewController.firstPage = 0;
//	PAAlbumData *albumData = [[PAAlbumData alloc] init];
//	albumData.photoDatas = [[NSMutableArray alloc] initWithArray:@[customAnnotation.photoData]];
//	photoViewController.albumData = albumData;
//	
//	[self.navigationController pushViewController:photoViewController animated:YES];
	
	[self returnPhotoViewController];
}

- (MKAnnotationView*)mapView:(MKMapView*)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
	
	if (annotation == mapView.userLocation) {
		return nil;
	}
	
	// return nill
	// ここでnilを返したとすると、ピンがAnnotationに使われる
	// 細かい調整は以下
	
	MKPinAnnotationView *annotationView;
	annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"identifier"];
	if (annotationView == nil) {
		annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"identifier"];
	}
	
	[annotationView setPinColor:MKPinAnnotationColorRed];
	[annotationView setCanShowCallout:YES];
	[annotationView setAnimatesDrop:YES];
	[annotationView setRightCalloutAccessoryView:[UIButton buttonWithType:UIButtonTypeDetailDisclosure]];
	
	CustomAnnotation *customAnnotation = (CustomAnnotation *)annotation;
	
	UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 30.0f, 30.0f)];
	imageView.image = [UIImage imageWithCGImage:customAnnotation.photoData.asset.thumbnail];
	imageView.layer.borderWidth = 0.5f;
	imageView.layer.borderColor = [UIColor blackColor].CGColor;
	annotationView.leftCalloutAccessoryView = imageView;
	
	annotationView.annotation = annotation;
	
	return annotationView;
}

- (void)zoomPinAction
{
	[self zoomToFitMapAnnotations:_mapView animated:YES];
	
	if (_mapView.annotations.count == 1) {
		[_mapView selectAnnotation:[_mapView.annotations objectAtIndex:0] animated:YES];
	}
}

//- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView
//{
//	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
//}
//
//- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
//{
//	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
//}
//
//- (void)mapViewDidStopLocatingUser:(MKMapView *)mapView
//{
//	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
//}

- (void)backBarUIButton
{
	[self performSegueWithIdentifier:@"AlbumFromMap" sender:self];
}

- (void)myPopViewController
{
	[self performSegueWithIdentifier:@"AlbumFromMap" sender:self];
}

- (void)returnPhotoViewController
{
	self.navigationItem.rightBarButtonItem.enabled = NO;
	self.navigationController.toolbar.userInteractionEnabled = NO;
	
	PAPhotoViewController *photoViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PAPhotoViewController"];
	PAAlbumData *albumData = [[PAAlbumData alloc] init];
	albumData.photoDatas = _photoDatas;
	photoViewController.albumData = albumData;
	photoViewController.indexOfPhotoDatas = _indexOfPhotoDatas;
	if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
		photoViewController.view.frame = CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
	}
	[self.view addSubview:photoViewController.view];
	
	[UIView animateWithDuration:0.75f animations:^{
		[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.view cache:NO];
	} completion:^(BOOL finished) {
		[self.navigationController pushViewController:photoViewController animated:NO];
	}];
}

- (void)reloadData
{
	if (_isDisappear == YES) {
		return;
	}
	
	dispatch_async(dispatch_get_main_queue(), ^{
		[self performSegueWithIdentifier:@"AlbumFromMap" sender:self];
//		[self returnPhotoViewController];
	});
}

@end




@implementation CustomAnnotation
@end