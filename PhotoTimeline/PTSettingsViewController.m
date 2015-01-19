//
//  PTSettingsViewController.m
//  PhotoTimeline
//
//  Created by Karijuku Keisuke on 2013/05/16.
//  Copyright (c) 2013年 Keisuke Karijuku. All rights reserved.
//

#import "PTSettingsViewController.h"

#import "PTViewController.h"

@interface PTSettingsViewController ()
{
	PTAppDelegate *_appDelegate;
}

@end

@implementation PTSettingsViewController

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
	
	PTAppDelegate *appDelegate = (PTAppDelegate *)[[UIApplication sharedApplication] delegate];
	_appDelegate = appDelegate;
	
	[self.navigationItem setTitle:@"Settings"];

	UIButton *customView = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 36.0f, 36.0f)];
	 [customView setImage:[UIImage imageNamed:@"259-list.png"] forState:UIControlStateNormal];
	 [customView setImage:[UIImage imageNamed:@"259-list_touched.png"] forState:UIControlStateHighlighted];
	customView.showsTouchWhenHighlighted = YES;
	customView.exclusiveTouch = YES;
	[customView addTarget:self action:@selector(toggleLeftPanel) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:customView];
	self.navigationItem.leftBarButtonItem = buttonItem;
	
	_appIconImageView.layer.cornerRadius = 10.0f;
	_appIconImageView.clipsToBounds = YES;
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	if ([userDefaults boolForKey:@"DontMakeByDate"] == YES) {
		_makeByDateButton.on = YES;
	}
	else {
		_makeByDateButton.on = NO;
	}
	if ([userDefaults boolForKey:@"EnablePhotoStream"] == YES) {
		_photoStreamButton.on = YES;
	}
	else {
		_photoStreamButton.on = NO;
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSUInteger)supportedInterfaceOrientations
{
	return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	if (indexPath.section == 2) {
		if (indexPath.row == 0) {
			if (_appDelegate.albumDataController.isEditable == NO) {
				[self showDontEditingAlertView];
				return;
			}
			
			//Reset Album Database
			
			NSString *title = NSLocalizedString(@"Are you sure you want to reset?", @"PTSettingsViewController");
			NSString *cancel = NSLocalizedString(@"Cancel", @"PTSettingsViewController");
			NSString *reset = NSLocalizedString(@"Reset album database", @"PTSettingsViewController");
			UIActionSheet *actionSheet =[[UIActionSheet alloc] initWithTitle:title
																	delegate:self
														   cancelButtonTitle:cancel
													  destructiveButtonTitle:reset
														   otherButtonTitles:nil];
			actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
			[actionSheet showInView:self.view];
		}
	}
	else if (indexPath.section == 3) {
		//About
		if (indexPath.row == 1) {
			//Tutorial
			if ([UIScreen mainScreen].bounds.size.height == 480) {
				UINavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"PTTutorialNavigationController"];
				[self presentViewController:navigationController animated:YES completion:nil];
			}
			else if ([UIScreen mainScreen].bounds.size.height == 568) {
				UINavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"PTTutorialNavigationController568"];
				[self presentViewController:navigationController animated:YES completion:nil];
			}
		}
		else if (indexPath.row == 2) {
			//Review in App Store
			
			NSURL *url = [NSURL URLWithString:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=663410888&mt=8&type=Purple+Software"];
			[[UIApplication sharedApplication] openURL:url];
		}
		else if (indexPath.row == 3) {
			//Twitter
			
			NSURL *url = [NSURL URLWithString:@"http://twitter.com/Photti_dev"];
			[[UIApplication sharedApplication] openURL:url];
		}
	}	
}

#pragma mark ActionSheetDelegate
-(void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 0) {
		//Reset Album Database
		if (_appDelegate.albumDataController.isEditable == NO) {
			[self showDontEditingAlertView];
			return;
		}
		
		PTAppDelegate *appDelegate = (PTAppDelegate *)[[UIApplication sharedApplication] delegate];
		
		NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		BOOL makeAlbumMadeByDate = [userDefaults integerForKey:@"MakeAlbumMadeByDate"];
		[appDelegate.albumDataController resetAlbumDatasWithDivide:makeAlbumMadeByDate];
		
		[appDelegate.albumDataController checkAlbumDataController];
		
		[appDelegate.albumDataController sortAlbumDataByDate];
		
		[appDelegate.albumDataController asyncSaveAlbumDataController];
		
		[_viewController reloadData];
	}
}

