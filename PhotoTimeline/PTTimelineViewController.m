//
//  PTTimelineViewController.m
//  PhotoTimeline
//
//  Created by Karijuku Keisuke on 2013/04/03.
//  Copyright (c) 2013年 Keisuke Karijuku. All rights reserved.
//

#import "PTTimelineViewController.h"

#import "PTAlbumViewController.h"
#import "PTNavigationController.h"

#import "PTCombineViewController.h"

@interface PTTimelineViewController ()
{
	PTAppDelegate *_ptAppDelegate;
	
	PTNavigationController *_navigationController;
		
	NSInteger _selectedIndex;
	
	NSOperationQueue *_queue;
	
	NSMutableArray *_thumbnailImages;
	
	NSMutableArray *_selectedIndexPaths;
		
	PTDivideViewController *_divideViewController;
	PTCombineViewController *_combineViewController;
	
	NSIndexPath *_moveIntexPath;
}

@end

@implementation PTTimelineViewController


#pragma mark - ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[self initNavigationItem];
		
	PTAppDelegate *appDelegate = (PTAppDelegate *)[[UIApplication sharedApplication] delegate];
	_ptAppDelegate = appDelegate;
	
	_navigationController = (PTNavigationController *)self.navigationController;
	
	_queue = [[NSOperationQueue alloc] init];
	_queue.maxConcurrentOperationCount = 1;
	
	_selectedIndexPaths = [NSMutableArray array];
	
	[self loadThumbnailImages];
	
	if ([_tableView numberOfRowsInSection:0] > 0) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_firstNumberOfRows inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
		});
	}
}

- (void)initNavigationItem
{
	NSString *timeline = NSLocalizedString(@"Timeline", @"PTTimelineViewController");
	[self.navigationItem setTitle:timeline];
	
	UIButton *customView = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 36.0f, 36.0f)];
	[customView setImage:[UIImage imageNamed:@"259-list.png"] forState:UIControlStateNormal];
	[customView setImage:[UIImage imageNamed:@"259-list_touched.png"] forState:UIControlStateHighlighted];
	customView.showsTouchWhenHighlighted = YES;
	customView.exclusiveTouch = YES;
	[customView addTarget:self action:@selector(toggleLeftPanel) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem* buttonItem = [[UIBarButtonItem alloc] initWithCustomView:customView];
	self.navigationItem.leftBarButtonItem = buttonItem;
	
	UIButton *customView1 = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 36.0f, 36.0f)];
	[customView1 setImage:[UIImage imageNamed:@"05-plus_gray.png"] forState:UIControlStateNormal];
	[customView1 setImage:[UIImage imageNamed:@"05-plus_gray_touched.png"] forState:UIControlStateHighlighted];
	customView1.showsTouchWhenHighlighted = YES;
	customView1.exclusiveTouch = YES;
	[customView1 addTarget:self action:@selector(topBarRightUIButton) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem* buttonItem1 = [[UIBarButtonItem alloc] initWithCustomView:customView1];
	
	UIButton *customView2 = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 36.0f, 36.0f)];
	[customView2 setImage:[UIImage imageNamed:@"01-magnify.png"] forState:UIControlStateNormal];
	[customView2 setImage:[UIImage imageNamed:@"01-magnify_touched.png"] forState:UIControlStateHighlighted];
	customView2.showsTouchWhenHighlighted = YES;
	customView2.exclusiveTouch = YES;
	[customView2 addTarget:self action:@selector(searchButtonAction) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *buttonItem2 = [[UIBarButtonItem alloc] initWithCustomView:customView2];
	
	self.navigationItem.rightBarButtonItems = @[buttonItem1, buttonItem2];
}

- (void)loadThumbnailImages
{
	NSMutableArray *thumbnailImages = [[NSMutableArray alloc] init];
	for (PAAlbumData *albumData in _ptAppDelegate.albumDataController.albumDatas) {
		id image;
		if (albumData.photoDatas.count > 0 && albumData.thumbnailIndex <= albumData.photoDatas.count - 1) {
			PAPhotoData *photoData = [albumData.photoDatas objectAtIndex:albumData.thumbnailIndex];
			if (photoData.asset != nil) {
				image = [UIImage imageWithCGImage:photoData.asset.aspectRatioThumbnail];
			}
			else {
				image = [NSNumber numberWithBool:NO];
			}
		}
		else {
			image = [NSNumber numberWithBool:NO];
		}
		[thumbnailImages addObject:image];
	}
	
	_thumbnailImages = thumbnailImages;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	_combineViewController = nil;
	_divideViewController = nil;
			
//	if (_isLeftPanelOpened) {
//		[_navigationController leftPanelShow];
//		_isLeftPanelOpened = NO;
//	}
	
	//	NSLog(@"[%d]", queueCount);
}

