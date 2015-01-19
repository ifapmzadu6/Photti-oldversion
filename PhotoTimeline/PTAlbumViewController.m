
//  PTAlbumViewController.m
//  PhotoTimeline
//
//  Created by Karijuku Keisuke on 2013/04/03.
//  Copyright (c) 2013年 Keisuke Karijuku. All rights reserved.
//

#import "PTAppDelegate.h"

#import "PTNavigationController.h"

#import "PTAlbumViewController.h"

#import "PhotoViewController.h"
#import "PTGPSMapViewController.h"


@interface PTAlbumViewController ()
{
	PTAppDelegate *_appDelegate;
	
	BOOL _isDividedAlbum;
	NSMutableArray *_dividedAlbum;
	
	NSString *_actionSheetMode;
	
//	NSString *_editingMode;
	
	EditingModeType _editingModeType;
	
	NSMutableArray *_selectedCellIndexPaths;
	
	NSMutableArray *_tmpPhotoData;
	
	UIDocumentInteractionController *docController;
	
	PTImageView *_headerImageView;
	
	UIView *_headerBackView;
	
	BOOL _saveAlbumToCameraroll;
	BOOL _saveAlbumAllPhotos;
	
	BOOL _isAddNewOne;
	
	BOOL _isDividedAllPhoto;
	NSMutableArray *_dividedAllPhoto;
	
	BOOL _isDisableReloadData;
	
	PTDivideViewController *_divideViewController;
	PTCombineViewController *_combineViewController;
	
	PTNavigationController *_navigationController;
}

@end

@implementation PTAlbumViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	
	_appDelegate = (PTAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	_navigationController = (PTNavigationController *)self.navigationController;
	
	if (_isAllPhotos) {
		_headerViewAddButton.enabled = NO;
		_headerViewSortButton.enabled = NO;
		_headerViewSaveAlbumButton.enabled = NO;
		_headerViewRemoveButton.enabled = NO;
	}
	
	[_headerViewAddButton setImage:[UIImage imageNamed:@"05-plus_touched.png"] forState:UIControlStateHighlighted];
	_headerViewAddButton.exclusiveTouch = YES;
	[_headerViewSortButton setImage:[UIImage imageNamed:@"03-arrows_touched.png"] forState:UIControlStateHighlighted];
	_headerViewSortButton.exclusiveTouch = YES;
	[_headerViewSaveAlbumButton setImage:[UIImage imageNamed:@"86-camera_touched.png"] forState:UIControlStateHighlighted];
	_headerViewSaveAlbumButton.exclusiveTouch = YES;
	[_headerViewShareButton setImage:[UIImage imageNamed:@"213-etcaction_touched.png"] forState:UIControlStateHighlighted];
	_headerViewShareButton.exclusiveTouch = YES;
	[_headerViewRemoveButton setImage:[UIImage imageNamed:@"218-trash2_touched.png"] forState:UIControlStateHighlighted];
	_headerViewRemoveButton.exclusiveTouch = YES;
	
	//ジェスチャーの追加（左スワイプで戻る）
	if (_isAllPhotos == NO) {
		UISwipeGestureRecognizer* swipeRightGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRightGesture:)];
		swipeRightGesture.direction = UISwipeGestureRecognizerDirectionRight;
		[self.view addGestureRecognizer:swipeRightGesture];
	}
	
	_selectedCellIndexPaths = [[NSMutableArray alloc] init];
	
	if (_isAllPhotos == YES) {
		_albumData = _allPhoto;
	}
	
	if (_albumData.showDateInAlbumView == PTShowDateInAlbumViewAuto) {
		if (_albumData.dateString != nil && [_albumData.dateString isEqualToString:_albumData.endDateString] == NO) {
			_isDividedAlbum = YES;
		}
		else {
			_isDividedAlbum = NO;
		}
	}
	else if (_albumData.showDateInAlbumView == PTShowDateInAlbumViewYes) {
		_isDividedAlbum = YES;
	}
	else {
		_isDividedAlbum = NO;
	}
	
	if (_isDividedAlbum == YES) {
		_dividedAlbum = [_albumData dividePhotosInAlbumByDate];
	}
	
	[_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderViewDate"];
	
	[self initNavigationBar];
	
	//サムネイルを先読みしてアニメーションをなめらかに
	CGImageRef imageRef;
	for (int i = 9; i <= 32; i++) {
		if (i < _albumData.photoDatas.count) {
			PAPhotoData *photoData = [_albumData.photoDatas objectAtIndex:i];
			imageRef = photoData.asset.thumbnail;
		}
		else {
			imageRef = NULL;
			break;
		}
	}
}