- (void)reloadData
{
	
}

- (void)toggleLeftPanel
{
	[_viewController showLeftPanelAnimated:YES];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
//	if ([[segue identifier] isEqualToString:@"SettingsToOrder"]) {
//		PTSettingsPhotoOrderViewController *settingsPhotoOrderViewController = [segue destinationViewController];
//		settingsPhotoOrderViewController.orderMode = _orderModeLabel.text;
//	}
}

- (IBAction)settingsViewViewReturnActionForSegue:(UIStoryboardSegue *)segue
{
//	if ([[segue identifier] isEqualToString:@"SettingsFromOrder"]) {
//		PTSettingsPhotoOrderViewController *settingsPhotoOrderViewController = [segue sourceViewController];
//		if ([settingsPhotoOrderViewController.orderMode isEqualToString:@"Newer"]) {
//			_orderModeLabel.text = @"Newer";
//		}
//		else if ([settingsPhotoOrderViewController.orderMode isEqualToString:@"Older"]) {
//			_orderModeLabel.text = @"Older";
//		}
//	}
}

- (IBAction)photoStreamButtonAction:(id)sender
{
	if (_appDelegate.albumDataController.isEditable == NO) {
		[self showDontEditingAlertView];
		[_photoStreamButton setOn:!_photoStreamButton.on animated:YES];
		return;
	}
	
	[self showEnablePhotoStreamAlertView:_photoStreamButton.on];
}

- (IBAction)makeByDateButtonAction:(id)sender
{
	if (_appDelegate.albumDataController.isEditable == NO) {
		[self showDontEditingAlertView];
		return;
	}
		
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setBool:_makeByDateButton.on forKey:@"DontMakeByDate"];
}

- (void)showDontEditingAlertView
{
	NSString *title = NSLocalizedString(@"This Function is not enabled while loading.", @"PTSettingsViewController");
	NSString *message = NSLocalizedString(@"Please try again after waiting for a while. ", @"PTSettingsViewController");
	NSString *ok = NSLocalizedString(@"OK", @"PTSettingsViewController");
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
													message:message
												   delegate:self
										  cancelButtonTitle:nil
										  otherButtonTitles:ok, nil];
	alertView.tag = 777;
	[alertView show];
}

- (void)showEnablePhotoStreamAlertView:(BOOL)enable
{
	NSString *title;
	NSString *message;
	NSString *ok;
	if (enable == YES) {
		title = NSLocalizedString(@"Do you load the photos from Photo Stream?", @"PTSettingsViewController");
		message = NSLocalizedString(@"When loading the photos from Photo Stream is turned ON, timeline may be changed largely. and there is the same photo in this device, those two photos may be displayed.", @"PTSettingsViewController");
		ok = NSLocalizedString(@"Enable", @"PTSettingsViewController");
	}
	else {
		title = NSLocalizedString(@"Do you stop loading photos from Photo Stream?", @"PTSettingsViewController");
		message = NSLocalizedString(@"When loading the photos from Photo Stream is turned OFF, timeline may be changed largely.", @"PTSettingsViewController");
		ok = NSLocalizedString(@"Disable", @"PTSettingsViewController");
	}
	NSString *cancel = NSLocalizedString(@"Cancel", @"PTSettingsViewController");
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
													message:message
												   delegate:self
										  cancelButtonTitle:cancel
										  otherButtonTitles:ok, nil];
	alertView.tag = 555;
	[alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertView.tag == 555) {
		if (buttonIndex == 0) {
			[_photoStreamButton setOn:!_photoStreamButton.on animated:YES];
		}
		else if (buttonIndex == 1) {
			NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
			[userDefaults setBool:_photoStreamButton.on forKey:@"EnablePhotoStream"];
			
			[_appDelegate.albumDataController accessPhotoLibrary];
		}
	}
}

@end
