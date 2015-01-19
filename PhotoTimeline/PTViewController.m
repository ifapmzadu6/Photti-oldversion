//
//  PTViewController.m
//  PhotoTimeline
//
//  Created by Karijuku Keisuke on 2013/04/03.
//  Copyright (c) 2013年 Keisuke Karijuku. All rights reserved.
//

#import "PTViewController.h"
#import "PTNavigationController.h"
#import "PTTimelineViewController.h"
#import "PTLeftViewController.h"
#import "PTSettingsViewController.h"


@interface PTViewController ()
{
	PTAppDelegate *_ptAppDelegate;
	
	BOOL _isAlertViewDisplayed;
}

@end

@implementation PTViewController

- (void)loadView
{
	[super loadView];
	
	_ptAppDelegate.albumDataController.delegate = self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	self.leftFixedWidth = 270.0f;
}

- (void)viewDidAppear:(BOOL)animated
{
	if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusNotDetermined) {
		if ([UIScreen mainScreen].bounds.size.height == 480) {
			UINavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"PTTutorialNavigationController"];
			navigationController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
			[self presentViewController:navigationController animated:YES completion:^{
				navigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
			}];
		}
		else if ([UIScreen mainScreen].bounds.size.height == 568) {
			UINavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"PTTutorialNavigationController568"];
			navigationController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
			[self presentViewController:navigationController animated:YES completion:^{
				navigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
			}];
		}
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)awakeFromNib
{
	PTAppDelegate *appDelegate = (PTAppDelegate *)[[UIApplication sharedApplication] delegate];
	_ptAppDelegate = appDelegate;
	
	_navigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"PTNavigationController"];
	_navigationController.ptAppDelegate = _ptAppDelegate;
	_navigationController.viewController = self;
	
	[self setCenterPanel:_navigationController];
	
	_leftViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PTLeftViewController"];
	_leftViewController.ptAppDelegate = _ptAppDelegate;
	_leftViewController.viewController = self;
	UINavigationController *leftNavigationController = [[UINavigationController alloc] initWithRootViewController:_leftViewController];
	[self setLeftPanel:leftNavigationController];
}

- (void)stylePanel:(UIView *)panel {
}

#pragma mark PAAlbumDataControllerDelegate
- (void)willAccessPhotoLibrary
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSInteger count = [userDefaults integerForKey:@"CountOfLaunched"];
	if (count == 0) {
		[userDefaults setBool:YES forKey:@"CheckPhotoStreamEnable2"];
	}
	else if ([userDefaults boolForKey:@"CheckPhotoStreamEnable2"] == NO) {
		_isAlertViewDisplayed = YES;
		dispatch_async(dispatch_get_main_queue(), ^{
			[self performSelector:@selector(showPhotoStreamEnableAlertView) withObject:nil afterDelay:0.3f];
		});
		
		while (_isAlertViewDisplayed == YES) {
			[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
		}
		
		dispatch_async(dispatch_get_main_queue(), ^{
			MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:_ptAppDelegate.window animated:YES];
			NSString *title = NSLocalizedString(@"Loading...", @"PTViewController");
			hud.labelText = title;
		});
	}
	
	if (_ptAppDelegate.albumDataController.isFirstAccess == NO) {
		dispatch_async(dispatch_get_main_queue(), ^{
			MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:_ptAppDelegate.window animated:YES];
			NSString *title = NSLocalizedString(@"Loading...", @"PTViewController");
			hud.labelText = title;
		});
	}
	
	[self reloadData];
}

- (void)didAccessPhotoLibrary
{
	dispatch_async(dispatch_get_main_queue(), ^{
		[MBProgressHUD hideHUDForView:_ptAppDelegate.window animated:YES];
	});
	[self reloadData];
}

- (void)reloadData
{
	id navigationController = (id)self.centerPanel;
	[navigationController performSelector:@selector(reloadData)];
	[_leftViewController reloadData];
}

- (void)centerPanelShowAllPhotos
{
	dispatch_async(dispatch_get_main_queue(), ^{
		if ([_navigationController.topViewController isMemberOfClass:[PTAlbumViewController class]] == NO) {
			PTAlbumViewController *albumViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PTAlbumViewController"];
			albumViewController.isAllPhotos = YES;
			albumViewController.allPhoto = _ptAppDelegate.albumDataController.allPhoto;
			[_navigationController setViewControllers:@[albumViewController]];
		}
		[self showCenterPanelAnimated:YES];
	});
}

- (void)centerPanelShowAlbumWithIndex:(NSInteger)index
{
	dispatch_async(dispatch_get_main_queue(), ^{
		if ([_navigationController.topViewController isMemberOfClass:[PTTimelineViewController class]] == NO) {
			PTTimelineViewController *timelineViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PTTimelineViewController"];
			timelineViewController.firstNumberOfRows = index;
			[_navigationController setViewControllers:@[timelineViewController]];
		}
		else {
			[_navigationController moveTimelineAtIndex:index];
		}
		
		[self showCenterPanelAnimated:YES];
	});
}

- (void)centerPanelShowSettings
{
	dispatch_async(dispatch_get_main_queue(), ^{
		PTSettingsViewController *settingsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PTSettingsViewController"];
		settingsViewController.viewController = self;
		[_navigationController setViewControllers:@[settingsViewController]];
		
		[self showCenterPanelAnimated:YES];
	});
}

- (BOOL)shouldAutorotate
{
	return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
	return [_navigationController supportedInterfaceOrientations];
}

- (void)showPhotoStreamEnableAlertView
{	
	NSString *title = NSLocalizedString(@"Do you load the photos from Photo Stream?", @"PTAppDelegate");
	NSString *disable = NSLocalizedString(@"Disable", @"PTViewController");
	NSString *enable = NSLocalizedString(@"Enable", @"PTViewController");
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
														message:nil
														   delegate:self
												  cancelButtonTitle:disable
												  otherButtonTitles:enable, nil];
	alertView.tag = 222;
	
	[alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	if (alertView.tag == 222) {
		if (buttonIndex == 0) {
			//disable
			[userDefaults setBool:NO forKey:@"EnablePhotoStream"];
		}
		else if (buttonIndex == 1) {
			//enable
			[userDefaults setBool:YES forKey:@"EnablePhotoStream"];
		}
	}
	_isAlertViewDisplayed = NO;
	[userDefaults setBool:YES forKey:@"CheckPhotoStreamEnable2"];
	[userDefaults synchronize];
}

@end