- (void)initNavigationBar
{
	[self.navigationItem setTitle:_albumData.displayTitleString];
	
	UIButton *customView = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 36.0f, 36.0f)];
	if (_isAllPhotos) {
		[customView setImage:[UIImage imageNamed:@"259-list.png"] forState:UIControlStateNormal];
		[customView setImage:[UIImage imageNamed:@"259-list_touched.png"] forState:UIControlStateHighlighted];
		customView.showsTouchWhenHighlighted = YES;
		[customView addTarget:self action:@selector(toggleLeftPanel) forControlEvents:UIControlEventTouchUpInside];
	}
	else {
		[customView setImage:[UIImage imageNamed:@"09-arrow-west.png"] forState:UIControlStateNormal];
		[customView setImage:[UIImage imageNamed:@"09-arrow-west_touched.png"] forState:UIControlStateHighlighted];
		[customView addTarget:self action:@selector(backBarUIButton) forControlEvents:UIControlEventTouchUpInside];
	}
	customView.showsTouchWhenHighlighted = YES;
	customView.exclusiveTouch = YES;
	UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:customView];
	self.navigationItem.leftBarButtonItem = buttonItem;
	
	UIButton *customView1 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 36.0f, 36.0f)];
	[customView1 setImage:[UIImage imageNamed:@"211-action.png"] forState:UIControlStateNormal];
	[customView1 setImage:[UIImage imageNamed:@"211-action_touched.png"] forState:UIControlStateHighlighted];
	customView1.showsTouchWhenHighlighted = YES;
	customView1.exclusiveTouch = YES;
	[customView1 addTarget:self action:@selector(settingBarUIButton) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *buttonItem1 = [[UIBarButtonItem alloc] initWithCustomView:customView1];
	self.navigationItem.rightBarButtonItem = buttonItem1;
	
	if (_isAllPhotos) {
		self.navigationItem.rightBarButtonItem.enabled = NO;
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self.navigationController.navigationBar setTranslucent:NO];
	
	[self.navigationController setToolbarHidden:YES animated:YES];
	
	_combineViewController = nil;
	_divideViewController = nil;
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
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


#pragma mark CollectionView

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
	NSInteger section = 0;
	
	if (_isAddNewOne == NO) {
		if (_isEditing && (_editingModeType == EditingModeTypeSort)) {
			section = 1;
		}
		else {
			if (_isDividedAlbum == YES) {
				section = _dividedAlbum.count;
			}
			else {
				section = 1;
			}
		}
	}
	else {
		if (_isDividedAllPhoto == YES) {
			section = _dividedAllPhoto.count;
		}
		else {
			section = 1;
		}
	}
	
	return section;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	NSInteger row = 0;
	
	if (_isAddNewOne == NO) {
		if (_isEditing && (_editingModeType == EditingModeTypeSort)) {
			row = _tmpPhotoData.count;
		}
		else {
			if (_isDividedAlbum == NO) {
				row = _albumData.photoDatas.count;
			}
			else {
				NSMutableArray *photoDatas = [_dividedAlbum objectAtIndex:section];
				row = photoDatas.count;
			}
		}
	}
	else {
		if (_isDividedAllPhoto == NO) {
			row = _allPhoto.photoDatas.count;
		}
		else {
			NSMutableArray *photoDatas = [_dividedAllPhoto objectAtIndex:section];
			row = photoDatas.count;
		}
	}
	
	return row;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
	
	UIImageView *imageView = (UIImageView *)[cell viewWithTag:1];
	UIImageView *checkMark = (UIImageView *)[cell viewWithTag:2];
	UIActivityIndicatorView *activityIndicatorView = (UIActivityIndicatorView *)[cell viewWithTag:3];
	UILabel *videoLabel = (UILabel *)[cell viewWithTag:4];
	
	PAPhotoData *photoData;
	if (_isEditing && (_editingModeType == EditingModeTypeAddNewOne)) {
		if (_isDividedAllPhoto == NO) {
			photoData = [_allPhoto.photoDatas objectAtIndex:indexPath.row];
		}
		else {
			NSMutableArray *photoDatas = [_dividedAllPhoto objectAtIndex:indexPath.section];
			photoData = [photoDatas objectAtIndex:indexPath.row];
		}
	}
	else if (_isEditing && (_editingModeType == EditingModeTypeSort)) {
		photoData = [_tmpPhotoData objectAtIndex:indexPath.row];
	}
	else {
		if (_isDividedAlbum == NO) {
			photoData = [_albumData.photoDatas objectAtIndex:indexPath.row];
		}
		else {
			NSMutableArray *photoDatas = [_dividedAlbum objectAtIndex:indexPath.section];
			photoData = [photoDatas objectAtIndex:indexPath.row];
		}
	}
	
	if (photoData.asset == nil) {
		if (activityIndicatorView.isAnimating == NO) {
			[activityIndicatorView startAnimating];
		}
		if ([cell.backgroundColor isEqual:[UIColor colorWithWhite:0.9f alpha:1.0f]] == NO) {
			cell.backgroundColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
		}
		
		if (videoLabel.hidden == NO) {
			videoLabel.hidden = YES;
		}
	}
	else {
		if (activityIndicatorView.isAnimating == YES) {
			[activityIndicatorView stopAnimating];
		}
		if ([cell.backgroundColor isEqual:[UIColor whiteColor]] == NO) {
			cell.backgroundColor = [UIColor whiteColor];
		}
		
		imageView.image = [photoData thumbnail];
		
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
			if (videoLabel.hidden == NO) {
				videoLabel.hidden = YES;
			}
		}
		
		if (imageView.alpha != 1.0f) {
			imageView.alpha = 1.0f;
			checkMark.hidden = YES;
		}
		if (_isEditing) {
			if (_editingModeType == EditingModeTypeRemove) {
				checkMark.image = [UIImage imageNamed:@"checkmark.png"];
			}
			else {
				checkMark.image = [UIImage imageNamed:@"checkmark_green.png"];
			}
			
			if (_isAddNewOne) {
				if ([_albumData.photoDatas containsObject:photoData]) {
					cell.backgroundColor = [UIColor blackColor];
					imageView.alpha = 0.5f;
					checkMark.hidden = NO;
				}
			}
			if ([_selectedCellIndexPaths containsObject:indexPath]) {
				cell.backgroundColor = [UIColor whiteColor];
				imageView.alpha = 0.5f;
				checkMark.hidden = NO;
			}
		}
	}
	
	return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	[_collectionView deselectItemAtIndexPath:indexPath animated:NO];
	
	PAPhotoData *photoData;
	if (_isAddNewOne == YES) {
		if (_isDividedAllPhoto == NO) {
			photoData = [_allPhoto.photoDatas objectAtIndex:indexPath.row];
		}
		else {
			NSMutableArray *photoDatas = [_dividedAllPhoto objectAtIndex:indexPath.section];
			photoData = [photoDatas objectAtIndex:indexPath.row];
		}
	}
	else {
		if (_isDividedAlbum == NO) {
			photoData = [_albumData.photoDatas objectAtIndex:indexPath.row];
		}
		else {
			NSMutableArray *photoDatas = [_dividedAlbum objectAtIndex:indexPath.section];
			photoData = [photoDatas objectAtIndex:indexPath.row];
		}
	}
	
	if (photoData.asset == nil) {
		return;
	}
	else {
		if (photoData.asset.thumbnail == nil) {
			return;
		}
	}
	
	if (_isEditing) {
		if (_editingModeType == EditingModeTypeTwitter) {
			if (photoData.isVideo == YES) {
				[self showVideoCannotBeShareAlertViewMode:EditingModeTypeTwitter];
				
				return;
			}
			
			SLComposeViewController *twitterPostVC = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
			MBProgressHUD *progressHUD = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
			progressHUD.labelText = NSLocalizedString(@"Loading...", @"PTAlbumViewController");
			dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
				UIImage *image = [self loadImageAtIndexPath:indexPath];
				[twitterPostVC addImage:image];
				dispatch_async(dispatch_get_main_queue(), ^{
					[MBProgressHUD hideHUDForView:self.view.window animated:YES];
					
					[self cancelButtonAction];
					[self presentViewController:twitterPostVC animated:YES completion:nil];
				});
			});
		}
		else if (_editingModeType == EditingModeTypeLine) {
			if (photoData.isVideo == YES) {
				[self showVideoCannotBeShareAlertViewMode:EditingModeTypeLine];
				
				return;
			}
			
			MBProgressHUD *progressHUD = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
			progressHUD.labelText = NSLocalizedString(@"Loading...", @"PTAlbumViewController");
			dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
				UIImage *image = [self loadImageAtIndexPath:indexPath];
				NSData *data = UIImageJPEGRepresentation(image, 0.8);
				dispatch_async(dispatch_get_main_queue(), ^{
					[MBProgressHUD hideHUDForView:self.view.window animated:YES];
					
					[self cancelButtonAction];
					
					UIPasteboard *pasteboard = [UIPasteboard pasteboardWithName:@"jp.naver.linecamera.pasteboard" create:YES];
					[pasteboard setData:data forPasteboardType:@"public.jpeg"];
					[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"line://msg/image/%@", pasteboard.name]]];
				});
			});
		}
		else if (_editingModeType == EditingModeTypeOpenIn) {
			MBProgressHUD *progressHUD = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
			progressHUD.labelText = NSLocalizedString(@"Loading...", @"PTAlbumViewController");
			if (photoData.isVideo == NO) {
				dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
					UIImage *image = [photoData fullResolutionImage];
					NSData *data = UIImageJPEGRepresentation(image, 1.0f);
					
					NSString* a_doc_tmp = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp/image.jpg"];
					BOOL isSuccess = [data writeToFile:a_doc_tmp atomically:YES];
					if (!isSuccess) {
						NSLog(@"not create data!");
					}
					
					NSURL *url = [NSURL fileURLWithPath:a_doc_tmp];
					docController = [UIDocumentInteractionController interactionControllerWithURL:url];
					dispatch_async(dispatch_get_main_queue(), ^{
						[MBProgressHUD hideHUDForView:self.view.window animated:YES];
						
						[self cancelButtonAction];
						BOOL isValid = [docController presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];
						if (!isValid) {
							NSLog(@"ファイル形式に対応するアプリがありません。");
						}
					});
				});
			}
			else {
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
					docController = [UIDocumentInteractionController interactionControllerWithURL:url];
					
					dispatch_async(dispatch_get_main_queue(), ^{
						[MBProgressHUD hideHUDForView:self.view.window animated:YES];
						
						[self cancelButtonAction];
						BOOL isValid = [docController presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];
						if (!isValid) {
							NSLog(@"ファイル形式に対応するアプリがありません。");
						}
					});
				});
			}
		}
		else if ((_editingModeType == EditingModeTypeSaveAlbum) || (_editingModeType == EditingModeTypeEtcAction) || (_editingModeType == EditingModeTypeRemove)) {
			if (![_selectedCellIndexPaths containsObject:indexPath]) {
				[_selectedCellIndexPaths addObject:indexPath];
			}
			else {
				[_selectedCellIndexPaths removeObject:indexPath];
			}
			[_collectionView reloadItemsAtIndexPaths:@[indexPath]];
		}
		else if (_editingModeType == EditingModeTypeAddNewOne) {
			if ([_albumData.photoDatas containsObject:photoData]) {
				return;
			}
			
			if (![_selectedCellIndexPaths containsObject:indexPath]) {
				[_selectedCellIndexPaths addObject:indexPath];
			}
			else {
				[_selectedCellIndexPaths removeObject:indexPath];
			}
			[_collectionView reloadItemsAtIndexPaths:@[indexPath]];
		}
		else if ((_editingModeType == EditingModeTypeMail) || (_editingModeType == EditingModeTypeFacebook)) {
			if (photoData.isVideo == YES) {
				[self showVideoCannotBeShareAlertViewMode:_editingModeType];
				
				return;
			}
			if (![_selectedCellIndexPaths containsObject:indexPath]) {
				if (_selectedCellIndexPaths.count < 10) {
					[_selectedCellIndexPaths addObject:indexPath];
				}
			}
			else {
				[_selectedCellIndexPaths removeObject:indexPath];
			}
			[_collectionView reloadItemsAtIndexPaths:@[indexPath]];
			
			NSString *title = NSLocalizedString(@"Select photos (%d/10)", @"PTAlbumViewController");
			NSString *toolbarTitle = [NSString stringWithFormat:title, _selectedCellIndexPaths.count];
			_headerViewToolBarLabel.text = toolbarTitle;
		}
		else if (_editingModeType == EditingModeTypeThumbnail) {
			//サムネイルの更新とalbumdataの変更
			_albumData.thumbnailAssetURL = photoData.assetURL;
			_albumData.thumbnailIndex = [_albumData.photoDatas indexOfObject:photoData];
			
			[_albumData checkAlbumData];
						
			[_navigationController requestReloadData];
			
			[_appDelegate.albumDataController asyncSaveAlbumDataController];
			
			[self cancelButtonAction];			
		}
	}
	else {
		PAPhotoViewController *photoViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PAPhotoViewController"];
		
		photoViewController.albumData = _albumData;
		photoViewController.indexOfPhotoDatas = [_albumData.photoDatas indexOfObject:photoData];
		[self.navigationController pushViewController:photoViewController animated:YES];
	}
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
	UICollectionReusableView *reusableview = nil;
	
	if (kind == UICollectionElementKindSectionHeader) {
		if (indexPath.section == 0) {
			UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
			reusableview = headerView;
			
			PTImageView *imageView = (PTImageView *)[headerView viewWithTag:1];
			UILabel *titleLabel = (UILabel *)[headerView viewWithTag:2];
			UILabel *dateLabel = (UILabel *)[headerView viewWithTag:3];
			UILabel *photosLabel = (UILabel *)[headerView viewWithTag:4];
			UIView *imageMaskView = (UIView *)[headerView viewWithTag:5];
			
			UIView *backView = (UIView *)[headerView viewWithTag:10];
			
			if (_isEditing == NO) {
				_headerImageView = imageView;
				_headerBackView = backView;
				backView.hidden = NO;
				
				if (_albumData.title == nil) {
					titleLabel.text = NSLocalizedString(@"Tap here to enter title", @"PAAlbumViewController");
					titleLabel.adjustsFontSizeToFitWidth = YES;
				}
				else {
					titleLabel.text = _albumData.displayTitleString;
					titleLabel.adjustsFontSizeToFitWidth = NO;
				}
				
				if (_isAllPhotos == NO) {
					UITapGestureRecognizer *tapGusture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAlbumTitle:)];
					[titleLabel setGestureRecognizers:@[tapGusture]];
				}
				
				dateLabel.text = _albumData.displayDateString;
				
				photosLabel.text = _albumData.displayCountString;
				
				if (_albumData.photoDatas.count > 0 && _albumData.thumbnailIndex <= _albumData.photoDatas.count - 1) {
					PAPhotoData *photoData = [_albumData.photoDatas objectAtIndex:_albumData.thumbnailIndex];
					
					UIImage *image = [photoData aspectRatioThumbnail];
					if (image != nil) {
						[imageView loadImageFromAsset:photoData.asset thumbnail:image];
					}
					else {
						[imageView setImageNil];
					}
				}
				else {
					[imageView DisplayNoPhotos];
				}
				
				if (_isAllPhotos == NO && _albumData.photoDatas.count > 0) {
					UITapGestureRecognizer *tapGustureHeaderViewImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerViewImageAction:)];
					[imageMaskView setGestureRecognizers:@[tapGustureHeaderViewImage]];
				}
			}
			else {
				backView.hidden = YES;
			}
			
			if (_isDividedAlbum || _isDividedAllPhoto) {
				UIView *dividedDateLabelBackView = [reusableview viewWithTag:777];
				if (dividedDateLabelBackView == nil) {
					dividedDateLabelBackView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 284.0f, 320.0f, 27.0f)];
					dividedDateLabelBackView.tag = 777;
					dividedDateLabelBackView.backgroundColor = [UIColor whiteColor];
					[reusableview addSubview:dividedDateLabelBackView];
				}
				UILabel *photoDateLabel = (UILabel *)[dividedDateLabelBackView viewWithTag:111];
				if (photoDateLabel == nil) {
					photoDateLabel = [[UILabel alloc] init];
					photoDateLabel.font = [UIFont boldSystemFontOfSize:17.0f];
					photoDateLabel.textColor = [UIColor colorWithRed:0.204f green:0.212f blue:0.239f alpha:0.83f];
					photoDateLabel.tag = 111;
					[dividedDateLabelBackView addSubview:photoDateLabel];
				}
				
				NSMutableArray *photoDatas;
				if (_isDividedAllPhoto && (_editingModeType == EditingModeTypeAddNewOne) && _isEditing) {
					photoDatas = [_dividedAllPhoto objectAtIndex:0];
				}
				else {
					photoDatas = [_dividedAlbum objectAtIndex:0];
				}
				PAPhotoData *photoData = [photoDatas objectAtIndex:0];
				photoDateLabel.text = [photoData dateFullString];
				CGSize textSize = [photoDateLabel.text sizeWithFont:photoDateLabel.font];
				photoDateLabel.frame = CGRectMake(10.0f, 0.0f, textSize.width, 27.0f);
				
				UILabel *photoCountLabel = (UILabel *)[headerView viewWithTag:222];
				if (photoCountLabel == nil) {
					photoCountLabel = [[UILabel alloc] init];
					photoCountLabel.tag = 222;
					photoCountLabel.font = [UIFont boldSystemFontOfSize:15.0f];
					photoCountLabel.textColor = [UIColor colorWithRed:0.204f green:0.212f blue:0.239f alpha:0.666f];
					photoCountLabel.textAlignment = NSTextAlignmentRight;
					[dividedDateLabelBackView addSubview:photoCountLabel];
				}
				photoCountLabel.text = [PAAlbumData displayCountString:photoDatas];
				photoCountLabel.frame = CGRectMake(textSize.width + 10.0f, 0.0f, 320.0f - textSize.width - 20.0f, 27.0f);
			}
		}
		else {
			UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderViewDate" forIndexPath:indexPath];
			reusableview = headerView;
			
			UILabel *dateLabel = (UILabel *)[headerView viewWithTag:111];
			if (dateLabel == nil) {
				dateLabel = [[UILabel alloc] init];
				dateLabel.tag = 111;
				dateLabel.font = [UIFont boldSystemFontOfSize:17.0f];
				dateLabel.textColor = [UIColor colorWithRed:0.204f green:0.212f blue:0.239f alpha:0.83f];
				[headerView addSubview:dateLabel];
			}
			NSMutableArray *photoDatas;
			if (_isEditing && (_editingModeType == EditingModeTypeAddNewOne) && _isDividedAllPhoto) {
				photoDatas = [_dividedAllPhoto objectAtIndex:indexPath.section];
			}
			else {
				photoDatas = [_dividedAlbum objectAtIndex:indexPath.section];
			}
			PAPhotoData *photoData = [photoDatas objectAtIndex:0];
			dateLabel.text = [photoData dateFullString];
			CGSize textSize = [dateLabel.text sizeWithFont:dateLabel.font];
			dateLabel.frame = CGRectMake(10.0f, 0.0f, textSize.width, 27.0f);
			
			UILabel *photoCountLabel = (UILabel *)[headerView viewWithTag:222];
			if (photoCountLabel == nil) {
				photoCountLabel = [[UILabel alloc] init];
				photoCountLabel.tag = 222;
				photoCountLabel.font = [UIFont boldSystemFontOfSize:15.0f];
				photoCountLabel.textColor = [UIColor colorWithRed:0.204f green:0.212f blue:0.239f alpha:0.666f];
				photoCountLabel.textAlignment = NSTextAlignmentRight;
				[headerView addSubview:photoCountLabel];
			}
			
			photoCountLabel.text = [PAAlbumData displayCountString:photoDatas];;
			photoCountLabel.frame = CGRectMake(textSize.width + 10.0f, 0.0f, 320.0f - textSize.width - 20.0f, 27.0f);
		}
	}
	
	return reusableview;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{	
	if (section > 0) {
		return CGSizeMake(0.0f, 27.0f);
	}
	
	if (_editingModeType == EditingModeTypeSort) {
		return CGSizeMake(0.0f, 284.0f);
	}
	else if (_editingModeType == EditingModeTypeAddNewOne) {
		if (_isDividedAllPhoto) {
			return CGSizeMake(0.0f, 311.0f);
		}
		else {
			return CGSizeMake(0.0f, 284.0f);
		}
	}
	else {
		if (_isDividedAlbum) {
			return CGSizeMake(0.0f, 311.0f);
		}
		else {
			return CGSizeMake(0.0f, 284.0f);
		}
	}
	
	return CGSizeZero;
}

