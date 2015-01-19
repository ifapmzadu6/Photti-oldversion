//
//  PAPhotoViewController.m
//  PhotoTimeline
//
//  Created by Karijuku Keisuke on 2013/04/17.
//  Copyright (c) 2013年 Keisuke Karijuku. All rights reserved.
//

#import "PAPhotoViewController.h"

#import "PhotoViewController.h"

#import "PTGPSMapViewController.h"


@interface PAPhotoViewController ()
{
	UILabel *_navigationTopLabel;
	UILabel *_navigationBottomLabel;
	
	UIPageViewController *_pageViewController;
	
	PhotoViewController *_beforePhotoViewController;
	PhotoViewController *_visiblePhotoViewController;
	PhotoViewController *_afterPhotoViewController;
	PhotoViewController *_tmpPhotoViewController;
	
	MPMoviePlayerController *_moviePlayerController;
			
	PAPhotoData *_visiblePhotoData;
	
	NSOperationQueue *_queue;
	NSOperationQueue *_fullResolutionQueue;
	
	BOOL _singleTapDisable;
	BOOL _isDisable;
	
	BOOL _isDisappear;
}

@end

@implementation PAPhotoViewController

@synthesize albumData = _albumData;

- (void)loadView
{
	[super loadView];
		
	self.wantsFullScreenLayout = YES;
	
//	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];
	
	[self.navigationController.navigationBar setTranslucent:YES];
	
	[self.navigationController.toolbar setTranslucent:YES];
	[self.navigationController.toolbar setTintColor:[UIColor whiteColor]];
}

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
	
	if (_queue == nil) {
		_queue = [[NSOperationQueue alloc] init];
		_queue.maxConcurrentOperationCount = 1;
		_fullResolutionQueue = [[NSOperationQueue alloc] init];
		_fullResolutionQueue.maxConcurrentOperationCount = 1;
	}
	
	//ナビゲーションバー
	UIButton *customView = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 36.0f, 36.0f)];
	 [customView setImage:[UIImage imageNamed:@"09-arrow-west.png"] forState:UIControlStateNormal];
	 [customView setImage:[UIImage imageNamed:@"09-arrow-west_touched.png"] forState:UIControlStateHighlighted];
	customView.showsTouchWhenHighlighted = YES;
	customView.exclusiveTouch = YES;
	[customView addTarget:self action:@selector(backBarUIButton) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem* buttonItem = [[UIBarButtonItem alloc] initWithCustomView:customView];
	self.navigationItem.leftBarButtonItem = buttonItem;
	
	UIView *navigationTitleView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 200.0f, 44.0f)];
	navigationTitleView.backgroundColor = [UIColor clearColor];
	_navigationTopLabel = [[UILabel alloc] init];
	_navigationTopLabel.backgroundColor = [UIColor clearColor];
	_navigationTopLabel.textColor = [UIColor colorWithRed:0.204f green:0.212f blue:0.239f alpha:1.0f];
	_navigationTopLabel.textAlignment = NSTextAlignmentCenter;
	[navigationTitleView addSubview:_navigationTopLabel];
	_navigationBottomLabel = [[UILabel alloc] init];
	_navigationBottomLabel.backgroundColor = [UIColor clearColor];
	_navigationBottomLabel.textColor = [UIColor colorWithRed:0.204f green:0.212f blue:0.239f alpha:0.734f];
	_navigationBottomLabel.textAlignment = NSTextAlignmentCenter;
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
	
	//ツールバー
	UIButton *customView2 = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 36.0f, 36.0f)];
	[customView2 setImage:[UIImage imageNamed:@"211-action.png"] forState:UIControlStateNormal];
	[customView2 setImage:[UIImage imageNamed:@"211-action_touched.png"] forState:UIControlStateHighlighted];
	customView2.showsTouchWhenHighlighted = YES;
	customView2.exclusiveTouch = YES;
	[customView2 addTarget:self action:@selector(settingBarUIButton) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem* buttonItem2 = [[UIBarButtonItem alloc] initWithCustomView:customView2];
	
	NSString *string = NSLocalizedString(@"Swipe here\nright to back", @"PAPhotoViewController");
	NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:string];
	[attributeString addAttribute:NSFontAttributeName
						   value:[UIFont boldSystemFontOfSize:10]
						   range:(NSRange){0, [attributeString length]}];
	[attributeString addAttribute:NSForegroundColorAttributeName
							value:[UIColor colorWithRed:0.5f green:0.5f blue:0.5f alpha:1.0f]
						   range:(NSRange){0, [attributeString length]}];
