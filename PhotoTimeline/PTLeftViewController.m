//
//  PTLeftViewController.m
//  PhotoTimeline
//
//  Created by Karijuku Keisuke on 2013/04/03.
//  Copyright (c) 2013年 Keisuke Karijuku. All rights reserved.
//

#import "PTLeftViewController.h"

enum SECTION {
	TIMELINE = 1,
	CAMERAROLL = 0
	};

@interface PTLeftViewController ()
{	
	NSInteger _numberOfRowsInTimelineSection;
	
	NSInteger _numberOfRowsInCameraRollSection;
	
	BOOL _isTimelineClosed;
	
	BOOL _isCamerarollClosed;
}

@end

@implementation PTLeftViewController

@synthesize viewController = _viewController;


- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[self.navigationController.navigationBar setTintColor:[UIColor colorWithWhite:0.9f alpha:1.0f]];
	
	UIButton *customView = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 36.0f, 36.0f)];
	[customView setImage:[UIImage imageNamed:@"19-gear.png"] forState:UIControlStateNormal];
	[customView setImage:[UIImage imageNamed:@"19-gear_touched.png"] forState:UIControlStateHighlighted];
	customView.showsTouchWhenHighlighted = YES;
	customView.exclusiveTouch = YES;
	[customView addTarget:self action:@selector(openSettingsView) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem* buttonItem = [[UIBarButtonItem alloc] initWithCustomView:customView];
	self.navigationItem.leftBarButtonItem = buttonItem;
	
	UIView *statusbarView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 20.0f)];
	statusbarView.backgroundColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
	[self.navigationController.view addSubview:statusbarView];
	
	[self.navigationItem setTitle:@"Photti       "];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)openSettingsView
{
	[_viewController centerPanelShowSettings];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSInteger number = 0;
	
	if (section == CAMERAROLL) {
		number = _numberOfRowsInCameraRollSection;
	}
	else if (section == TIMELINE) {
		if (_isTimelineClosed) {
			number = 0;
		}
		else if (_numberOfRowsInTimelineSection > 0) {
			number = _numberOfRowsInTimelineSection;
		}
		else {
			number = 1;
		}
	}
	
    return number;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
	
	UIImageView *imageView = (UIImageView *)[cell viewWithTag:1];
	UILabel *titleLabel = (UILabel *)[cell viewWithTag:2];
	UILabel *photosLabel = (UILabel *)[cell viewWithTag:3];
	UILabel *dateLabel = (UILabel *)[cell viewWithTag:4];
	
	if (indexPath.section == CAMERAROLL) {
		if (indexPath.row == 0) {
			if (_ptAppDelegate.albumDataController.allPhoto.photoDatas.count > 0) {
				PAPhotoData *photoData = [_ptAppDelegate.albumDataController.allPhoto.photoDatas objectAtIndex:0];
				
				imageView.image = [UIImage imageWithCGImage:photoData.asset.aspectRatioThumbnail];
			}
			
			NSString *title = NSLocalizedString(@"All Photos", @"PTLeftViewController");
			titleLabel.text = title;
			titleLabel.textColor = [UIColor colorWithRed:0.204f green:0.212f blue:0.239f alpha:1.0f];
			photosLabel.text = [NSString stringWithFormat:@"(%d)", _ptAppDelegate.albumDataController.allPhoto.photoDatas.count];
			dateLabel.text = _ptAppDelegate.albumDataController.allPhoto.displayDateString;
		}
//		else if (indexPath.row == 1) {
//			PAPhotoData *photoData = [_ptAppDelegate.albumDataController.noDatePhotoDatas objectAtIndex:0];
//			
//			cell.textLabel.text = @"Undated Photos";
//
//			cell.imageView.image = photoData.thumbnail;
//		}
	}
	else if (indexPath.section == TIMELINE) {
		if (indexPath.row == _numberOfRowsInTimelineSection) {
			NSString *title = NSLocalizedString(@"Open Timeline", @"PTLeftViewController");
			titleLabel.text = title;
			titleLabel.textColor = [UIColor colorWithRed:0.204f green:0.212f blue:0.239f alpha:1.0f];
			
			photosLabel.text = nil;
			dateLabel.text = nil;
			
			imageView.image = [UIImage imageNamed:@"214-open.png"];
		}
		else {
			PAAlbumData *albumData = [_ptAppDelegate.albumDataController.albumDatas objectAtIndex:indexPath.row];
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
		}
	}
	
	CGSize titleLabelSize = [titleLabel.text sizeWithFont:titleLabel.font constrainedToSize:CGSizeMake(152.0f, 21.0f) lineBreakMode:NSLineBreakByTruncatingTail];
	titleLabel.frame = CGRectMake(titleLabel.frame.origin.x, titleLabel.frame.origin.y, titleLabelSize.width, titleLabel.frame.size.height);
	CGFloat photoLabelX = titleLabel.frame.origin.x + titleLabel.frame.size.width + 3.0f;
	CGFloat photoLabelWidth = 262.0f - photoLabelX;
	photosLabel.frame = CGRectMake(photoLabelX, photosLabel.frame.origin.y, photoLabelWidth, photosLabel.frame.size.height);
	
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == CAMERAROLL) {
		if (indexPath.row == 0) {
			[_viewController centerPanelShowAllPhotos];
		}
	}
	else if (indexPath.section == TIMELINE) {
		[_viewController centerPanelShowAlbumWithIndex:indexPath.row];
	}
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	PTSectionHeader *containerView = [[PTSectionHeader alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 24.0f)];
	containerView.alpha = 0.85f;
	
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 0.0f, 300.0f, 24.0f)];
	label.backgroundColor = [UIColor clearColor];
	if (section == CAMERAROLL) {
		NSString *title = NSLocalizedString(@"Camera Roll", @"PTLeftViewController");
		label.text = title;
	}
	else if (section == TIMELINE) {
		NSString *timeline = NSLocalizedString(@"Timeline", @"PTLeftViewController");
		label.text = timeline;
	}
	else {
		label.text = nil;
	}
	label.textColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.8f];
	label.font = [UIFont boldSystemFontOfSize:14.0f];
	[containerView addSubview:label];
	
	return containerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 24.0f;
}

- (void)reloadData
{
	_numberOfRowsInTimelineSection = _ptAppDelegate.albumDataController.albumDatas.count;
	
	_numberOfRowsInCameraRollSection = 1;

	dispatch_async(dispatch_get_main_queue(), ^{
		[_tableView reloadData];
	});
}

@end



@implementation PTSectionHeader

- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
	CGContextFillRect(context, rect);
	
	CGContextSetLineWidth(context, 1.0f);
	CGContextSetRGBStrokeColor(context, 0.6f, 0.6f, 0.6f, 1.0f);
	CGPoint lines0[] =
	{
		CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect)),
		CGPointMake(CGRectGetMaxX(rect), CGRectGetMinY(rect))
	};
	CGContextAddLines(context, lines0, 2);
	CGContextStrokePath(context);
	CGPoint lines1[] =
	{
		CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect)),
		CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect))
	};
	CGContextAddLines(context, lines1, 2);
	CGContextStrokePath(context);
}

@end