#pragma mark LXReorderableCollectionViewFlowLayoutDataSource
- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath willMoveToIndexPath:(NSIndexPath *)toIndexPath
{
	PAPhotoData *photoData = [_tmpPhotoData objectAtIndex:fromIndexPath.row];
	[_tmpPhotoData removeObject:photoData];
	[_tmpPhotoData insertObject:photoData atIndex:toIndexPath.row];
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath;
{
	if (_isEditing && (_editingModeType == EditingModeTypeSort)) {
		return YES;
	}
	
	return NO;
}

#pragma mark AlbumTitle

//TextFieldDelegate

- (void)tapAlbumTitle:(id)sender
{
	if (_appDelegate.albumDataController.isEditable == NO) {
		[self showDontEditingAlertView];
		return;
	}
	
	_saveAlbumToCameraroll = NO;
	
	[self showAlbumTitleAlertView];
}

- (void)showAlbumTitleAlertView
{
	NSString *title= NSLocalizedString(@"Album Title", @"PTAlbumViewController");
	NSString *message= NSLocalizedString(@"Enter a title for this album.", @"PTAlbumViewController");
	NSString *cancel= NSLocalizedString(@"Cancel", @"PTAlbumViewController");
	NSString *done= NSLocalizedString(@"Done", @"PTAlbumViewController");
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
													message:message
												   delegate:self
										  cancelButtonTitle:cancel
										  otherButtonTitles:done, nil];
	alert.alertViewStyle = UIAlertViewStylePlainTextInput;
	
	alert.tag = 555;
	
	UITextField* textField = [alert textFieldAtIndex:0];
	textField.text = _albumData.title;
	
	textField.returnKeyType = UIReturnKeyDone;
	textField.delegate = self;
	
	[alert show];	
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertView.tag == 555) {
		if (buttonIndex == 1) {
			//Doneボタンが押されたとき
			UITextField *textField = [alertView textFieldAtIndex:0];
			NSString *text = textField.text;
			
			_albumData.title = text;
			[_albumData checkAlbumData];
			
			[_appDelegate.albumDataController asyncSaveAlbumDataController];
			
			[_navigationController requestReloadData];
			
			[self.navigationItem setTitle:_albumData.displayTitleString];
			if (_saveAlbumToCameraroll && _saveAlbumAllPhotos) {
				MBProgressHUD *progressHUD = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
				NSString *title = NSLocalizedString(@"Saving...", @"PTAlbumViewController");
				progressHUD.labelText = title;
				
				dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{	
				[_appDelegate.albumDataController saveAlbumDataToCameraRoll:_albumData];
					dispatch_async(dispatch_get_main_queue(), ^{
						[MBProgressHUD hideHUDForView:self.view.window animated:YES];
					});
				});
			}
			else if (_saveAlbumToCameraroll && !_saveAlbumAllPhotos) {
				_editingModeType = EditingModeTypeSaveAlbum;
				
				NSString *caption;
				if (_albumData.countOfPhotos > 0 && _albumData.countOfVideos > 0) {
					caption = NSLocalizedString(@"Select items to Save this Album", @"PTAlbumViewController");
				}
				else if (_albumData.countOfPhotos > 0) {
					caption = NSLocalizedString(@"Select photos to save this album", @"PTAlbumViewController");
				}
				else if (_albumData.countOfVideos > 0) {
					caption = NSLocalizedString(@"Select videos to save this album", @"PTAlbumViewController");
				}
				else {
					caption = NSLocalizedString(@"Select items to Save this Album", @"PTAlbumViewController");
				}
				[self editingModeEnableWithCaption:caption doneButtonEnable:YES];
			}
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


#pragma mark Segue

- (void)backBarUIButton
{
	[self performSegueWithIdentifier:_returnSegueIdentifier sender:self];
}

- (void)handleSwipeRightGesture:(UISwipeGestureRecognizer *)sender
{
	if (_isEditing == YES) {
		return;
	}
	
	[self backBarUIButton];
}

- (void)settingBarUIButton
{
	if (_appDelegate.albumDataController.isEditable == NO) {
		[self showDontEditingAlertView];
		return;
	}
	
	_actionSheetMode = @"AlbumSettings";
	
	NSString *title = NSLocalizedString(@"Album Settings", @"PTAlbumViewController");
	NSString *cancel = NSLocalizedString(@"Cancel", @"PTAlbumViewController");
	NSString *delete = NSLocalizedString(@"Delete this album", @"PTAlbumViewController");
	NSString *combine = NSLocalizedString(@"Combine other album", @"PTAlbumViewController");
	NSString *divide = NSLocalizedString(@"Divide this Album", @"PTAlbumViewController");
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title
															 delegate:self
													cancelButtonTitle:cancel
											   destructiveButtonTitle:delete
													otherButtonTitles:combine, divide, nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	[actionSheet showInView:self.view.window];
}

- (void)toggleLeftPanel
{
	[_navigationController showLeftPanel];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ( [[segue identifier] isEqualToString:@"AlbumToPhoto"] ) {
	}
}

- (IBAction)albumViewReturnActionForSegue:(UIStoryboardSegue *)segue
{
	NSInteger index = 0;
	if ([segue.identifier isEqualToString:@"AlbumFromPhoto"]) {
		PAPhotoViewController *photoViewController = segue.sourceViewController;
		
		index = photoViewController.indexOfPhotoDatas;
	}
	else if ([segue.identifier isEqualToString:@"AlbumFromMap"]) {
		PTGPSMapViewController *gpsMapViewController = segue.sourceViewController;
		
		index = gpsMapViewController.indexOfPhotoDatas;
	}
	
	NSIndexPath *indexPath = [self indexPathFromIndex:index];
	
	if ([_collectionView.indexPathsForVisibleItems containsObject:indexPath] == NO) {
		if (_collectionView.indexPathsForVisibleItems.count > 0) {
			NSIndexPath *visibleIndexPath = [_collectionView.indexPathsForVisibleItems objectAtIndex:0];
			if (indexPath.row < visibleIndexPath.row) {
				[_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
				_collectionView.contentOffset = CGPointMake(0, _collectionView.contentOffset.y - 88.0f);
			}
			else {
				[_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
			}
		}
	}
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	CGFloat offsetY = _collectionView.contentOffset.y;
	CGFloat scrollY = 284.0f - offsetY;
	CGFloat toolBarY = offsetY - 240.0f;
	
	if (offsetY > 240.0f)
	{
		offsetY = 72.0f;
		scrollY = 44.0f;
		toolBarY = 0.0f;
	}
	else if (offsetY < 0.0f) {
		offsetY = 0.0f;
	}
	else {
		offsetY /= 3.333f;
	}
	
	_headerBackView.frame = CGRectMake(0.0f,
									   offsetY,
									   _headerImageView.frame.size.width,
									   _headerImageView.frame.size.height);
	
	_headerViewToolBar.frame = CGRectMake(0.0f,
										  -toolBarY,
										  _headerViewToolBar.frame.size.width,
										  _headerViewToolBar.frame.size.height);
	
	_collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(scrollY, 0.0f, 0.0f, 0.0f);
}

#pragma mark ReloadData
- (void)reloadData
{
	if (_isDisableReloadData == YES) {
		return;
	}
	
	if (_albumData.showDateInAlbumView == PTShowDateInAlbumViewAuto) {
		if (_albumData.dateString != nil && [_albumData.dateString isEqualToString:_albumData.endDateString] == NO) {
			_isDividedAlbum = YES;
		}
		else {
			_isDividedAlbum = NO;
		}
	}
	else if (_albumData.showDateInAlbumView == PTShowDateInAlbumViewYes) {
		_isDividedAlbum = YES;
	}
	else {
		_isDividedAlbum = NO;
	}
	if (_isDividedAlbum) {
		_dividedAlbum = [_albumData dividePhotosInAlbumByDate];
	}
	
	if ([_allPhoto.dateString isEqualToString:_allPhoto.endDateString] == YES) {
		_isDividedAllPhoto = NO;
	}
	else {
		_isDividedAllPhoto = YES;
	}
	if (_isAddNewOne && _isDividedAllPhoto) {
		_dividedAllPhoto = [_allPhoto dividePhotosInAlbumByDate];
	}
	
	[_selectedCellIndexPaths removeAllObjects];
	
	dispatch_async(dispatch_get_main_queue(), ^{
		[self.collectionView reloadData];
	});
	
	if (_divideViewController != nil) {
		[_divideViewController reloadData];
	}
	if (_combineViewController != nil) {
		[_combineViewController reloadData];
	}
}


#pragma mark ButtonAction

- (void)headerViewImageAction:(id)sender
{
	if (_appDelegate.albumDataController.isEditable == NO) {
		[self showDontEditingAlertView];
		return;
	}
	
	_editingModeType = EditingModeTypeThumbnail;
	
	NSString *caption;
	if (_albumData.countOfPhotos > 0 && _albumData.countOfVideos > 0) {
		caption = NSLocalizedString(@"Select an item for cover photo", @"PTAlbumViewController");
	}
	else if (_albumData.countOfPhotos > 0) {
		caption = NSLocalizedString(@"Select a photo for cover photo", @"PTAlbumViewController");
	}
	else if (_albumData.countOfVideos > 0) {
		caption = NSLocalizedString(@"Select a video for cover photo", @"PTAlbumViewController");
	}
	else {
		caption = NSLocalizedString(@"Select an item for cover photo", @"PTAlbumViewController");
	}
	[self editingModeEnableWithCaption:caption doneButtonEnable:NO];
}

- (IBAction)headerViewAddButtonAction:(id)sender
{
	if (_appDelegate.albumDataController.isEditable == NO) {
		[self showDontEditingAlertView];
		return;
	}
	
	_editingModeType = EditingModeTypeAddNewOne;
	
	_isAddNewOne = YES;
	
	if ([_allPhoto.dateString isEqualToString:_allPhoto.endDateString] == YES) {
		_isDividedAllPhoto = NO;
	}
	else {
		_isDividedAllPhoto = YES;
		
		_dividedAllPhoto = [_allPhoto dividePhotosInAlbumByDate];
	}
	
	NSString *caption;
	if (_allPhoto.countOfPhotos > 0 && _allPhoto.countOfVideos > 0) {
		caption = NSLocalizedString(@"Select items to add", @"PTAlbumViewController");
	}
	else if (_allPhoto.countOfPhotos > 0) {
		caption = NSLocalizedString(@"Select photos to add", @"PTAlbumViewController");
	}
	else if (_allPhoto.countOfVideos > 0) {
		caption = NSLocalizedString(@"Select videos to add", @"PTAlbumViewController");
	}
	else {
		caption = NSLocalizedString(@"Select items to add", @"PTAlbumViewController");
	}
	[self editingModeEnableWithCaption:caption doneButtonEnable:YES];
}

- (IBAction)headerViewSortButtonAction:(id)sender
{
	if (_appDelegate.albumDataController.isEditable == NO) {
		[self showDontEditingAlertView];
		return;
	}
	
	_actionSheetMode = @"Sort";
	
	NSString *title;
	if (_albumData.countOfPhotos > 0 && _albumData.countOfVideos > 0) {
		title = NSLocalizedString(@"Sort items", @"PTAlbumViewController");
	}
	else if (_albumData.countOfPhotos > 0) {
		title = NSLocalizedString(@"Sort photos", @"PTAlbumViewController");
	}
	else if (_albumData.countOfVideos > 0) {
		title = NSLocalizedString(@"Sort videos", @"PTAlbumViewController");
	}
	else {
		title = NSLocalizedString(@"Sort items", @"PTAlbumViewController");
	}
	NSString *cancel = NSLocalizedString(@"Cancel", @"PTAlbumViewController");
	NSString *sortManually = NSLocalizedString(@"Sort manually", @"PTAlbumViewController");
	NSString *sortByDateAscending = NSLocalizedString(@"Sort by date (Ascending)", @"PTAlbumViewController");
	NSString *sortByDateDescending = NSLocalizedString(@"Sort by date (Descending)", @"PTAlbumViewController");
	NSString *showDate;
	if (_albumData.showDateInAlbumView == PTShowDateInAlbumViewAuto) {
		if (_isDividedAlbum) {
			showDate = NSLocalizedString(@"Do not show date in this album", @"PTAlbumViewController");
		}
		else {
			showDate = NSLocalizedString(@"Show date in this album", @"PTAlbumViewController");
		}
	}
	else if (_albumData.showDateInAlbumView == PTShowDateInAlbumViewYes) {
		showDate = NSLocalizedString(@"Do not show date in this album", @"PTAlbumViewController");
	}
	else {
		showDate = NSLocalizedString(@"Show date in this album", @"PTAlbumViewController");
	}
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title
															 delegate:self
													cancelButtonTitle:cancel
											   destructiveButtonTitle:nil
													otherButtonTitles:sortManually, sortByDateAscending, sortByDateDescending, showDate, nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	
	[actionSheet showInView:self.view.window];
}

- (IBAction)headerViewSaveAlbumButtonAction:(id)sender
{
	if (_appDelegate.albumDataController.isEditable == NO) {
		[self showDontEditingAlertView];
		return;
	}
	
	_actionSheetMode = @"SaveAlbum";
	
	NSString *title = NSLocalizedString(@"Save album to Camera Roll", @"PTAlbumViewController");
	NSString *cancel = NSLocalizedString(@"Cancel", @"PTAlbumViewController");
	NSString *allInThisAlbum;
	NSString *select;
	if (_albumData.countOfPhotos > 0 && _albumData.countOfVideos > 0) {
		allInThisAlbum = NSLocalizedString(@"All items in this album", @"PTAlbumViewController");
		select = NSLocalizedString(@"Select items", @"PTAlbumViewController");
	}
	else if (_albumData.countOfPhotos > 0) {
		allInThisAlbum = NSLocalizedString(@"All photos in this album", @"PTAlbumViewController");
		select = NSLocalizedString(@"Select photos", @"PTAlbumViewController");
	}
	else if (_albumData.countOfVideos > 0) {
		allInThisAlbum = NSLocalizedString(@"All videos in this album", @"PTAlbumViewController");
		select = NSLocalizedString(@"Select videos", @"PTAlbumViewController");
	}
	else {
		allInThisAlbum = NSLocalizedString(@"All items in this album", @"PTAlbumViewController");
		select = NSLocalizedString(@"Select items", @"PTAlbumViewController");
	}
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title
															 delegate:self
													cancelButtonTitle:cancel
											   destructiveButtonTitle:nil
													otherButtonTitles:allInThisAlbum, select, nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	[actionSheet showInView:self.view.window];
}

- (IBAction)headerViewShareButtonAction:(id)sender
{
	if (_appDelegate.albumDataController.isEditable == NO) {
		[self showDontEditingAlertView];
		return;
	}
	
	_actionSheetMode = @"Share";
	
	NSString *title;
	if (_albumData.countOfPhotos > 0 && _albumData.countOfVideos > 0) {
		title = NSLocalizedString(@"Share items", @"PTAlbumViewController");
	}
	else if (_albumData.countOfPhotos > 0) {
		title = NSLocalizedString(@"Share photos", @"PTAlbumViewController");
	}
	else if (_albumData.countOfVideos > 0) {
		title = NSLocalizedString(@"Share videos", @"PTAlbumViewController");
	}
	else {
		title = NSLocalizedString(@"Share items", @"PTAlbumViewController");
	}
	NSString *cancel = NSLocalizedString(@"Cancel", @"PTAlbumViewController");
	NSString *facebook = NSLocalizedString(@"Facebook", @"PTAlbumViewController");
	NSString *twitter = NSLocalizedString(@"Twitter", @"PTAlbumViewController");
	NSString *line = NSLocalizedString(@"LINE", @"PTAlbumViewController");
	NSString *mail = NSLocalizedString(@"Mail", @"PTAlbumViewController");
	NSString *openIn = NSLocalizedString(@"Open In...", @"PTAlbumViewController");
	UIActionSheet *actionSheet;
	if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"line://"]]) {
		actionSheet = [[UIActionSheet alloc] initWithTitle:title
												  delegate:self
										 cancelButtonTitle:cancel
									destructiveButtonTitle:nil
										 otherButtonTitles:facebook, twitter, line, mail, openIn, nil];
		actionSheet.tag = 112;
	}
	else {
		actionSheet = [[UIActionSheet alloc] initWithTitle:title
												  delegate:self
										 cancelButtonTitle:cancel
									destructiveButtonTitle:nil
										 otherButtonTitles:facebook, twitter, mail, openIn, nil];
		actionSheet.tag = 111;
	}
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	[actionSheet showInView:self.view.window];
}