//	NSShadow *shadow = [[NSShadow alloc] init];
//    shadow.shadowOffset = CGSizeMake(0.0f, 0.0f);
//    shadow.shadowColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.5f];
//    shadow.shadowBlurRadius = 5.0f;
//	[attributeString addAttribute:NSShadowAttributeName
//							value:shadow
//							range:(NSRange){0, [attributeString length]}];
	UILabel *customView3 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 160, 40)];
	customView3.backgroundColor = [UIColor clearColor];
	customView3.lineBreakMode = NSLineBreakByWordWrapping;
	customView3.textAlignment = NSTextAlignmentCenter;
	customView3.numberOfLines = 2;
	[customView3 setAttributedText:attributeString];
	UISwipeGestureRecognizer* swipeRightGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(myPopViewController)];
	swipeRightGesture.direction = UISwipeGestureRecognizerDirectionRight;
	[customView3 addGestureRecognizer:swipeRightGesture];
	customView3.userInteractionEnabled = YES;
	customView3.exclusiveTouch = YES;
	UIBarButtonItem* buttonItem3 = [[UIBarButtonItem alloc] initWithCustomView:customView3];
	
	UIBarButtonItem *spacer = [[UIBarButtonItem alloc]
							   initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
							   target:nil action:nil];
	
	self.toolbarItems = @[buttonItem2, spacer, buttonItem3, spacer];
	
	_visiblePhotoViewController = [self createPhotoViewControllerAtIndex:_indexOfPhotoDatas];
	
    if (_visiblePhotoViewController != nil)
    {
		NSDictionary *option = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:40.0f], UIPageViewControllerOptionInterPageSpacingKey, nil];
		_pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:option];
		_pageViewController.dataSource = self;
		_pageViewController.delegate = self;
		_pageViewController.wantsFullScreenLayout = YES;
        
        [_pageViewController setViewControllers:@[_visiblePhotoViewController]
									 direction:UIPageViewControllerNavigationDirectionForward
									  animated:NO
									completion:nil];
		[self.view addSubview:_pageViewController.view];
	}
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	_singleTapDisable = YES;
	
	[_queue cancelAllOperations];
	_queue = nil;
	[_fullResolutionQueue cancelAllOperations];
	_fullResolutionQueue = nil;	
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	if (_queue == nil) {
		_queue = [[NSOperationQueue alloc] init];
		_queue.maxConcurrentOperationCount = 1;
		_fullResolutionQueue = [[NSOperationQueue alloc] init];
		_fullResolutionQueue.maxConcurrentOperationCount = 1;
	}
	
	[self.navigationController setToolbarHidden:NO animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	self.navigationItem.rightBarButtonItem.enabled = YES;
	self.navigationController.toolbar.userInteractionEnabled = YES;
	
	_singleTapDisable = NO;
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	
	if (_beforePhotoViewController) {
		[_beforePhotoViewController zoomViewFromSuperview];
		[_beforePhotoViewController.view removeFromSuperview];
		_beforePhotoViewController = nil;
	}
	if (_visiblePhotoViewController) {
		[_visiblePhotoViewController zoomViewFromSuperview];
		[_visiblePhotoViewController.view removeFromSuperview];
		_visiblePhotoViewController = nil;
	}
	if (_afterPhotoViewController) {
		[_afterPhotoViewController zoomViewFromSuperview];
		[_afterPhotoViewController.view removeFromSuperview];
		_afterPhotoViewController = nil;
	}
	if (_tmpPhotoViewController) {
		[_tmpPhotoViewController zoomViewFromSuperview];
		[_tmpPhotoViewController.view removeFromSuperview];
		_tmpPhotoViewController = nil;
	}
	
	[_pageViewController.view removeFromSuperview];
	_pageViewController = nil;
	
	_isDisappear = YES;
	
//	NSLog(@"PhotoViewController did disappear!");
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

- (UIViewController *)pageViewController:(UIPageViewController *)pvc viewControllerBeforeViewController:(PhotoViewController *)vc
{
    NSUInteger index = vc.pageIndex;
	
	if (index == 0) {
		return nil;
	}
	
	if (_beforePhotoViewController == nil) {
		_beforePhotoViewController = [self createPhotoViewControllerAtIndex:index - 1];
	}
	else {
		if (_beforePhotoViewController.pageIndex != index - 1) {
			PhotoViewController *tmpPhotoViewController = _visiblePhotoViewController;
			_visiblePhotoViewController = _beforePhotoViewController;
			if (_tmpPhotoViewController == nil) {
				_beforePhotoViewController = [self createPhotoViewControllerAtIndex:index - 1];
			}
			else {
				_beforePhotoViewController = [_tmpPhotoViewController init];
				_beforePhotoViewController.pageIndex = index - 1;
				_beforePhotoViewController.myDelegate = self;
				_beforePhotoViewController.photoData = [_albumData.photoDatas objectAtIndex:index - 1];
				_beforePhotoViewController.queue = _queue;
				_beforePhotoViewController.fullResolutionQueue = _fullResolutionQueue;
				[_beforePhotoViewController recycleView];
			}
			_tmpPhotoViewController = _afterPhotoViewController;
			_afterPhotoViewController = tmpPhotoViewController;
		}
	}
	
//	NSLog(@"viewControllerBeforeViewController %d to %d", index+1, index);
	return _beforePhotoViewController;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pvc viewControllerAfterViewController:(PhotoViewController *)vc
{
    NSUInteger index = vc.pageIndex;
	
	if (index == _albumData.photoDatas.count - 1) {
		return  nil;
	}
	
	if (_afterPhotoViewController == nil) {
		_afterPhotoViewController = [self createPhotoViewControllerAtIndex:index + 1];
	}
	else {
		if (_afterPhotoViewController.pageIndex != index + 1) {
			PhotoViewController *tmpPhotoViewController = _visiblePhotoViewController;
			_visiblePhotoViewController = _afterPhotoViewController;
			if (_tmpPhotoViewController == nil) {
				_afterPhotoViewController = [self createPhotoViewControllerAtIndex:index + 1];
			}
			else {
				_afterPhotoViewController = [_tmpPhotoViewController init];
				_afterPhotoViewController.pageIndex = index + 1;
				_afterPhotoViewController.myDelegate = self;
				_afterPhotoViewController.photoData = [_albumData.photoDatas objectAtIndex:index + 1];
				_afterPhotoViewController.queue = _queue;
				_afterPhotoViewController.fullResolutionQueue = _fullResolutionQueue;
				[_afterPhotoViewController recycleView];
			}
			_tmpPhotoViewController = _beforePhotoViewController;
			_beforePhotoViewController = tmpPhotoViewController;
		}
	}
		
//	NSLog(@"viewControllerAfterViewController %d to %d", index+1, index+2);
	return _afterPhotoViewController;
}

- (PhotoViewController *)createPhotoViewControllerAtIndex:(NSUInteger)index
{
	PhotoViewController *photoViewController = [[PhotoViewController alloc] init];
	photoViewController.pageIndex = index;
	photoViewController.myDelegate = self;
	photoViewController.photoData = [_albumData.photoDatas objectAtIndex:index];
	photoViewController.queue = _queue;
	photoViewController.fullResolutionQueue = _fullResolutionQueue;
	[photoViewController recycleView];
	
//	NSLog(@"create PhotoViewController at %d", index + 1);
	return photoViewController;
}

- (void)visibleViewIndex:(NSUInteger)index
{
	if (_visiblePhotoViewController != nil) {
		_visiblePhotoViewController.visibleIndex = index;
	}
	if (_tmpPhotoViewController != nil) {
		_tmpPhotoViewController.visibleIndex = index;
	}
	if (_afterPhotoViewController != nil) {
		_afterPhotoViewController.visibleIndex = index;
	}
	if (_beforePhotoViewController != nil) {
		_beforePhotoViewController.visibleIndex = index;
	}
}

- (void)viewWillAppearWithPhotoData:(PAPhotoData *)photoData
{	
	_indexOfPhotoDatas = [_albumData.photoDatas indexOfObject:photoData];
	_visiblePhotoData = photoData;
	
	NSString *title = NSLocalizedString(@"%d of %d", @"PAPhotoViewController");
	_navigationTopLabel.text = [NSString stringWithFormat:title, _indexOfPhotoDatas + 1, _albumData.photoDatas.count];
	_navigationBottomLabel.text = [photoData dateFullStringWithHour];
	
	[self visibleViewIndex:_indexOfPhotoDatas];
	
	if (photoData.location != nil) {
		UIButton *customView1 = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 36.0f, 40.0f)];
		[customView1 setImage:[UIImage imageNamed:@"07-map-marker.png"] forState:UIControlStateNormal];
		[customView1 setImage:[UIImage imageNamed:@"07-map-marker_touched.png"] forState:UIControlStateHighlighted];
		customView1.showsTouchWhenHighlighted = YES;
		customView1.exclusiveTouch = YES;
		[customView1 addTarget:self action:@selector(showMapAtIndexPhoto) forControlEvents:UIControlEventTouchUpInside];
		UIBarButtonItem* buttonItem1 = [[UIBarButtonItem alloc] initWithCustomView:customView1];
		self.navigationItem.rightBarButtonItem = buttonItem1;
	}
	else {
		UIButton *customView1 = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 36.0f, 40.0f)];
		UIBarButtonItem* buttonItem1 = [[UIBarButtonItem alloc] initWithCustomView:customView1];
		self.navigationItem.rightBarButtonItem = buttonItem1;		
	}
}

