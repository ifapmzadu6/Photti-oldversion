//
//  PTDivideViewController.m
//  PhotoTimeline
//
//  Created by Karijuku Keisuke on 2013/05/22.
//  Copyright (c) 2013年 Keisuke Karijuku. All rights reserved.
//

#import "PTDivideViewController.h"

@interface PTDivideViewController ()
{
	PTAppDelegate *_ptAppDelegate;
		
	NSMutableArray *_selectedIndexPaths;
	
	NSString *_dividedAlbumTitle;
		
	NSUInteger _numberInSection;
}

@end

@implementation PTDivideViewController

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
	// Do any additional setup after loading the view.
	
	self.wantsFullScreenLayout = YES;
	
	_ptAppDelegate = (PTAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	//ナビゲーションタイトル
	NSString *title = NSLocalizedString(@"Divide this album", @"PTDivideViewController");
	[self.navigationItem setTitle:title];
	
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
		
	_selectedIndexPaths = [NSMutableArray array];
	
	_numberInSection = _albumData.photoDatas.count;
	
	[self initHeaderView];
	[self initFooterView];
}

- (void)initHeaderView
{
	PAAlbumData *tmpAlbumData = [[PAAlbumData alloc] init];
	tmpAlbumData.photoDatas = [_albumData.photoDatas mutableCopy];
	for (NSIndexPath *indexPath in _selectedIndexPaths) {
		PAPhotoData *photoData = [_albumData.photoDatas objectAtIndex:indexPath.row];
		[tmpAlbumData.photoDatas removeObject:photoData];
	}
	tmpAlbumData.title = _albumData.title;
	tmpAlbumData.thumbnailAssetURL = _albumData.thumbnailAssetURL;
	[tmpAlbumData checkAlbumData];
	
	if (tmpAlbumData.photoDatas.count > 0) {
		PAPhotoData *thumnbanilPhotoData = [tmpAlbumData.photoDatas objectAtIndex:tmpAlbumData.thumbnailIndex];
		_headerViewImage.image = [thumnbanilPhotoData thumbnail];
	}
	else {
		_headerViewImage.image = [UIImage imageNamed:@"Picture_mini.png"];
	}
	
	if (tmpAlbumData.title != nil) {
		_headerViewTitle.textColor = [UIColor colorWithRed:0.204f green:0.212f blue:0.239f alpha:1.0f];
	}
	else {
		_headerViewTitle.textColor = [UIColor colorWithRed:0.204f green:0.212f blue:0.239f alpha:0.55f];
	}
	_headerViewTitle.text = tmpAlbumData.displayTitleString;
	
	_headerViewDate.text = tmpAlbumData.displayDateString;
	
	_headerViewPhotos.text = tmpAlbumData.displayCountString;
}