- (IBAction)headerViewRemoveButtonAction:(id)sender
{
	if (_appDelegate.albumDataController.isEditable == NO) {
		[self showDontEditingAlertView];
		return;
	}
	
	_editingModeType = EditingModeTypeRemove;
	
	NSString *caption;
	if (_albumData.countOfPhotos > 0 && _albumData.countOfVideos > 0) {
		caption = NSLocalizedString(@"Select items to remove", @"PTAlbumViewController");
	}
	else if (_albumData.countOfPhotos > 0) {
		caption = NSLocalizedString(@"Select photos to remove", @"PTAlbumViewController");
	}
	else if (_albumData.countOfVideos > 0) {
		caption = NSLocalizedString(@"Select videos to remove", @"PTAlbumViewController");
	}
	else {
		caption = NSLocalizedString(@"Select items to remove", @"PTAlbumViewController");
	}
	[self editingModeEnableWithCaption:caption doneButtonEnable:YES];
}

- (void)editingModeEnableWithCaption:(NSString *)caption doneButtonEnable:(BOOL)doneButtonEnable
{
	_isDisableReloadData = YES;
	
	_headerViewToolBarLabel.text = caption;
	
	[_selectedCellIndexPaths removeAllObjects];
	
	if (_collectionView.contentOffset.y <= 240.0f) {
		[_collectionView setContentOffset:CGPointMake(0.0f, 240.0f) animated:YES];
	}
	
	_collectionView.userInteractionEnabled = NO;
	
	UIBarButtonItem *rightBarButtonItem = self.navigationItem.rightBarButtonItem;
	UIButton *rightBarButton = (UIButton *)[rightBarButtonItem customView];
	UIBarButtonItem *leftBarButtonItem = self.navigationItem.leftBarButtonItem;
	UIButton *leftBarButton = (UIButton *)[leftBarButtonItem customView];
	
	[UIView animateWithDuration:0.3f animations:^{
		_collectionView.alpha = 0.0f;
		
		rightBarButton.alpha = 0.0f;
		leftBarButton.alpha = 0.0f;
		
		_headerViewAddButton.alpha = 0.0f;
		_headerViewSortButton.alpha = 0.0f;
		_headerViewSaveAlbumButton.alpha = 0.0f;
		_headerViewShareButton.alpha = 0.0f;
		_headerViewRemoveButton.alpha = 0.0f;
		
		_headerViewToolBarLabel.alpha = 1.0f;
	} completion:^(BOOL finished) {
		[self editingModeEnable:doneButtonEnable];
	}];
}