- (void)singleTap
{
	if (_singleTapDisable) {
		return;
	}
	
	_isDisable = YES;
		
	if (self.navigationController.navigationBarHidden) {
		[[UIApplication sharedApplication] setStatusBarHidden:NO];
		[self.navigationController setNavigationBarHidden:NO animated:YES];
		[self.navigationController setToolbarHidden:NO animated:YES];
		
		[UIView animateWithDuration:0.3f animations:^{
			self.view.backgroundColor = [UIColor whiteColor];
		} completion:^(BOOL finished) {
			_isDisable = NO;
		}];
	}
	else {
		[[UIApplication sharedApplication] setStatusBarHidden:YES];
		[self.navigationController setNavigationBarHidden:YES animated:YES];
		[self.navigationController setToolbarHidden:YES animated:YES];
		
		[UIView animateWithDuration:0.3f animations:^{
			self.view.backgroundColor = [UIColor blackColor];
		} completion:^(BOOL finished) {
			_isDisable = NO;
		}];
	}
}

- (void)backBarUIButton
{
	if (_isDisable) {
		return;
	}
	
	_singleTapDisable = YES;
	
	[self performSegueWithIdentifier:@"AlbumFromPhoto" sender:self];
}

- (void)myPopViewController
{
	if (_isDisable) {
		return;
	}
	
	_singleTapDisable = YES;
	
	[self performSegueWithIdentifier:@"AlbumFromPhoto" sender:self];
}