- (void)viewDidAppear:(BOOL)animated
{	
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	
	[_queue cancelAllOperations];
	
	SDWebImageManager *imageManager = [SDWebImageManager sharedManager];
	[imageManager.imageCache clearMemory];
}

- (NSUInteger)supportedInterfaceOrientations
{
	return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)topBarRightUIButton
{	
	if (_ptAppDelegate.albumDataController.isEditable == NO) {
		[self showDontEditingAlertView];
		return;
	}
	
	[self showAlbumTitleAlertView:YES];
}

- (void)searchButtonAction
{	
	UIView *overlayView = [[UIView alloc] initWithFrame:self.view.bounds];
	overlayView.alpha = 0.0f;
	overlayView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.666f];
	overlayView.userInteractionEnabled = NO;
	[self.view addSubview:overlayView];
	[UIView animateWithDuration:0.5f animations:^{
		overlayView.alpha = 1.0f;
	} completion:^(BOOL finished) {
		[overlayView removeFromSuperview];
	}];
	
	[self performSegueWithIdentifier:@"TimelineToSearch" sender:self];
}


#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _ptAppDelegate.albumDataController.albumDatas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
	
    // Configure the cell...
	UILabel *titleLabel = (UILabel *)[cell viewWithTag:1];
	UILabel *photoLabel = (UILabel *)[cell viewWithTag:2];
	UILabel *dateLabel = (UILabel *)[cell viewWithTag:3];
	PTImageView *imageView = (PTImageView *)[cell viewWithTag:4];
	UIActivityIndicatorView *activityIndicatorView = (UIActivityIndicatorView *)[cell viewWithTag:5];
	
	UIButton *facebookButton = (UIButton *)[cell viewWithTag:6];
	UIButton *saveAlbumButton = (UIButton *)[cell viewWithTag:7];
	UIButton *settingsAlbumButton = (UIButton *)[cell viewWithTag:8];
	
	UIImageView *newBadgeView = (UIImageView *)[cell viewWithTag:9];
	
	if (cell.tag != 500) {
		[facebookButton setImage:[UIImage imageNamed:@"215-photos_touched.png"] forState:UIControlStateHighlighted];
		facebookButton.exclusiveTouch = YES;
		[saveAlbumButton setImage:[UIImage imageNamed:@"216-scissors_touched.png"] forState:UIControlStateHighlighted];
		saveAlbumButton.exclusiveTouch = YES;
		[settingsAlbumButton setImage:[UIImage imageNamed:@"217-trash_touched.png"] forState:UIControlStateHighlighted];
		settingsAlbumButton.exclusiveTouch = YES;
		
		cell.tag = 500;
	}
	
	PAAlbumData *albumData = [_ptAppDelegate.albumDataController.albumDatas objectAtIndex:indexPath.row];
	
	if (albumData.title != nil) {
		titleLabel.textColor = [UIColor colorWithRed:0.204f green:0.212f blue:0.239f alpha:1.0f];
	}
	else {
		titleLabel.textColor = [UIColor colorWithRed:0.204f green:0.212f blue:0.239f alpha:0.55f];
	}
	titleLabel.text = albumData.displayTitleString;
	UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAlbumTitle:)];
	[titleLabel setGestureRecognizers:@[tapGesture]];
	
	photoLabel.text = albumData.displayCountString;
	
	dateLabel.text = albumData.displayDateString;
	
	if (albumData.photoDatas.count > 0 && albumData.thumbnailIndex <= albumData.photoDatas.count - 1) {
		PAPhotoData *photoData = [albumData.photoDatas objectAtIndex:albumData.thumbnailIndex];
		
		if (photoData.asset != nil) {
			id thumbnail = [_thumbnailImages objectAtIndex:indexPath.row];
			if ([thumbnail isMemberOfClass:[UIImage class]]) {
				[imageView loadImageFromAsset:photoData.asset thumbnail:thumbnail];
				
				if (activityIndicatorView.isAnimating) {
					[activityIndicatorView stopAnimating];
				}
			}
			else {
				[imageView setImageNil];
				
				if (activityIndicatorView.isAnimating == NO) {
					[activityIndicatorView startAnimating];
				}
			}
		}
		else {
			[imageView setImageNil];
			
			if (activityIndicatorView.isAnimating == NO) {
				[activityIndicatorView startAnimating];
			}
		}
	}
	else {
		[imageView DisplayNoPhotos];
		
		if (activityIndicatorView.isAnimating) {
			[activityIndicatorView stopAnimating];
		}
	}
	
	if (albumData.photoDatas.count < 2) {
		saveAlbumButton.enabled = NO;
	}
	else {
		saveAlbumButton.enabled = YES;
	}
	
	if (albumData.isNew) {
		if (newBadgeView.hidden == YES) {
			newBadgeView.hidden = NO;
		}
	}
	else {
		if (newBadgeView.hidden == NO) {
			newBadgeView.hidden = YES;
		}
	}
	
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 340;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self performSegueWithIdentifier:@"TimelineToAlbum" sender:self];
}

