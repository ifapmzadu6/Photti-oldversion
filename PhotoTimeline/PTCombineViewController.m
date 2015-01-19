//
//  PTCombineViewController.m
//  PhotoTimeline
//
//  Created by Karijuku Keisuke on 2013/05/21.
//  Copyright (c) 2013年 Keisuke Karijuku. All rights reserved.
//

#import "PTCombineViewController.h"

@interface PTCombineViewController ()
{
	PTAppDelegate *_ptAppDelegate;
	
	PTCombineAlbumViewController *_combineAlbumViewController;
}

@end

@implementation PTCombineViewController

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
	_ptAppDelegate = appDelegate;
	
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 200.0f, 44.0f)];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.textAlignment = NSTextAlignmentCenter;
	NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowOffset = CGSizeMake(0.0f, 1.0f);
    shadow.shadowColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.8];
    shadow.shadowBlurRadius = 0.0f;
	NSDictionary *attributes = @{NSShadowAttributeName : shadow,
							  NSFontAttributeName : [UIFont boldSystemFontOfSize:20],
							  NSForegroundColorAttributeName : [UIColor colorWithRed:0.204f green:0.212f blue:0.239f alpha:1.0f]};
	NSString *title = NSLocalizedString(@"Combine albums", @"PTCombineViewController");
	NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attributes];
	titleLabel.attributedText = attributedTitle;
	[self.navigationItem setTitleView:titleLabel];
	
	[self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
	
	UIButton *customView = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 36.0f, 36.0f)];
	[customView setImage:[UIImage imageNamed:@"60-x.png"] forState:UIControlStateNormal];
	[customView setImage:[UIImage imageNamed:@"60-x_touched.png"] forState:UIControlStateHighlighted];
	customView.showsTouchWhenHighlighted = YES;
	customView.exclusiveTouch = YES;
	[customView addTarget:self action:@selector(cancelButtonAction) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem* buttonItem = [[UIBarButtonItem alloc] initWithCustomView:customView];
	self.navigationItem.leftBarButtonItem = buttonItem;
	
	UIButton *customView1 = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 36.0f, 36.0f)];
	[customView1 setImage:[UIImage imageNamed:@"47-o.png"] forState:UIControlStateNormal];
	[customView1 setImage:[UIImage imageNamed:@"47-o_touched.png"] forState:UIControlStateHighlighted];
	customView1.showsTouchWhenHighlighted = YES;
	customView1.exclusiveTouch = YES;
	[customView1 addTarget:self action:@selector(didSelectPhotos) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem* buttonItem1 = [[UIBarButtonItem alloc] initWithCustomView:customView1];
	self.navigationItem.rightBarButtonItem = buttonItem1;
	
	UIView *statusbarView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 20.0f)];
	statusbarView.backgroundColor = [UIColor whiteColor];
	[self.navigationController.view addSubview:statusbarView];
	
	[self.tableView selectRowAtIndexPath:_firstIndexPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _albumDatas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
	
	UIImageView *imageView = (UIImageView *)[cell viewWithTag:1];
	UILabel *titleLabel = (UILabel *)[cell viewWithTag:2];
	UILabel *photosLabel = (UILabel *)[cell viewWithTag:3];
	UILabel *dateLabel = (UILabel *)[cell viewWithTag:4];
    
    PAAlbumData *albumData = [_albumDatas objectAtIndex:indexPath.row];
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 24.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	PTSectionHeader *containerView = [[PTSectionHeader alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 24.0f)];
	containerView.alpha = 0.85f;
	
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 0.0f, 300.0f, 24.0f)];
	label.backgroundColor = [UIColor clearColor];
	NSString *title = NSLocalizedString(@"Timeline", @"PTCombineViewController");
	label.text = title;
	label.textColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.8f];
	label.font = [UIFont boldSystemFontOfSize:14.0f];
	[containerView addSubview:label];
	
	return containerView;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	
}