- (void)settingBarUIButton
{
	if (_isDisable) {
		return;
	}
	
	_singleTapDisable = YES;
	
	PAPhotoData *photoData = [_albumData.photoDatas objectAtIndex:_indexOfPhotoDatas];
	if (photoData.isVideo == NO) {
		NSDictionary *urls = [photoData.asset valueForProperty:ALAssetPropertyURLs];
		NSURL *url;
		if ([urls count]) {
			for (NSString *key in urls) {
				// I'm making an assumption that the URL I want is the first URL in the dictionary
				url = [urls objectForKey:key];
				break;
			}
		}
		
		_activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[url] applicationActivities:nil];
		NSMutableArray *activityTypes = [NSMutableArray array];
		[activityTypes addObject:UIActivityTypeSaveToCameraRoll];
		_activityViewController.excludedActivityTypes = activityTypes;
		[self presentViewController:_activityViewController animated:YES completion:^{
			_singleTapDisable = NO;
		}];
	}
	else {
		MBProgressHUD *progressHUD = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
		progressHUD.labelText = NSLocalizedString(@"Loading...", @"PTPhotoViewController");
		dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
			ALAssetRepresentation *rep = [photoData.asset defaultRepresentation];
			Byte *buffer = (Byte *)malloc(rep.size);
			NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:rep.size error:nil];
			NSData *data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
			
			NSString* a_doc_tmp = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp/video.mp4"];
			
			if ([data writeToFile:a_doc_tmp atomically:YES] == NO) {
				NSLog(@"write to file error!");
			}
			
			NSURL *url = [NSURL fileURLWithPath:a_doc_tmp];			
			dispatch_async(dispatch_get_main_queue(), ^{
				[MBProgressHUD hideHUDForView:self.view.window animated:YES];
				NSArray* actItems = [NSArray arrayWithObjects:url, nil];
				_activityViewController = [[UIActivityViewController alloc] initWithActivityItems:actItems applicationActivities:nil];
				NSMutableArray *activityTypes = [NSMutableArray array];
				[activityTypes addObject:UIActivityTypeSaveToCameraRoll];
				_activityViewController.excludedActivityTypes = activityTypes;
				[self presentViewController:_activityViewController animated:YES completion:^{
					_singleTapDisable = NO;
				}];
				
				_singleTapDisable = NO;
			});
		});
	}
}