- (void)initFooterView
{
	PAAlbumData *tmpAlbumData = [[PAAlbumData alloc] init];
	for (NSIndexPath *indexPath in _selectedIndexPaths) {
		PAPhotoData *photoData = [_albumData.photoDatas objectAtIndex:indexPath.row];
		[tmpAlbumData.photoDatas addObject:photoData];
	}
	tmpAlbumData.title = _dividedAlbumTitle;
	tmpAlbumData.thumbnailAssetURL = _albumData.thumbnailAssetURL;
	[tmpAlbumData checkAlbumData];
	
	if (tmpAlbumData.photoDatas.count > 0) {
		PAPhotoData *thumnbanilPhotoData = [tmpAlbumData.photoDatas objectAtIndex:tmpAlbumData.thumbnailIndex];
		_footerViewImage.image = [thumnbanilPhotoData thumbnail];
	}
	else {
		_footerViewImage.image = [UIImage imageNamed:@"Picture_mini.png"];
	}
	
	if (tmpAlbumData.title != nil) {
		_footerViewTitle.textColor = [UIColor colorWithRed:0.204f green:0.212f blue:0.239f alpha:1.0f];
	}
	else {
		_footerViewTitle.textColor = [UIColor colorWithRed:0.204f green:0.212f blue:0.239f alpha:0.55f];
	}
	_footerViewTitle.text = tmpAlbumData.displayTitleString;
	UITapGestureRecognizer *tapGusture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAlbumTitle:)];
	[_footerViewTitle setGestureRecognizers:@[tapGusture]];
	_footerViewTitle.userInteractionEnabled = YES;
	
	_footerViewDate.text = tmpAlbumData.displayDateString;
	
	_footerViewPhotos.text = tmpAlbumData.displayCountString;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
	return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return _numberInSection;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
	
	PAPhotoData *photoData = [_albumData.photoDatas objectAtIndex:indexPath.row];
	
	UIImageView *imageView = (UIImageView *)[cell viewWithTag:1];
	UIImageView *checkmark = (UIImageView *)[cell viewWithTag:2];
	UILabel *videoLabel = (UILabel *)[cell viewWithTag:3];
	
	CGImageRef imageRef = photoData.asset.thumbnail;
	if (imageRef == nil) {
		imageView.image = nil;
	}
	else {
		imageView.image = [UIImage imageWithCGImage:imageRef];
	}
	
	if (photoData.isVideo == YES) {
		NSNumber *duration = [photoData.asset valueForProperty:ALAssetPropertyDuration];
		NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:duration.floatValue];
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		if (duration.floatValue > 60.0f * 60.0f) {
			[dateFormatter setDateFormat:@"H:mm:ss "];
		}
		else {
			[dateFormatter setDateFormat:@"m:ss "];
		}
		videoLabel.text = [dateFormatter stringFromDate:date];
		
		videoLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"71-videolabel.png"]];
		
		videoLabel.hidden = NO;
	}
	else {
		videoLabel.hidden = YES;
	}
	
	if ([_selectedIndexPaths containsObject:indexPath]) {
		checkmark.hidden = NO;
		
		imageView.alpha = 0.5f;
	}
	else {
		checkmark.hidden = YES;
		
		imageView.alpha = 1.0f;
	}
	
	return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	[_collectionView deselectItemAtIndexPath:indexPath animated:NO];
	
	PAPhotoData *photoData = [_albumData.photoDatas objectAtIndex:indexPath.row];
	if (photoData.asset.thumbnail == nil) {
		return;
	}
	
	if ([_selectedIndexPaths containsObject:indexPath]) {
		[_selectedIndexPaths removeObject:indexPath];
	}
	else {
		[_selectedIndexPaths addObject:indexPath];
	}
	
	[_collectionView reloadItemsAtIndexPaths:@[indexPath]];
	
	[self initHeaderView];
	[self initFooterView];
}

- (void)cancelButtonAction
{
	[self dismissViewControllerAnimated:YES completion:nil];	
}

- (void)didSelectPhotos
{
	if (_selectedIndexPaths.count > 0 && _selectedIndexPaths.count != _albumData.photoDatas.count) {
		PAAlbumData *tmpAlbumData = [[PAAlbumData alloc] init];
		for (NSIndexPath *indexPath in _selectedIndexPaths) {
			PAPhotoData *photoData = [_albumData.photoDatas objectAtIndex:indexPath.row];
			[tmpAlbumData.photoDatas addObject:photoData];
		}
		tmpAlbumData.title = _dividedAlbumTitle;
		tmpAlbumData.thumbnailAssetURL = _albumData.thumbnailAssetURL;
		[tmpAlbumData sortPhotoDataByDate];
		[tmpAlbumData checkAlbumData];
		
		[_selectedIndexPaths sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
			NSIndexPath *indexPath1 = (NSIndexPath *)obj1;
			NSIndexPath *indexPath2 = (NSIndexPath *)obj2;
			return [indexPath2 compare:indexPath1];
		}];
		
		for (NSIndexPath *indexPath in _selectedIndexPaths) {
			[_albumData.photoDatas removeObjectAtIndex:indexPath.row];
		}
		[_albumData checkAlbumData];
		
		[_myDelegate divideAlbum:tmpAlbumData];
	}
	
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)tapAlbumTitle:(id)sender
{	
	[self showAlbumTitleAlertView];
}