#pragma mark Action
- (void)tapAlbumTitle:(id)sender
{
	if (_ptAppDelegate.albumDataController.isEditable == NO) {
		[self showDontEditingAlertView];
		return;
	}
	
	UITapGestureRecognizer *tapGesture = (UITapGestureRecognizer *)sender;
	UILabel *label = (UILabel *)tapGesture.view;
	UITableViewCell *cell = (UITableViewCell *)[[label superview] superview];
	_selectedIndex = [self.tableView indexPathForCell:cell].row;
	
	[self showAlbumTitleAlertView:NO];
}

- (IBAction)settingsAlbumButtonAction:(id)sender
{
	if (_ptAppDelegate.albumDataController.isEditable == NO) {
		[self showDontEditingAlertView];
		return;
	}
	
	UIButton *button = (UIButton *)sender;
	UITableViewCell *cell = (UITableViewCell *)[[button superview] superview];
	_selectedIndex = [self.tableView indexPathForCell:cell].row;
	
	NSString *title = NSLocalizedString(@"Are you sure you want to delete this album? The photos will not be deleted.", @"PTTimelineViewController");
	NSString *cancel = NSLocalizedString(@"Cancel", @"PTTimelineViewController");
	NSString *deleteAlbum = NSLocalizedString(@"Delete this album", @"PTTimelineViewController");
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:cancel destructiveButtonTitle:deleteAlbum otherButtonTitles:nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	[actionSheet showInView:self.view];
}

- (IBAction)saveAlbumButtonAction:(id)sender
{
	if (_ptAppDelegate.albumDataController.isEditable == NO) {
		[self showDontEditingAlertView];
		return;
	}
	
	UIButton *button = (UIButton *)sender;
	UITableViewCell *cell = (UITableViewCell *)[[button superview] superview];
	_selectedIndex = [self.tableView indexPathForCell:cell].row;
	
	PAAlbumData *albumData = [_ptAppDelegate.albumDataController.albumDatas objectAtIndex:_selectedIndex];
	if (albumData.photoDatas.count > 1) {
		_divideViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PTDivideViewController"];
		_divideViewController.albumData = [_ptAppDelegate.albumDataController.albumDatas objectAtIndex:_selectedIndex];
		_divideViewController.myDelegate = self;
		
		PTAlbumSettingsNavigationController *navigationController = [[PTAlbumSettingsNavigationController alloc] initWithRootViewController:_divideViewController];
	
		[self presentViewController:navigationController animated:YES completion:nil];
	}
}

- (IBAction)facebookAlbumButtonAction:(id)sender
{
	if (_ptAppDelegate.albumDataController.isEditable == NO) {
		[self showDontEditingAlertView];
		return;
	}
	
	UIButton *button = (UIButton *)sender;
	UITableViewCell *cell = (UITableViewCell *)[[button superview] superview];
	_selectedIndex = [self.tableView indexPathForCell:cell].row;
	
	_combineViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PTCombineViewController"];
	_combineViewController.albumDatas = _ptAppDelegate.albumDataController.albumDatas;
	_combineViewController.firstIndexPath = [NSIndexPath indexPathForRow:_selectedIndex inSection:0];
	_combineViewController.myDelegate = self;
	
	PTAlbumSettingsNavigationController *navigationController = [[PTAlbumSettingsNavigationController alloc] initWithRootViewController:_combineViewController];
		
	[self presentViewController:navigationController animated:YES completion:nil];
}