- (void)editingModeEnable:(BOOL)doneButtonEnable
{
	_isEditing = YES;
	
	[_collectionView reloadData];
	
	_collectionView.contentInset = UIEdgeInsetsMake(-240.0f, 0.0f, 0.0f, 0.0f);
	if (_isAddNewOne) {
		[_collectionView setContentOffset:CGPointMake(0.0f, 240.0f) animated:NO];
	}
	
	//ナヴィゲーションバーボタンの追加
	UIButton *customView = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 36.0f, 36.0f)];
	[customView setImage:[UIImage imageNamed:@"60-x.png"] forState:UIControlStateNormal];
	[customView setImage:[UIImage imageNamed:@"60-x_touched.png"] forState:UIControlStateHighlighted];
	customView.showsTouchWhenHighlighted = YES;
	customView.exclusiveTouch = YES;
	customView.alpha = 0.0f;
	[customView addTarget:self action:@selector(cancelButtonAction) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem* buttonItem = [[UIBarButtonItem alloc] initWithCustomView:customView];
	self.navigationItem.leftBarButtonItem = buttonItem;
	
	UIButton *customView1;
	if (doneButtonEnable) {
		customView1 = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 36.0f, 36.0f)];
		[customView1 setImage:[UIImage imageNamed:@"47-o.png"] forState:UIControlStateNormal];
		[customView1 setImage:[UIImage imageNamed:@"47-o_touched.png"] forState:UIControlStateHighlighted];
		customView1.showsTouchWhenHighlighted = YES;
		customView1.exclusiveTouch = YES;
		customView1.alpha = 0.0f;
		[customView1 addTarget:self action:@selector(didSelectPhotos) forControlEvents:UIControlEventTouchUpInside];
		UIBarButtonItem* buttonItem1 = [[UIBarButtonItem alloc] initWithCustomView:customView1];
		self.navigationItem.rightBarButtonItem = buttonItem1;
	}
	else {
		UIButton *customView = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 36.0f, 36.0f)];
		UIBarButtonItem* buttonItem = [[UIBarButtonItem alloc] initWithCustomView:customView];
		self.navigationItem.rightBarButtonItem = buttonItem;
	}
	
	[UIView animateWithDuration:0.3f animations:^{
		_collectionView.alpha = 1.0f;
		
		customView.alpha = 1.0f;
		if (doneButtonEnable) {
			customView1.alpha = 1.0f;
		}
	} completion:^(BOOL finished) {		
		_collectionView.userInteractionEnabled = YES;
		
		_isDisableReloadData = NO;
	}];
}