- (UIImage *)loadImage
{
	PAPhotoData *photoData = [_albumData.photoDatas objectAtIndex:_indexOfPhotoDatas];
		
	UIImage *decompressedImage;
	if (MIN([photoData dimensions].height, [photoData dimensions].width) > 1280) {
		decompressedImage = [photoData makeThumbnailImage:960];
	}
	else {
		decompressedImage = [photoData fullResolutionImage];
	}
	
    return decompressedImage;
}


- (void)showMapAtIndexPhoto
{
	if (_isDisable) {
		return;
	}
	
	_singleTapDisable = YES;
	
	self.navigationItem.rightBarButtonItem.enabled = NO;
	self.navigationController.toolbar.userInteractionEnabled = NO;
	
	PTGPSMapViewController *gpsMapViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PTGPSMapViewController"];
	gpsMapViewController.navigationTopLabelText = _navigationTopLabel.text;
	gpsMapViewController.navigationBottomLabelText = _navigationBottomLabel.text;
	gpsMapViewController.photoDatas = _albumData.photoDatas;
	gpsMapViewController.indexOfPhotoDatas = _indexOfPhotoDatas;
	gpsMapViewController.isSingle = YES;
	if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
		gpsMapViewController.view.frame = CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
	}
	gpsMapViewController.view.opaque = YES;
	gpsMapViewController.mapView.opaque = YES;
	[self.view addSubview:gpsMapViewController.view];
	
	[UIView animateWithDuration:0.75f animations:^{
		[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view cache:NO];
	} completion:^(BOOL finished) {
		[self.navigationController pushViewController:gpsMapViewController animated:NO];
	}];
}