#pragma mark ActionSheet

-(void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	NSString *title = NSLocalizedString(@"Are you sure you want to delete this album? The photos will not be deleted.", @"PTTimelineViewController");
	if ([actionSheet.title isEqualToString:title]) {
		if (buttonIndex == 0) {
			[_ptAppDelegate.albumDataController.albumDatas removeObjectAtIndex:_selectedIndex];
			
			[_ptAppDelegate.albumDataController asyncSaveAlbumDataController];
			
			[_navigationController requestReloadData];
		}
	}
}

#pragma Segue
- (void)reloadData
{
	NSLog(@"Reload-PTTimelineViewController");
	
	[self loadThumbnailImages];
	
	dispatch_async(dispatch_get_main_queue(), ^{		
		[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
		
		if (_moveIntexPath != nil) {
			if (_moveIntexPath.row <= [self.tableView numberOfRowsInSection:_moveIntexPath.section] - 1) {
				[self.tableView scrollToRowAtIndexPath:_moveIntexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
				_moveIntexPath = nil;
			}
		}
	});
	
	if (_divideViewController != nil) {
		[_divideViewController reloadData];
	}
	if (_combineViewController != nil) {
		[_combineViewController reloadData];
	}
}

#pragma mark Segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"TimelineToAlbum"]) {
		PTAlbumViewController *albumViewController = [segue destinationViewController];
		NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
		PAAlbumData *albumData = [_ptAppDelegate.albumDataController.albumDatas objectAtIndex:indexPath.row];
		if (albumData.isNew == YES) {
			albumData.isOpened = YES;
		}
		
		albumViewController.albumData = albumData;		
		albumViewController.allPhoto = _ptAppDelegate.albumDataController.allPhoto;
		
		albumViewController.returnSegueIdentifier = @"TimelineFromAlbum";
	}
}

- (IBAction)timelineViewReturnActionForSegue:(UIStoryboardSegue *)segue
{
	if ([[segue identifier] isEqualToString:@"TimelineFromAlbum"]) {
		PTAlbumViewController *albumViewController = [segue sourceViewController];
		
		if (albumViewController.isDeleteAlbum) {
			[_ptAppDelegate.albumDataController.albumDatas removeObject:albumViewController.albumData];
			
			[_ptAppDelegate.albumDataController asyncSaveAlbumDataController];
			
			[_navigationController requestReloadData];
		}
		else {
			NSUInteger index = [_ptAppDelegate.albumDataController.albumDatas indexOfObject:albumViewController.albumData];
			NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
			
			[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
		}
	}
	else if ([segue.identifier isEqualToString:@"TimelineFromSearch"]) {
		PTSearchViewController *searchViewController = [segue sourceViewController];
		
		if (searchViewController.overlayView != nil) {
			UIView *overlayView = [[UIView alloc] initWithFrame:self.view.bounds];
			overlayView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.666f];
			overlayView.userInteractionEnabled = NO;
			[self.view addSubview:overlayView];
			[UIView animateWithDuration:0.5f animations:^{
				overlayView.alpha = 0.0f;
			} completion:^(BOOL finished) {
				[overlayView removeFromSuperview];
			}];
		}
	}
}

#pragma mark Etc.
- (void)showAlbumTitleAlertView:(BOOL)isNew
{
	NSString *title;
	if (isNew) {
		title = NSLocalizedString(@"New Album", @"PTTimelineViewController");
	}
	else {
		title = NSLocalizedString(@"Album Title", @"PTTimelineViewController");
	}
	NSString *message = NSLocalizedString(@"Enter a title for this album.", @"PTTimelineViewController");
	NSString *cancel = NSLocalizedString(@"Cancel", @"PTTimelineViewController");
	NSString *done = NSLocalizedString(@"Done", @"PTTimelineViewController");
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
													message:message
												   delegate:self
										  cancelButtonTitle:cancel
										  otherButtonTitles:done, nil];
	alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
	
	if (isNew) {
		alertView.tag = 444;
	}
	else {
		alertView.tag = 555;
	}
	
	UITextField* textField = [alertView textFieldAtIndex:0];
	if (isNew == NO) {
		PAAlbumData *albumData = [_ptAppDelegate.albumDataController.albumDatas objectAtIndex:_selectedIndex];
		textField.text = albumData.title;
	}
	textField.returnKeyType = UIReturnKeyDone;
	textField.delegate = self;
	
	[alertView show];	
}