- (void)cancelButtonAction
{
	_isDisableReloadData = YES;
	
	if (_collectionView.contentOffset.y <= 240.0f && (_editingModeType != EditingModeTypeThumbnail)) {
		[_collectionView setContentOffset:CGPointMake(0.0f, 0.0f) animated:YES];
	}
	
	_collectionView.userInteractionEnabled = NO;
	
	UIBarButtonItem *rightBarButtonItem = self.navigationItem.rightBarButtonItem;
	UIButton *rightBarButton = (UIButton *)[rightBarButtonItem customView];
	UIBarButtonItem *leftBarButtonItem = self.navigationItem.leftBarButtonItem;
	UIButton *leftBarButton = (UIButton *)[leftBarButtonItem customView];
	
	[UIView animateWithDuration:0.3f animations:^{
		_collectionView.alpha = 0.0f;
		
		rightBarButton.alpha = 0.0f;
		leftBarButton.alpha = 0.0f;
		
		_headerViewAddButton.alpha = 1.0f;
		_headerViewSortButton.alpha = 1.0f;
		_headerViewSaveAlbumButton.alpha = 1.0f;
		_headerViewShareButton.alpha = 1.0f;
		_headerViewRemoveButton.alpha = 1.0f;
		
		_headerViewToolBarLabel.alpha = 0.0f;
		
		if (( _isAddNewOne && _collectionView.contentOffset.y > 240.0f ) ||
			(_editingModeType == EditingModeTypeThumbnail)) {
			_headerViewToolBar.frame = CGRectMake(0.0f, 240.0f, _headerViewToolBar.frame.size.width, _headerViewToolBar.frame.size.height);
		}
	} completion:^(BOOL finished) {
		[self cancelEditingMode];
	}];
}

- (void)cancelEditingMode
{
	[self initNavigationBar];
	
	_isEditing = NO;
	
	[_collectionView reloadData];
	
	UIBarButtonItem *rightBarButtonItem = self.navigationItem.rightBarButtonItem;
	UIButton *rightBarButton = (UIButton *)[rightBarButtonItem customView];
	rightBarButton.alpha = 0.0f;
	UIBarButtonItem *leftBarButtonItem = self.navigationItem.leftBarButtonItem;
	UIButton *leftBarButton = (UIButton *)[leftBarButtonItem customView];
	leftBarButton.alpha = 0.0f;
	
	_collectionView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
	if (_isAddNewOne || (_editingModeType == EditingModeTypeThumbnail)) {
		_collectionView.contentOffset = CGPointMake(0.0f, 0.0f);
	}
	
	_editingModeType = EditingModeTypeNone;
	
	_isAddNewOne = NO;
	
	_collectionView.backgroundColor = [UIColor whiteColor];
	
	[UIView animateWithDuration:0.3f animations:^{
		_collectionView.alpha = 1.0f;
		
		rightBarButton.alpha = 1.0f;
		leftBarButton.alpha= 1.0f;
	} completion:^(BOOL finished) {
		_collectionView.userInteractionEnabled = YES;
		self.navigationItem.rightBarButtonItem.enabled = YES;
		self.navigationItem.leftBarButtonItem.enabled = YES;
		
		_isDisableReloadData = NO;
	}];
}

- (void)didSelectPhotos
{
	if (_editingModeType == EditingModeTypeSaveAlbum) {
		if (_selectedCellIndexPaths.count == 0) {
			[self cancelButtonAction];
			return;
		}
		
		[_selectedCellIndexPaths sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
			NSIndexPath *indexPath1 = (NSIndexPath *)obj1;
			NSIndexPath *indexPath2 = (NSIndexPath *)obj2;
			return [indexPath1 compare:indexPath2];
		}];
		
		[self saveAlbumWithIndexPaths:_selectedCellIndexPaths];
	}
	else if (_editingModeType == EditingModeTypeEtcAction) {
		MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
		hud.mode = MBProgressHUDModeAnnularDeterminate;
		NSString *title = NSLocalizedString(@"Loading...", @"PTAlbumViewController");
		hud.labelText = title;
		
		NSArray *indexPaths = [_selectedCellIndexPaths copy];
		NSMutableArray *actItems = [[NSMutableArray alloc] init];
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
			NSInteger count = 0;
			for (NSIndexPath *indexPath in indexPaths) {
				UIImage *image = [self loadImageAtIndexPath:indexPath];
				[actItems addObject:image];
				count++;
				hud.progress = (float)count/(float)indexPaths.count;
			}
			
			dispatch_async(dispatch_get_main_queue(), ^{
				[MBProgressHUD hideHUDForView:self.view.window animated:YES];
				UIActivityViewController *activityView = [[UIActivityViewController alloc] initWithActivityItems:actItems applicationActivities:nil];
				NSMutableArray *activityTypes = [[NSMutableArray alloc] init];
				[activityTypes addObjectsFromArray:@[UIActivityTypePostToFacebook, UIActivityTypePostToTwitter, UIActivityTypePostToWeibo, UIActivityTypeSaveToCameraRoll]];
				if (actItems.count >= 1) {
					[activityTypes addObjectsFromArray:@[UIActivityTypeAssignToContact]];
				}
				if (actItems.count >= 6) {
					[activityTypes addObjectsFromArray:@[UIActivityTypeMail, UIActivityTypeMessage]];
				}
				activityView.excludedActivityTypes = activityTypes;
				[self presentViewController:activityView animated:YES completion:nil];
				
				[self cancelButtonAction];
			});
		});
	}
	else if (_editingModeType == EditingModeTypeFacebook) {
		if (_selectedCellIndexPaths.count == 0) {
			[self cancelButtonAction];
			return;
		}
		
		if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
			MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
			hud.mode = MBProgressHUDModeAnnularDeterminate;
			NSString *title = NSLocalizedString(@"Loading...", @"PTAlbumViewController");
			hud.labelText = title;
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
				SLComposeViewController *facebookPostVC = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
				NSInteger count = 0;
				for (NSIndexPath *indexPath in _selectedCellIndexPaths) {
					UIImage *image = [self loadImageAtIndexPath:indexPath];
					NSData *data = UIImageJPEGRepresentation(image, 0.8f);
					image = [UIImage imageWithData:data];
					[facebookPostVC addImage:image];
					count++;
					hud.progress = (float)count/(float)_selectedCellIndexPaths.count;
				}
				[facebookPostVC setCompletionHandler:^(SLComposeViewControllerResult result) {
					if (result == SLComposeViewControllerResultDone) {
						NSLog(@"Post Facebook is Done");
					}
				}];
				
				dispatch_async(dispatch_get_main_queue(), ^{
					[MBProgressHUD hideHUDForView:self.view.window animated:YES];
					
					[self presentViewController:facebookPostVC animated:YES completion:nil];
				});
			});
		}
		
		[self cancelButtonAction];
	}
	else if (_editingModeType == EditingModeTypeMail) {
		if (_selectedCellIndexPaths.count == 0) {
			[self cancelButtonAction];
			return;
		}
		
		MFMailComposeViewController *mailPicker = [[MFMailComposeViewController alloc] init];
		mailPicker.mailComposeDelegate = self;
		
		MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
		hud.mode = MBProgressHUDModeAnnularDeterminate;
		NSString *title = NSLocalizedString(@"Loading...", @"PTAlbumViewController");
		hud.labelText = title;
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
			NSInteger count = 0;
			for (NSIndexPath *indexPath in _selectedCellIndexPaths) {
				UIImage *image = [self loadImageAtIndexPath:indexPath];
				NSData *data = UIImageJPEGRepresentation(image, 0.7f);
				NSString *fileName = [NSString stringWithFormat:@"Image%d.jpg", count];
				[mailPicker addAttachmentData:data mimeType:@"image.jpeg" fileName:fileName];
				
				count++;
				hud.progress = (float)count/(float)_selectedCellIndexPaths.count;
			}
			
			dispatch_async(dispatch_get_main_queue(), ^{
				[MBProgressHUD hideHUDForView:self.view.window animated:YES];
				
				[self presentViewController:mailPicker animated:YES completion:nil];
			});
		});
		
		[self cancelButtonAction];
	}
	else if (_editingModeType == EditingModeTypeRemove) {
		_actionSheetMode = @"Remove";
		
		NSString *title;
		if (_albumData.countOfPhotos > 0 && _albumData.countOfVideos > 0) {
			title = NSLocalizedString(@"These items will removed from this album, but will remain in your Photo Library.", @"PTAlbumViewController");
		}
		else if (_albumData.countOfPhotos > 0) {
			title = NSLocalizedString(@"These photos will removed from this album, but will remain in your Photo Library.", @"PTAlbumViewController");
		}
		else if (_albumData.countOfVideos > 0) {
			title = NSLocalizedString(@"These videos will removed from this album, but will remain in your Photo Library.", @"PTAlbumViewController");
		}
		else {
			title = NSLocalizedString(@"These Items will removed from this album, but will remain in your Photo Library.", @"PTAlbumViewController");
		}
		NSString *cancel = NSLocalizedString(@"Cancel", @"PTAlbumViewController");
		NSString *remove = NSLocalizedString(@"Remove", @"PTAlbumViewController");
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title
																 delegate:self
														cancelButtonTitle:cancel
												   destructiveButtonTitle:remove
														otherButtonTitles:nil];
		actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
		[actionSheet showInView:self.view];
	}
	else if (_editingModeType == EditingModeTypeAddNewOne) {
		if (_selectedCellIndexPaths.count > 0) {
			for (NSIndexPath *indexPath in _selectedCellIndexPaths) {
				PAPhotoData *photoData;
				if (_isDividedAllPhoto == YES) {
					NSMutableArray *photoDatas = [_dividedAllPhoto objectAtIndex:indexPath.section];
					photoData = [photoDatas objectAtIndex:indexPath.row];
				}
				else {
					photoData = [_allPhoto.photoDatas objectAtIndex:indexPath.row];
				}
				[_albumData.photoDatas addObject:photoData];
			};
			
			[_albumData checkAlbumData];
			
			[_appDelegate.albumDataController sortAlbumDataByDate];
			
			[_navigationController requestReloadData];
			
			[_appDelegate.albumDataController asyncSaveAlbumDataController];			
		}
		
		[self cancelButtonAction];
	}
	else if (_editingModeType == EditingModeTypeSort) {
		_albumData.photoDatas = _tmpPhotoData;
		
		[_albumData checkAlbumData];
		
		[_navigationController requestReloadData];
		
		[_appDelegate.albumDataController asyncSaveAlbumDataController];
		
		[self cancelButtonAction];
	}
}