- (void)showAlbumTitleAlertView
{
	NSString *title= NSLocalizedString(@"Album Title", @"PTDivideViewController");
	NSString *message= NSLocalizedString(@"Enter a title for this album.", @"PTDivideViewController");
	NSString *cancel= NSLocalizedString(@"Cancel", @"PTDivideViewController");
	NSString *done= NSLocalizedString(@"Done", @"PTDivideViewController");
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
													message:message
												   delegate:self
										  cancelButtonTitle:cancel
										  otherButtonTitles:done, nil];
	alert.alertViewStyle = UIAlertViewStylePlainTextInput;
	
	UITextField* textField = [alert textFieldAtIndex:0];
	textField.text = _dividedAlbumTitle;
	textField.returnKeyType = UIReturnKeyDone;
	textField.delegate = self;
	
	[alert show];	
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 1) {
		//Doneボタンが押されたとき
		UITextField* textField = [alertView textFieldAtIndex:0];
		
		_dividedAlbumTitle = textField.text;
		
		[self initFooterView];
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)alertTextField
{
	UIAlertView *alertView = (UIAlertView *)[alertTextField superview];
	
	[self alertView:alertView clickedButtonAtIndex:1];
	[alertView dismissWithClickedButtonIndex:1 animated:YES];
	
	return YES;
}

- (void)reloadData
{
	dispatch_async(dispatch_get_main_queue(), ^{
		[_selectedIndexPaths removeAllObjects];
		
		[self.collectionView reloadData];
		
		_numberInSection = _albumData.photoDatas.count;
		
		[self.collectionView reloadData];
		
		[self initFooterView];
		[self initHeaderView];
	});
}

@end





@implementation PTDivideViewHeaderView

- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGRect shadow2 = CGRectMake(CGRectGetMinX(rect), CGRectGetMaxY(rect) - 4.0f, CGRectGetMaxX(rect), 4.0f);
	CGFloat components3[] = {
        0.0f, 0.0f, 0.0f, 0.5f,
		0.0f, 0.0f, 0.0f, 0.0f
    };
	CGFloat locations3[] = { 0.0f, 1.0f };
	size_t count3 = sizeof(components3)/ (sizeof(CGFloat)* 4);
	CGContextFillVarticalGradientRect(context, shadow2, components3, locations3, count3);
		
	CGRect backGroundRect = CGRectMake(0.0f, 0.0f, 320.0f, 75.0f);
//	CGFloat components1[] = {
//		0.75f, 0.75f, 0.75f, 1.0f,
//        0.95f, 0.95f, 0.95f, 1.0f     // R, G, B, Alpha
//    };
//	CGFloat locations1[] = { 0.0f, 1.0f };
//	size_t count1 = sizeof(components1)/ (sizeof(CGFloat)* 4);
//	CGContextFillVarticalGradientRect(context, backGroundRect, components1, locations1, count1);
	
	CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
	CGContextFillRect(context, backGroundRect);
}

@end

@implementation PTDivideViewFooterView

- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGRect shadow2 = CGRectMake(CGRectGetMinX(rect), 0.0f, CGRectGetMaxX(rect), 4.0f);
	CGFloat components3[] = {
        0.0f, 0.0f, 0.0f, 0.0f,
		0.0f, 0.0f, 0.0f, 0.5f
    };
	CGFloat locations3[] = { 0.0f, 1.0f };
	size_t count3 = sizeof(components3)/ (sizeof(CGFloat)* 4);
	CGContextFillVarticalGradientRect(context, shadow2, components3, locations3, count3);
	
	CGRect backGroundRect = CGRectMake(0.0f, 4.0f, 320.0f, 75.0f);
	CGContextSetRGBFillColor(context, 57.0f/255.0f, 147.0f/255.0f, 211.0f/255.0f, 0.25f);
	CGContextFillRect(context, backGroundRect);
	
//	CGFloat components2[] = {
//        1.0f, 1.0f, 1.0f, 0.5f,
//		1.0f, 1.0f, 1.0f, 0.0f
//    };
//	CGFloat locations2[] = { 0.0f, 1.0f };
//	size_t count2 = sizeof(components2)/ (sizeof(CGFloat)* 4);
//	CGContextFillVarticalGradientRect(context, backGroundRect, components2, locations2, count2);
}
@end