- (void)showDontEditingAlertView
{
	NSString *title = NSLocalizedString(@"This function is not enabled while loading.", @"PTTimelineViewController");
	NSString *message = NSLocalizedString(@"Please try again after waiting for a while. ", @"PTTimelineViewController");
	NSString *ok = NSLocalizedString(@"OK", @"PTTimelineViewController");
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
													message:message
												   delegate:self
										  cancelButtonTitle:nil
										  otherButtonTitles:ok, nil];
	alert.tag = 777;
	[alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertView.tag == 555) {
		//showAlbumTitleAlertView
		if (buttonIndex == 1) {
			//Doneボタンが押されたとき
			UITextField *textField = [alertView textFieldAtIndex:0];
			NSString *text = textField.text;
			
			PAAlbumData *albumData = [_ptAppDelegate.albumDataController.albumDatas objectAtIndex:_selectedIndex];
			albumData.title = text;
			[albumData checkAlbumData];
			
			[_navigationController requestReloadData];
			
			[_ptAppDelegate.albumDataController asyncSaveAlbumDataController];
		}
	}
	else if (alertView.tag == 444) {
		if (buttonIndex == 1) {
			UITextField *textField = [alertView textFieldAtIndex:0];
			NSString *text = textField.text;
			
			PAAlbumData *newAlbumData = [[PAAlbumData alloc] init];
			newAlbumData.title = text;
			[newAlbumData checkAlbumData];
			newAlbumData.isNew = YES;
			newAlbumData.createDate = [NSDate date];
			newAlbumData.isOpened = NO;
			
			[_ptAppDelegate.albumDataController.albumDatas insertObject:newAlbumData atIndex:0];
			
			[_ptAppDelegate.albumDataController asyncSaveAlbumDataController];
			
			_moveIntexPath = [NSIndexPath indexPathForRow:0 inSection:0];
			
			[_navigationController requestReloadData];
		}
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)alertTextField
{
	UIAlertView *alertView = (UIAlertView *)[alertTextField superview];
	
	[self alertView:alertView clickedButtonAtIndex:1];
	[alertView dismissWithClickedButtonIndex:1 animated:YES];
	
	return YES;
}

- (void)combineAlbums:(NSMutableArray *)selectedAlbumDatas
{
	PAAlbumData *newAlbumData = [_ptAppDelegate.albumDataController combinedAlbumDataFromAlbumDatas:selectedAlbumDatas];
	
	for (PAAlbumData *albumData in selectedAlbumDatas) {
		[_ptAppDelegate.albumDataController.albumDatas removeObject:albumData];
	}
	
	[_ptAppDelegate.albumDataController.albumDatas addObject:newAlbumData];
	
	[_ptAppDelegate.albumDataController sortAlbumDataByDate];
	
	[_ptAppDelegate.albumDataController asyncSaveAlbumDataController];
	
	NSUInteger moveIndex = [_ptAppDelegate.albumDataController.albumDatas indexOfObject:newAlbumData];
	_moveIntexPath = [NSIndexPath indexPathForRow:moveIndex inSection:0];
	
	[_navigationController requestReloadData];
}

- (void)divideAlbum:(PAAlbumData *)albumData
{
	[_ptAppDelegate.albumDataController.albumDatas addObject:albumData];
	
	[_ptAppDelegate.albumDataController sortAlbumDataByDate];
	
	NSUInteger moveIndex = [_ptAppDelegate.albumDataController.albumDatas indexOfObject:albumData];
	_moveIntexPath = [NSIndexPath indexPathForRow:moveIndex inSection:0];
	
	[_ptAppDelegate.albumDataController asyncSaveAlbumDataController];
	
	[_navigationController requestReloadData];
}


- (void)toggleLeftPanel
{
	[_navigationController showLeftPanel];
}

@end



@implementation CustomToolbar

- (void)drawRect:(CGRect)rect {
	
	// デフォルトの境界線の描画を無効に
}

@end