#pragma mark UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (_appDelegate.albumDataController.isEditable == NO) {
		[self showDontEditingAlertView];
		return;
	}
	
	if ([@"SaveAlbum" isEqualToString:_actionSheetMode]) {
		if (buttonIndex == 0) {
			if (_albumData.title == nil) {
				_saveAlbumToCameraroll = YES;
				_saveAlbumAllPhotos = YES;
				
				[self showAlbumTitleAlertView];
			}
			else {
				NSMutableArray *indexPaths = [NSMutableArray array];
				if (_isDividedAlbum == YES) {
					for (int i=0; i<_dividedAlbum.count; i++) {
						NSMutableArray *photoDatas = [_dividedAlbum objectAtIndex:i];
						for (int j=0; j<photoDatas.count; j++) {
							NSIndexPath *indexPath = [NSIndexPath indexPathForRow:j inSection:i];
							[indexPaths addObject:indexPath];
						}
					}
				}
				else {
					for (NSInteger i=0; i<_albumData.photoDatas.count; i++) {
						NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
						[indexPaths addObject:indexPath];
					}
				}
				
				[self saveAlbumWithIndexPaths:indexPaths];
			}
		}
		else if (buttonIndex == 1) {
			if (_albumData.title == nil) {
				_saveAlbumToCameraroll = YES;
				_saveAlbumAllPhotos = NO;
				
				[self showAlbumTitleAlertView];
			}
			else {
				_editingModeType = EditingModeTypeSaveAlbum;
				
				NSString *caption;
				if (_albumData.countOfPhotos > 0 && _albumData.countOfVideos > 0) {
					caption = NSLocalizedString(@"Select items to save this album", @"PTAlbumViewController");
				}
				else if (_albumData.countOfPhotos > 0) {
					caption = NSLocalizedString(@"Select photos to save this album", @"PTAlbumViewController");
				}
				else if (_albumData.countOfVideos > 0) {
					caption = NSLocalizedString(@"Select videos to save this album", @"PTAlbumViewController");
				}
				else {
					caption = NSLocalizedString(@"Select items to save this album", @"PTAlbumViewController");
				}
				[self editingModeEnableWithCaption:caption doneButtonEnable:YES];
			}
		}
	}
	else if ([@"Share" isEqualToString:_actionSheetMode]) {
		if (buttonIndex == 0) {
			//Facebook
			_editingModeType = EditingModeTypeFacebook;
			
			if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
				NSString *caption = NSLocalizedString(@"Select photos for facebook", @"PTAlbumViewController");
				[self editingModeEnableWithCaption:caption doneButtonEnable:YES];
			}
			else {
				NSString *title = NSLocalizedString(@"Facebook account has not been set", @"PAAlbumViewController");
				NSString *message = NSLocalizedString(@"Please set your Facebook account from the Settings app.", @"PAAlbumViewController");
				NSString *ok = NSLocalizedString(@"OK", @"PAAlbumViewController");;
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
																	message:message
																   delegate:self
														  cancelButtonTitle:nil
														  otherButtonTitles:ok, nil];
				[alertView show];
			}
		}
		else if (buttonIndex == 1) {
			//Twitter
			_editingModeType = EditingModeTypeTwitter;
			
			if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
				NSString *caption = NSLocalizedString(@"Select a photo for twitter", @"PTAlbumViewController");
				[self editingModeEnableWithCaption:caption doneButtonEnable:NO];
			}
			else {
				NSString *title = NSLocalizedString(@"Twitter account has not been set", @"PAAlbumViewController");
				NSString *message = NSLocalizedString(@"Please set your Twitter account from the Settings app.", @"PAAlbumViewController");
				NSString *ok = NSLocalizedString(@"OK", @"PAAlbumViewController");;
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
																	message:message
																   delegate:self
														  cancelButtonTitle:nil
														  otherButtonTitles:ok, nil];
				[alertView show];
			}
		}
		else if (buttonIndex == 2 && actionSheet.tag == 112) {
			_editingModeType = EditingModeTypeLine;
			
			NSString *caption = NSLocalizedString(@"Select a photo for LINE", @"PAAlbumViewController");
			[self editingModeEnableWithCaption:caption doneButtonEnable:NO];
		}
		else if ((buttonIndex == 2 && actionSheet.tag == 111) || (buttonIndex == 3 && actionSheet.tag == 112)) {
			//Mail
			_editingModeType = EditingModeTypeMail;
			
			NSString *caption = NSLocalizedString(@"Select photos for mail", @"PTAlbumViewController");
			[self editingModeEnableWithCaption:caption doneButtonEnable:YES];
		}
		else if ((buttonIndex == 3 && actionSheet.tag == 111) || (buttonIndex == 4 && actionSheet.tag == 112)){
			//Open In...
			_editingModeType = EditingModeTypeOpenIn;
			
			NSString *caption;
			if (_albumData.countOfPhotos > 0 && _albumData.countOfVideos > 0) {
				caption = NSLocalizedString(@"Select an item for \"Open in...\"", @"PTAlbumViewController");
			}
			else if (_albumData.countOfPhotos > 0) {
				caption = NSLocalizedString(@"Select a photo for \"Open in...\"", @"PTAlbumViewController");
			}
			else if (_albumData.countOfVideos > 0) {
				caption = NSLocalizedString(@"Select a video for \"Open in...\"", @"PTAlbumViewController");
			}
			else {
				caption = NSLocalizedString(@"Select an item for \"Open in...\"", @"PTAlbumViewController");
			}
			[self editingModeEnableWithCaption:caption doneButtonEnable:NO];
		}
	}
	else if ([@"Remove" isEqualToString:_actionSheetMode]) {
		if (buttonIndex == 0) {
			[_selectedCellIndexPaths sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
				NSIndexPath *indexPath1 = (NSIndexPath *)obj1;
				NSIndexPath *indexPath2 = (NSIndexPath *)obj2;
				
				return [indexPath2 compare:indexPath1];
			}];
			
			for (NSIndexPath *indexPath in _selectedCellIndexPaths) {
				PAPhotoData *photoData;
				if (_isDividedAlbum) {
					NSMutableArray *photoDatas = [_dividedAlbum objectAtIndex:indexPath.section];
					photoData = [photoDatas objectAtIndex:indexPath.row];
				}
				else {
					photoData = [_albumData.photoDatas objectAtIndex:indexPath.row];
				}
				
				[_albumData.photoDatas removeObject:photoData];
			}
			
			[_albumData checkAlbumData];
			
			[_appDelegate.albumDataController sortAlbumDataByDate];
						
			[_navigationController requestReloadData];
			
			[_appDelegate.albumDataController asyncSaveAlbumDataController];
			
			[self cancelButtonAction];
		}
	}
	else if ([@"AlbumSettings" isEqualToString:_actionSheetMode]) {
		if (buttonIndex == 0) {
			//Delete
			_actionSheetMode = @"DeleteAlbum";
			
			NSString *title;
			if (_albumData.countOfPhotos > 0 && _albumData.countOfVideos > 0) {
				title = NSLocalizedString(@"Are you sure you want to delete this album? The items will not be deleted.", @"PTAlbumViewController");
			}
			else if (_albumData.countOfPhotos > 0) {
				title = NSLocalizedString(@"Are you sure you want to delete this album? The photos will not be deleted.", @"PTAlbumViewController");
			}
			else if (_albumData.countOfVideos > 0) {
				title = NSLocalizedString(@"Are you sure you want to delete this album? The videos will not be deleted.", @"PTAlbumViewController");
			}
			else {
				title = NSLocalizedString(@"Are you sure you want to delete this album? The items will not be deleted.", @"PTAlbumViewController");
			}
			NSString *cancel = NSLocalizedString(@"Cancel", @"PTAlbumViewController");
			NSString *delete = NSLocalizedString(@"Delete this album", @"PTAlbumViewController");
			UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title
																	 delegate:self
															cancelButtonTitle:cancel
													   destructiveButtonTitle:delete
															otherButtonTitles:nil];
			actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
			[actionSheet showInView:self.view];
		}
		else if (buttonIndex == 1) {
			//Combine
			PTAppDelegate *appDelegate = (PTAppDelegate *)[[UIApplication sharedApplication] delegate];
			
			_combineViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PTCombineViewController"];
			_combineViewController.albumDatas = appDelegate.albumDataController.albumDatas;
			_combineViewController.firstIndexPath = [NSIndexPath indexPathForRow:[appDelegate.albumDataController.albumDatas indexOfObject:_albumData] inSection:0];
			_combineViewController.myDelegate = self;
			
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:_combineViewController];
			
			[self presentViewController:navigationController animated:YES completion:nil];
		}
		else if (buttonIndex == 2) {
			//Divide
			if (_albumData.photoDatas.count > 1) {
				_divideViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PTDivideViewController"];
				_divideViewController.albumData = _albumData;
				_divideViewController.myDelegate = self;
				
				PTAlbumSettingsNavigationController *navigationController = [[PTAlbumSettingsNavigationController alloc] initWithRootViewController:_divideViewController];
				
				[self presentViewController:navigationController animated:YES completion:nil];
			}
		}
	}
	else if ([@"DeleteAlbum" isEqualToString:_actionSheetMode]) {
		if (buttonIndex == 0) {
			//DeleteAlbum
			_isDeleteAlbum = YES;
			
			[self performSegueWithIdentifier:_returnSegueIdentifier sender:self];
		}
	}
	else if ([@"Sort" isEqualToString:_actionSheetMode]) {
		if (buttonIndex == 0) {
			//Manually
			_tmpPhotoData = [_albumData.photoDatas mutableCopy];
			
			_editingModeType = EditingModeTypeSort;
			
			NSString *caption;
			if (_albumData.countOfPhotos > 0 && _albumData.countOfVideos > 0) {
				caption = NSLocalizedString(@"Long tap an item to rearrange", @"PTAlbumViewController");
			}
			else if (_albumData.countOfPhotos > 0) {
				caption = NSLocalizedString(@"Long tap a photo to rearrange", @"PTAlbumViewController");
			}
			else if (_albumData.countOfVideos > 0) {
				caption = NSLocalizedString(@"Long tap a video to rearrange", @"PTAlbumViewController");
			}
			else {
				caption = NSLocalizedString(@"Long tap an item to rearrange", @"PTAlbumViewController");
			}
			[self editingModeEnableWithCaption:caption doneButtonEnable:YES];
		}
		else if (buttonIndex == 1) {
			//Sort
			[_albumData sortPhotoDataByDate];
			
			[_albumData checkAlbumData];
			
			[_navigationController requestReloadData];
			
			[_appDelegate.albumDataController asyncSaveAlbumDataController];
		}
		else if (buttonIndex == 2) {
			//SortReverse
			[_albumData sortPhotoDataByDateReverse];
			
			[_albumData checkAlbumData];
			
			[_navigationController requestReloadData];
			
			[_appDelegate.albumDataController asyncSaveAlbumDataController];

		}
		else if (buttonIndex == 3) {
			//アルバム内で日付を表示しない
			if (_albumData.showDateInAlbumView == PTShowDateInAlbumViewAuto) {
				if (_albumData.dateString != nil && [_albumData.dateString isEqualToString:_albumData.endDateString] == NO) {
					_albumData.showDateInAlbumView = PTShowDateInAlbumViewNo;
				}
				else {
					_albumData.showDateInAlbumView = PTShowDateInAlbumViewYes;
				}
			}
			else if (_albumData.showDateInAlbumView == PTShowDateInAlbumViewYes) {
				_albumData.showDateInAlbumView = PTShowDateInAlbumViewNo;
			}
			else {
				_albumData.showDateInAlbumView = PTShowDateInAlbumViewYes;
			}
			
			[_navigationController requestReloadData];
			
			[_appDelegate.albumDataController asyncSaveAlbumDataController];			
		}
	}
}

