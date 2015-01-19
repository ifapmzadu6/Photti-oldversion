//
//  PTSearchViewController.m
//  PhotoTimeline
//
//  Created by Karijuku Keisuke on 2013/07/29.
//  Copyright (c) 2013年 Keisuke Karijuku. All rights reserved.
//

#import "PTSearchViewController.h"

@interface PTSearchViewController ()
{
	PTAppDelegate *_appDelegate;
	
	PTNavigationController *_navigationController;
	
	UISearchBar *_searchBar;
		
	NSArray *_searchResults;
	
	NSOperationQueue *_queue;
}

@end

@implementation PTSearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	UIButton *customView = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 36.0f, 36.0f)];
	[customView setImage:[UIImage imageNamed:@"09-arrow-west.png"] forState:UIControlStateNormal];
	[customView setImage:[UIImage imageNamed:@"09-arrow-west_touched.png"] forState:UIControlStateHighlighted];
	customView.showsTouchWhenHighlighted = YES;
	customView.exclusiveTouch = YES;
	[customView addTarget:self action:@selector(backBarUIButton) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem* buttonItem = [[UIBarButtonItem alloc] initWithCustomView:customView];
	self.navigationItem.leftBarButtonItem = buttonItem;
	
	_appDelegate = (PTAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	_navigationController = (PTNavigationController *)self.navigationController;
	
	_searchBar = [[UISearchBar alloc] init];
	_searchBar.delegate = self;
	_searchBar.tintColor = [UIColor whiteColor];
	_searchBar.placeholder = NSLocalizedString(@"Search", @"PTSearchViewController");
	self.navigationItem.titleView = _searchBar;
	self.navigationItem.titleView.frame = CGRectMake(0, 0, 320, 44);
	
	[_searchBar becomeFirstResponder];
	
	_queue = [[NSOperationQueue alloc] init];
	_queue.maxConcurrentOperationCount = 1;
	
	_overlayView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
	_overlayView.alpha = 0.0f;
	_overlayView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.666f];
	[self.view addSubview:_overlayView];
	[UIView animateWithDuration:0.5f animations:^{
		_overlayView.alpha = 1.0f;
	}];
	
	self.tableView.scrollEnabled = NO;
	
	UISwipeGestureRecognizer* swipeRightGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRightGesture:)];
	swipeRightGesture.direction = UISwipeGestureRecognizerDirectionRight;
	[self.view addGestureRecognizer:swipeRightGesture];
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

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	[_searchBar resignFirstResponder];
	
	if (_overlayView != nil) {
		[UIView animateWithDuration:0.5f animations:^{
			_overlayView.alpha = 0.0f;
		} completion:^(BOOL finished) {
			[_overlayView removeFromSuperview];
			_overlayView = nil;
		}];
	}
}

- (void)backBarUIButton
{
	[self performSegueWithIdentifier:@"TimelineFromSearch" sender:self];
}

- (void)handleSwipeRightGesture:(UISwipeGestureRecognizer *)sender
{
	[self backBarUIButton];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _searchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
	
	UIImageView *imageView = (UIImageView *)[cell viewWithTag:1];
	UILabel *titleLabel = (UILabel *)[cell viewWithTag:2];
	UILabel *photosLabel = (UILabel *)[cell viewWithTag:3];
	UILabel *dateLabel = (UILabel *)[cell viewWithTag:4];
    
    PAAlbumData *albumData = [_searchResults objectAtIndex:indexPath.row];
	if (albumData.photoDatas.count > 0 && albumData.thumbnailIndex <= albumData.photoDatas.count - 1) {
		PAPhotoData *photoData = [albumData.photoDatas objectAtIndex:albumData.thumbnailIndex];
		
		imageView.image = [photoData aspectRatioThumbnail];
	}
	else {
		UIImage *image = [UIImage imageNamed:@"Picture_mini.png"];
		[imageView setImage:image];
	}
	
	if (albumData.title == nil) {
		titleLabel.textColor = [UIColor colorWithRed:0.204f green:0.212f blue:0.239f alpha:0.55f];
	}
	else {
		titleLabel.textColor = [UIColor colorWithRed:0.204f green:0.212f blue:0.239f alpha:1.0f];
	}
	titleLabel.text = albumData.displayTitleString;
	
	photosLabel.text = [NSString stringWithFormat:@"(%d)", albumData.photoDatas.count];
	
	dateLabel.text = albumData.displayDateString;
	
	CGSize titleLabelSize = [titleLabel.text sizeWithFont:titleLabel.font constrainedToSize:CGSizeMake(182.0f, 21.0f) lineBreakMode:NSLineBreakByTruncatingTail];
	titleLabel.frame = CGRectMake(titleLabel.frame.origin.x, titleLabel.frame.origin.y, titleLabelSize.width, titleLabel.frame.size.height);
	CGFloat photoLabelX = titleLabel.frame.origin.x + titleLabel.frame.size.width + 4.0f;
	CGFloat photoLabelWidth = 300.0f - photoLabelX;
	photosLabel.frame = CGRectMake(photoLabelX, photosLabel.frame.origin.y, photoLabelWidth, photosLabel.frame.size.height);
	
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self performSegueWithIdentifier:@"SearchToAlbum" sender:self];
	
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SearchToAlbum"]) {
		PTAlbumViewController *albumViewController = [segue destinationViewController];
		NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
		PAAlbumData *albumData = [_searchResults objectAtIndex:indexPath.row];
		if (albumData.isNew == YES) {
			albumData.isOpened = YES;
		}
		
		albumViewController.albumData = albumData;
		albumViewController.allPhoto = _appDelegate.albumDataController.allPhoto;
		
		albumViewController.returnSegueIdentifier = @"SearchFromAlbum";
	}
}

- (IBAction)searchViewReturnActionForSegue:(UIStoryboardSegue *)segue
{
	if ([segue.identifier isEqualToString:@"SearchFromAlbum"]) {
		PTAlbumViewController *albumViewController = [segue sourceViewController];
		if (albumViewController.isDeleteAlbum) {
			[_appDelegate.albumDataController.albumDatas removeObject:albumViewController.albumData];
			
			[_appDelegate.albumDataController asyncSaveAlbumDataController];
			
			[_navigationController requestReloadData];
			dispatch_async(dispatch_get_main_queue(), ^{
				[MBProgressHUD hideHUDForView:_appDelegate.window animated:YES];
			});
		}
	}
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
	[self reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	[_searchBar resignFirstResponder];
}

#pragma mark - NavigationController

- (void)reloadData
{
	NSMutableArray *searchResults = [NSMutableArray array];
	
	for (PAAlbumData *albumData in _appDelegate.albumDataController.albumDatas) {
		if (albumData.title != nil) {
			NSRange range = [albumData.title rangeOfString:_searchBar.text options:NSCaseInsensitiveSearch];
			if (range.location != NSNotFound) {
				[searchResults addObject:albumData];
			}
		}
	}
	
	_searchResults = [searchResults copy];
	
	dispatch_async(dispatch_get_main_queue(), ^{
		if (_searchResults.count > 0) {
			if (_overlayView != nil) {
				[_overlayView removeFromSuperview];
				_overlayView = nil;
				self.tableView.scrollEnabled = YES;
			}
		}
		else {
			if (_overlayView == nil) {
				_overlayView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
				_overlayView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.666f];
				[self.view addSubview:_overlayView];
				
				[self.tableView setContentOffset:CGPointZero animated:NO];
				self.tableView.scrollEnabled = NO;
			}
		}
		
		[self.tableView reloadData];
	});
}

@end