- (void)cancelButtonAction
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didSelectPhotos
{
	if (_ptAppDelegate.albumDataController.isEditable == NO) {
		[self showDontEditingAlertView];
		return;
	}
	
	if (self.tableView.indexPathsForSelectedRows.count == 0) {
		return;
	}
	
	NSString *title = NSLocalizedString(@"Combine these albums", @"PTCombineViewController");
	NSString *message = NSLocalizedString(@"Arrange these album order.\n\n\n\n\n\n\n\n\n\n\n", @"PTCombineViewController");
	NSString *cancel = NSLocalizedString(@"Cancel", @"PTCombineViewController");
	NSString *combine = NSLocalizedString(@"Combine", @"PTCombineViewController");
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
													message:message
												   delegate:self
										  cancelButtonTitle:cancel
										  otherButtonTitles:combine, nil];
	UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(15.0f, 80.0f, 255.0f, 180.0f) style:UITableViewStylePlain];
	tableView.tag = 999;
	
	NSMutableArray *tmpIndexPaths = [[NSMutableArray alloc] initWithArray:self.tableView.indexPathsForSelectedRows];
	[tmpIndexPaths sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
		NSIndexPath *indexPath1 = (NSIndexPath *)obj1;
		NSIndexPath *indexPath2 = (NSIndexPath *)obj2;
		if (indexPath1.row < indexPath2.row) {
			return NSOrderedAscending;
		}
		else if (indexPath1.row > indexPath2.row) {
			return NSOrderedDescending;
		}
		else {
			return NSOrderedSame;
		}
	}];
	NSMutableArray *selectedAlbumDatas = [[NSMutableArray alloc] init];
	for (NSIndexPath *tmpIndexPath in tmpIndexPaths) {
		PAAlbumData *albumData = [_albumDatas objectAtIndex:tmpIndexPath.row];
		[selectedAlbumDatas addObject:albumData];
	}
	
	_combineAlbumViewController = [[PTCombineAlbumViewController alloc] init];
	_combineAlbumViewController.selectedAlbumDatas = selectedAlbumDatas;
	_combineAlbumViewController.tableView.autoresizingMask = UIViewAutoresizingNone;
	_combineAlbumViewController.tableView.frame = CGRectMake(15.0f, 78.0f, 255.0f, 190.0f);
	
	[alert addSubview:_combineAlbumViewController.tableView];
	
	[alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{	
	if (buttonIndex == 1) {
		//Done
		if (_ptAppDelegate.albumDataController.isEditable == NO) {
			[self showDontEditingAlertView];
			return;
		}
		
		[_myDelegate combineAlbums:_combineAlbumViewController.selectedAlbumDatas];
		
		[self dismissViewControllerAnimated:YES completion:nil];
	}
	
	_combineAlbumViewController = nil;
}

- (UIImage *)createThumbnail:(UIImage *)image
{
	CGFloat imageWidth = image.size.width;
	CGFloat imageHeight = image.size.height;
	
	CGRect cropRect;
	
	if (imageWidth >= imageHeight * 4.0f / 3.0f) {
		cropRect.size.width = imageHeight * 4.0f / 3.0f;
		cropRect.size.height = imageHeight;
		cropRect.origin.x = imageWidth / 2.0f - cropRect.size.width / 2.0f;
		cropRect.origin.y = 0.0f;
	}
	else {
		cropRect.size.width = imageWidth;
		cropRect.size.height = imageWidth * 3.0f / 4.0f;
		cropRect.origin.x = 0.0f;
		cropRect.origin.y = imageHeight / 2.0f - cropRect.size.height / 2.0f;
	}
	
	CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage, cropRect);
	UIImage *thumbnailImage = [UIImage imageWithCGImage:imageRef];
	CGImageRelease(imageRef);
	
	return thumbnailImage;
}

- (void)reloadData
{
	dispatch_async(dispatch_get_main_queue(), ^{
		[self.tableView reloadData];
		if (_combineAlbumViewController != nil) {
			[_combineAlbumViewController.tableView reloadData];
		}
	});
}

- (void)showDontEditingAlertView
{
	NSString *title = NSLocalizedString(@"This Function is not enabled while loading.", @"PTTimelineViewController");
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

@end