#pragma mark MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark PTCombineViewControllerDelegate
- (void)combineAlbums:(NSMutableArray *)selectedAlbumDatas
{
	PAAlbumData *newAlbumData = [_appDelegate.albumDataController combinedAlbumDataFromAlbumDatas:selectedAlbumDatas];
	
	for (PAAlbumData *albumData in selectedAlbumDatas) {
		[_appDelegate.albumDataController.albumDatas removeObject:albumData];
	}
	
	[_appDelegate.albumDataController.albumDatas addObject:newAlbumData];
	
	[_appDelegate.albumDataController sortAlbumDataByDate];
	
	[_appDelegate.albumDataController asyncSaveAlbumDataController];
	
	if ([selectedAlbumDatas containsObject:_albumData]) {
		_albumData = newAlbumData;
	}
	
	[_navigationController requestReloadData];
}

- (void)divideAlbum:(PAAlbumData *)albumData
{
	[_appDelegate.albumDataController.albumDatas addObject:albumData];
	
	[_appDelegate.albumDataController sortAlbumDataByDate];
	
	[_appDelegate.albumDataController asyncSaveAlbumDataController];
	
	[_navigationController requestReloadData];
}

#pragma mark Etc.

- (NSIndexPath *)indexPathFromIndex:(NSInteger)index
{
	NSIndexPath *indexPath;
	if (_isDividedAlbum == NO) {
		indexPath = [NSIndexPath indexPathForRow:index inSection:0];
	}
	else {
		PAPhotoData *photoData = [_albumData.photoDatas objectAtIndex:index];
		for (NSMutableArray *photoDatas in _dividedAlbum) {
			if ([photoDatas containsObject:photoData]) {
				indexPath = [NSIndexPath indexPathForRow:[photoDatas indexOfObject:photoData] inSection:[_dividedAlbum indexOfObject:photoDatas]];
				break;
			}
		}
	}
	
	return indexPath;
}

- (void)showDontEditingAlertView
{
	NSString *title = NSLocalizedString(@"This function is not enabled while loading.", @"PTAlbumViewController");
	NSString *message = NSLocalizedString(@"Please try again after waiting for a while. ", @"PTAlbumViewController");
	NSString *ok = NSLocalizedString(@"OK", @"PTAlbumViewController");
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
													message:message
												   delegate:self
										  cancelButtonTitle:nil
										  otherButtonTitles:ok, nil];
	alert.tag = 777;
	[alert show];
}

- (void)showVideoCannotBeShareAlertViewMode:(EditingModeType)editingModeType
{
	NSString *title = NSLocalizedString(@"It cannot be selected.", @"PTAlbumViewController");
	NSString *message;
	if (editingModeType == EditingModeTypeTwitter) {
		message = NSLocalizedString(@"A video cannot tweet.", @"PTAlbumViewController");
	}
	else if (editingModeType == EditingModeTypeFacebook) {
		message = NSLocalizedString(@"A video cannot post facebook", @"PTAlbumViewController");
	}
	else if (editingModeType == EditingModeTypeMail) {
		message = NSLocalizedString(@"A video cannot be send mail.", @"PTAlbumViewController");
	}
	else if (editingModeType == EditingModeTypeLine) {
		message = NSLocalizedString(@"A video cannot be send LINE.", @"PTAlbumViewController");
	}
	else {
		message = nil;
	}
	NSString *ok = NSLocalizedString(@"OK", @"PTAlbumViewController");
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
														message:message
													   delegate:self
											  cancelButtonTitle:nil
											  otherButtonTitles:ok, nil];
	[alertView show];
}

- (UIImage *)loadImageAtIndexPath:(NSIndexPath *)indexPath
{
	PAPhotoData *photoData;
	if (_isDividedAlbum) {
		NSMutableArray *photoDatas = [_dividedAlbum objectAtIndex:indexPath.section];
		photoData = [photoDatas objectAtIndex:indexPath.row];
	}
	else {
		photoData = [_albumData.photoDatas objectAtIndex:indexPath.row];
	}
	
	UIImage *decompressedImage;
	if (MIN([photoData dimensions].height, [photoData dimensions].width) > 1280) {
		decompressedImage = [photoData makeThumbnailImage:960];
	}
	else {
		decompressedImage = [photoData fullResolutionImage];
	}
	
    return decompressedImage;
}

- (void)albumDataChanged
{	
	[_navigationController albumDataChanged];
}


- (void)saveAlbumWithIndexPaths:(NSArray *)indexPaths
{		
	MBProgressHUD *progressHUD = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
	NSString *title = NSLocalizedString(@"Saving...", @"PTAlbumViewController");
	progressHUD.labelText = title;
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
		PAAlbumData *albumData = [[PAAlbumData alloc] init];
		albumData.title = _albumData.title;
		
		for (NSIndexPath *indexPath in indexPaths) {
			PAPhotoData *photoData;
			if (_isDividedAlbum == YES) {
				NSMutableArray *photoDatas = [_dividedAlbum objectAtIndex:indexPath.section];
				photoData = [photoDatas objectAtIndex:indexPath.row];
			}
			else {
				photoData = [_albumData.photoDatas objectAtIndex:indexPath.row];
			}
			[albumData.photoDatas addObject:photoData];
		}
		
		[_appDelegate.albumDataController saveAlbumDataToCameraRoll:albumData];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			[MBProgressHUD hideHUDForView:self.view.window animated:YES];
			
			if (_isEditing) {
				[self cancelButtonAction];
			}
		});
	});
}

@end