- (void)reloadData
{	
	if (_isDisappear == YES) {
		return;
	}
	
	if (_visiblePhotoData.asset.thumbnail == nil) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[self performSegueWithIdentifier:@"AlbumFromPhoto" sender:self];
		});
	}
	else {
		dispatch_async(dispatch_get_main_queue(), ^{
			_indexOfPhotoDatas = [_albumData.photoDatas indexOfObject:_visiblePhotoData];

			NSString *title = NSLocalizedString(@"%d of %d", @"PAPhotoViewController");
			[self.navigationItem setTitle:[NSString stringWithFormat:title, _indexOfPhotoDatas + 1, _albumData.photoDatas.count]];
			
			_visiblePhotoViewController = [_visiblePhotoViewController init];
			_visiblePhotoViewController.pageIndex = _indexOfPhotoDatas;
			_visiblePhotoViewController.visibleIndex = _indexOfPhotoDatas;
			_visiblePhotoViewController.myDelegate = self;
			_visiblePhotoViewController.photoData = [_albumData.photoDatas objectAtIndex:_indexOfPhotoDatas];
			_visiblePhotoViewController.queue = _queue;
			_visiblePhotoViewController.fullResolutionQueue = _fullResolutionQueue;
			[_visiblePhotoViewController recycleView];
			
			_beforePhotoViewController = nil;
			_afterPhotoViewController = nil;
			_tmpPhotoViewController = nil;
			
			[_pageViewController setViewControllers:@[_visiblePhotoViewController]
										  direction:UIPageViewControllerNavigationDirectionForward
										   animated:NO
										 completion:nil];
		});
	}
}

- (void)playMovie
{
	PAPhotoData *photoData = [_albumData.photoDatas objectAtIndex:_indexOfPhotoDatas];
	if (photoData.isVideo) {
		_moviePlayerController = [[MPMoviePlayerController alloc] initWithContentURL:photoData.assetURL];
		_moviePlayerController.controlStyle = MPMovieControlStyleFullscreen;
		_moviePlayerController.scalingMode = MPMovieScalingModeAspectFit;
		_moviePlayerController.view.autoresizesSubviews = YES;
		_moviePlayerController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
			_moviePlayerController.view.frame = CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
		}
		else {
			_moviePlayerController.view.frame = [UIScreen mainScreen].bounds;
		}
		_moviePlayerController.fullscreen = YES;
				
		NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
		[center addObserver:self selector:@selector(moviePlayBackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:_moviePlayerController];
		
		[_moviePlayerController prepareToPlay];
		
		_moviePlayerController.view.alpha = 0.0f;
		[self.navigationController.view addSubview:_moviePlayerController.view];
		
		[UIView animateWithDuration:0.5f animations:^{
			_moviePlayerController.view.alpha = 1.0f;
		} completion:^(BOOL finished) {
			[_moviePlayerController play];
		}];
	}
}

- (void)moviePlayBackDidFinish:(NSNotification*)notification
{
    NSDictionary* userInfo = [notification userInfo];
    int reason = [[userInfo objectForKey:
				 @"MPMoviePlayerPlaybackDidFinishReasonUserInfoKey"] intValue];
	if (reason == MPMovieFinishReasonUserExited) {
		[UIView animateWithDuration:0.5f animations:^{
			_moviePlayerController.view.alpha = 0.0f;
		} completion:^(BOOL finished) {
			[_moviePlayerController.view removeFromSuperview];
			_moviePlayerController = nil;
			
			[[UIApplication sharedApplication] setStatusBarHidden:NO];
		}];
    }
}

@end


