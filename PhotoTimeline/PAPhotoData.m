//
//  PAPhotoData.m
//  PhotoAlbum
//
//  Created by Karijuku Keisuke on 2013/04/02.
//  Copyright (c) 2013年 Keisuke Karijuku. All rights reserved.
//

#import "PAPhotoData.h"

@interface PAAlbumDataController ()
{
	NSDateFormatter *_formatter;
	
	NSOperationQueue *_accessPhotoLibraryQueue;
	
	NSOperationQueue *_saveDataBaseQueue;
	
	BOOL _isSavingAlbum;
}

@end

@implementation PAAlbumDataController

- (id)init
{
	self = [super init];
	if (self != nil)
	{
		NSLog(@"init-PAAlbumDataController");
		
		_library = [[ALAssetsLibrary alloc] init];
		
		_allPhoto = [[PAAlbumData alloc] init];
		_allPhoto.title = @"Camera Roll";
		_albumDatas = [[NSMutableArray alloc] init];
		_noDatePhotoDatas = [[NSMutableArray alloc] init];
		
		_formatter = [[NSDateFormatter alloc] init];
		[_formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"US"]];
		[_formatter setDateFormat:NSLocalizedString(@"MMM dd, yyyy", @"PTPhotoData")];
		
		_accessPhotoLibraryQueue = [[NSOperationQueue alloc] init];
		_accessPhotoLibraryQueue.maxConcurrentOperationCount = 1;
		
		_saveDataBaseQueue = [[NSOperationQueue alloc] init];
		_saveDataBaseQueue.maxConcurrentOperationCount = 1;
		
		_isEditable = NO;
		_isFirstAccess = YES;
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
	self = [super init];
	if (self)
	{
		NSLog(@"initWithCoder-PAAlbumDataController");
		
		_library = [[ALAssetsLibrary alloc] init];
		
		_allPhoto = [decoder decodeObjectForKey:@"PAAlbumDataControllerAllPhotos"];
		_albumDatas = [decoder decodeObjectForKey:@"PAAlbumDataControllerAlbumDatas"];
		_noDatePhotoDatas = [decoder decodeObjectForKey:@"PAAlbumDataControllerNoDatePhotoDatas"];
		
		_formatter = [[NSDateFormatter alloc] init];
		[_formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"US"]];
		[_formatter setDateFormat:NSLocalizedString(@"MMM dd, yyyy", @"PTPhotoData")];
		
		_accessPhotoLibraryQueue = [[NSOperationQueue alloc] init];
		_accessPhotoLibraryQueue.maxConcurrentOperationCount = 1;
		
		_saveDataBaseQueue = [[NSOperationQueue alloc] init];
		_saveDataBaseQueue.maxConcurrentOperationCount = 1;
		
		_isEditable = NO;
		_isFirstAccess = YES;
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
	[encoder encodeObject:_allPhoto forKey:@"PAAlbumDataControllerAllPhotos"];
	[encoder encodeObject:_albumDatas forKey:@"PAAlbumDataControllerAlbumDatas"];
	[encoder encodeObject:_noDatePhotoDatas forKey:@"PAAlbumDataControllerNoDatePhotoDatas"];
}

- (void)saveAlbumDataController
{
	if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusAuthorized) {
		NSData *tmpData = [NSKeyedArchiver archivedDataWithRootObject:self];
		NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		[userDefaults setObject:tmpData forKey:@"MainDataBase"];
	}
}

- (void)asyncSaveAlbumDataController
{
	if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusAuthorized) {
		[_saveDataBaseQueue cancelAllOperations];
		
		NSBlockOperation *operation = [[NSBlockOperation alloc] init];
		__weak NSBlockOperation *weakOperation = operation;
		
		[operation addExecutionBlock:^{
			if (weakOperation.isCancelled) {
				return;
			}
			NSData *tmpData = [NSKeyedArchiver archivedDataWithRootObject:self];
			if (weakOperation.isCancelled) {
				return;
			}
			NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
			[userDefaults setObject:tmpData forKey:@"MainDataBase"];
		}];
		
		[_saveDataBaseQueue addOperation:operation];
	}
}

- (void)addNotificationCenter
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessPhotoLibrary) name:ALAssetsLibraryChangedNotification object:nil];
}

- (void)accessPhotoLibrary
{
	if (_isSavingAlbum == YES) {
		return;
	}
	
	[_accessPhotoLibraryQueue cancelAllOperations];
	
	NSLog(@"AddAccessPhotoLibraryQueue");
	
	NSBlockOperation *operation = [[NSBlockOperation alloc] init];
    __weak NSBlockOperation *weakOperation = operation;

	[operation addExecutionBlock:^{
		if (weakOperation.isCancelled) {
			return;
		}
		
		NSLog(@"StartAccessPhotoLibrary");
		
		__block BOOL isOperation = YES;
		
		_isEditable = NO;
		
		while (_delegate == nil) {
			[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.005]];
		};
		
		[_delegate willAccessPhotoLibrary];
		
		for (PAPhotoData *photoData in _allPhoto.photoDatas) {
			photoData.isExist = NO;
		}
		
		ALAssetsGroupType assetsGroupType;
		NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		if ([userDefaults boolForKey:@"EnablePhotoStream"] == YES) {
			assetsGroupType = ALAssetsGroupAll;
		}
		else {
			assetsGroupType = ALAssetsGroupAlbum | ALAssetsGroupEvent | ALAssetsGroupFaces | ALAssetsGroupLibrary | ALAssetsGroupSavedPhotos;
		}
		
		[_library
		 enumerateGroupsWithTypes:assetsGroupType
		 usingBlock:^(ALAssetsGroup *group, BOOL *stop){
			 if (group != nil) {
				 [group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop){
					 if (asset) {
						 [self registerAsset:asset];
					 }
				 }];
			 }
			 else {
				 //すべての写真を読み込んだ後の処理
				 [_allPhoto sortPhotoDataByDate];
				 [_allPhoto checkAlbumData];
				 
				 NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
				 if ([userDefaults boolForKey:@"DontMakeByDate"] == NO) {
					 [self dividePhotoInAlbum];
				 }
				 
				 [self checkAlbumData];
				 [self sortAlbumDataByDate];
				 
				 [_delegate didAccessPhotoLibrary];
				 
				 _isEditable = YES;
				 _isFirstAccess = NO;
				 
				 isOperation = NO;
			 }
		 }
		 failureBlock:^(NSError *error){
		 }];
		
		while (isOperation == YES) {
			[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.005f]];
		}
		
		if (weakOperation.isCancelled == NO) {
			[self asyncSaveAlbumDataController];
		}
		
		NSLog(@"EndAccessPhotoLibrary");
	}];
	
	[_accessPhotoLibraryQueue addOperation:operation];
}

- (void)testAccessPhotoLibrary
{
	[_library enumerateGroupsWithTypes:ALAssetsGroupAlbum
										usingBlock:^(ALAssetsGroup *group, BOOL *stop){
										} failureBlock:nil];
}

- (void)registerAsset:(ALAsset *)newAsset
{
	NSUInteger newAssetURLHash = newAsset.defaultRepresentation.url.absoluteString.hash;
	
	//すべての写真 アセットの登録
	BOOL isExistAllPhotos = NO;
	for (PAPhotoData *photoData in _allPhoto.photoDatas) {
		if (newAssetURLHash == photoData.assetURLHash) {
			photoData.asset = newAsset;
			photoData.isExist = YES;
			isExistAllPhotos = YES;
			break;
		}
	}
	
	if (isExistAllPhotos == NO) {
		PAPhotoData *newPhotoData = [self newPhotoDataFromAsset:newAsset];
		[_allPhoto.photoDatas insertObject:newPhotoData atIndex:0];
	}
}

- (void)dividePhotoInAlbum
{
	for (PAPhotoData *photoData in _allPhoto.photoDatas.reverseObjectEnumerator) {
		//新規アセットの時
		if (photoData.isExistAllPhotos == NO) {
			//デフォルトの日付のアルバムがあるか
			BOOL isExistAlbum = NO;
			NSString *newDateString = [_formatter stringFromDate:photoData.date];
			NSDate *newDate = [_formatter dateFromString:newDateString];
			for (PAAlbumData *albumData in _albumDatas) {
				//条件
				//				if ([albumData.dateString isEqualToString:newDateString]) {
				if ([albumData.date isEqualToDate:newDate]) {
					NSDate *endDate = [newDate dateByAddingTimeInterval:24 * 60 * 60 - 1];
					//					NSString *endDateString = [_formatter stringFromDate:endDate];
					//					if ([albumData.endDateString isEqualToString:endDateString]) {
					if ([albumData.endDate isEqualToDate:endDate]) {
						//あれば登録
						[albumData.photoDatas insertObject:photoData atIndex:0];
						isExistAlbum = YES;
						break;
					}
				}
			}
			if (isExistAlbum == NO) {
				PAAlbumData *newAlbumData = [self newAlbumDataFromPhotoData:photoData];
				[_albumDatas insertObject:newAlbumData atIndex:0];
			}
			
			photoData.isExistAllPhotos = YES;
		}
	}
}

- (PAPhotoData *)newPhotoDataFromAsset:(ALAsset *)asset
{
	PAPhotoData *newPhotoData = [[PAPhotoData alloc] init];
	newPhotoData.asset = asset;
	newPhotoData.assetURL = asset.defaultRepresentation.url;
	newPhotoData.assetURLHash = asset.defaultRepresentation.url.absoluteString.hash;
	if([[asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]) {
		newPhotoData.isVideo = YES;
	}
	newPhotoData.date = [asset valueForProperty:ALAssetPropertyDate];
	newPhotoData.location = [asset valueForProperty:ALAssetPropertyLocation];
	newPhotoData.isExist = YES;
	newPhotoData.isExistAllPhotos = NO;
	newPhotoData.isNew = YES;
	
	return newPhotoData;
}

- (PAAlbumData *)newAlbumDataFromPhotoData:(PAPhotoData *)photoData
{
	PAAlbumData *newAlbumData = [[PAAlbumData alloc] init];
	[newAlbumData.photoDatas addObject:photoData];
	NSString *newAlbumDataDateString = [_formatter stringFromDate:photoData.date];
	NSDate *newAlbumDataDate = [_formatter dateFromString:newAlbumDataDateString];
	newAlbumData.date = newAlbumDataDate;
	newAlbumData.dateString = newAlbumDataDateString;
	NSDate *newAlbumDataEndDate = [newAlbumDataDate dateByAddingTimeInterval:24 * 60 * 60 - 1];
	newAlbumData.endDate = newAlbumDataEndDate;
	newAlbumData.endDateString = [_formatter stringFromDate:newAlbumDataEndDate];
	newAlbumData.isNew = YES;
	newAlbumData.createDate = [NSDate date];
	newAlbumData.isOpened = NO;
	
	return newAlbumData;
}

- (void)sortAlbumDataByDate
{
	[_albumDatas sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
		PAAlbumData *albumData1 = (PAAlbumData *)obj1;
		PAAlbumData *albumData2 = (PAAlbumData *)obj2;
		
		if (albumData1.date == nil) {
			return NSOrderedAscending;
		}
		else {
			return [albumData2.date compare:albumData1.date];
		}
	}];
}

- (void)checkAlbumDataController
{
	[_allPhoto checkAlbumData];
	[self checkAlbumData];
}

//- (void)checkAllPhotos
//{
//	if (_allPhoto.photoDatas.count == 0) {
//		return;
//	}
//
//	PAPhotoData *firstPhotoData = [_allPhoto.photoDatas objectAtIndex:0];
//	_allPhoto.dateString = [_formatter stringFromDate:firstPhotoData.date];
//	_allPhoto.date = [_formatter dateFromString:_allPhoto.dateString];
//	NSDate *newAlbumDataEndDate = [_allPhoto.date dateByAddingTimeInterval:_tmpTimeInterval];
//	_allPhoto.endDate = newAlbumDataEndDate;
//	_allPhoto.endDateString = [_formatter stringFromDate:newAlbumDataEndDate];
//	_allPhoto.countOfPlaces = 0;
//	for (PAPhotoData *photoData in [_allPhoto.photoDatas reverseObjectEnumerator]) {
//		if (photoData.asset == nil || photoData.isExist == NO) {
//			[_allPhoto.photoDatas removeObject:photoData];
//		}
//		else {
//			NSString *newAlbumDataDateString = [_formatter stringFromDate:photoData.date];
//			NSDate *newAlbumDataDate = [_formatter dateFromString:newAlbumDataDateString];
//			if ([newAlbumDataDate compare:_allPhoto.date] == NSOrderedAscending) {
//				_allPhoto.date = newAlbumDataDate;
//				_allPhoto.dateString = newAlbumDataDateString;
//			}
//			else if ([newAlbumDataDate compare:_allPhoto.endDate] == NSOrderedDescending) {
//				_allPhoto.endDate = newAlbumDataDate;
//				_allPhoto.endDateString = newAlbumDataDateString;
//			}
//
//			if (photoData.location != nil) {
//				_allPhoto.countOfPlaces++;
//			}
//		}
//	}
//}

- (void)checkAlbumData
{
	for (PAAlbumData *albumData in _albumDatas) {
		[albumData checkAlbumData];
	}
}

- (void)checkAlbumIsNew
{
	//３日間
	NSDate *beforeDate = [[NSDate date] dateByAddingTimeInterval:-24 * 60 * 60 * 3];
	
	for (PAAlbumData *albumData in _albumDatas) {
		if (albumData.isNew == YES) {
			if (albumData.isOpened == YES) {
				albumData.isNew = NO;
			}
			else {
				//３日より前
				if ([albumData.createDate timeIntervalSinceDate:beforeDate] < 0) {
					albumData.isNew = NO;
				}
			}
		}
	}
}

- (PAAlbumData *)combinedAlbumDataFromAlbumDatas:(NSArray *)albumDatas
{
	PAAlbumData *newAlbumData = [[PAAlbumData alloc] init];
	NSUInteger count = 0;
	for (PAAlbumData *albumData in albumDatas) {
		if (count == 0) {
			newAlbumData.title = albumData.title;
			newAlbumData.date = albumData.date;
			newAlbumData.dateString = albumData.dateString;
			newAlbumData.endDate = albumData.endDate;
			newAlbumData.endDateString = albumData.endDateString;
			newAlbumData.thumbnailAssetURL = nil;
			newAlbumData.thumbnailIndex = 0;
		}
		else {
			if (albumData.title != nil) {
				if (newAlbumData.title != nil) {
					newAlbumData.title = [newAlbumData.title stringByAppendingFormat:@" & %@",albumData.title];
				}
				else {
					newAlbumData.title = albumData.title;
				}
			}
		}
		
		for (PAPhotoData *photoData in albumData.photoDatas) {
			[newAlbumData.photoDatas addObject:photoData];
			
			NSString *newAlbumDataDateString = [_formatter stringFromDate:photoData.date];
			NSDate *newAlbumDataDate = [_formatter dateFromString:newAlbumDataDateString];
			if ([newAlbumDataDate compare:newAlbumData.date] == NSOrderedAscending) {
				newAlbumData.date = newAlbumDataDate;
				newAlbumData.dateString = newAlbumDataDateString;
			}
			else if ([newAlbumDataDate compare:newAlbumData.endDate] == NSOrderedDescending) {
				newAlbumData.endDate = newAlbumDataDate;
				newAlbumData.endDateString = newAlbumDataDateString;
			}
		}
		
		count++;
	}
	
	[newAlbumData checkAlbumData];
	
	return newAlbumData;
}

- (void)resetAlbumDatasWithDivide:(BOOL)isDivide
{
	[_albumDatas removeAllObjects];
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	if ([userDefaults boolForKey:@"DontMakeByDate"] == NO) {
		for (PAPhotoData *photoData in _allPhoto.photoDatas) {
			photoData.isExistAllPhotos = NO;
		}
		
		[self dividePhotoInAlbum];
	}
}

- (void)saveAlbumDataToCameraRoll:(PAAlbumData *)albumData
{
	_isSavingAlbum = YES;
	
	__block BOOL isSaving = YES;
	
	[_library enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
		if (*stop == NO) {
			if (group) {
				if ([[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:albumData.title]) {
					NSMutableArray *tmpArray = [albumData.photoDatas mutableCopy];
					
					[group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
						if (result) {
							for (PAPhotoData *tmpPhotoData in tmpArray.reverseObjectEnumerator) {
								if ([result.defaultRepresentation.url isEqual:tmpPhotoData.asset.defaultRepresentation.url]) {
									[tmpArray removeObject:tmpPhotoData];
								}
							}
						}
						else {
							int countOfPhotos = 0;
							int countOfVideos = 0;
							for (PAPhotoData *tmpPhotoData in tmpArray) {
								[group addAsset:tmpPhotoData.asset];
								if ([[tmpPhotoData.asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]) {
									countOfVideos++;
								}
								else {
									countOfPhotos++;
								}
							}
							
							NSString *title = NSLocalizedString(@"Saving this album was completed.", @"PTAlbumViewController");
							NSString *message;
							if (countOfPhotos > 0 && countOfVideos > 0) {
								message = NSLocalizedString(@"Already this album exists!\nAdded %d photos and %d videos.", @"PTAlbumViewController");
								message = [NSString stringWithFormat:message, countOfPhotos, countOfVideos];
							}
							else if (countOfPhotos > 0) {
								message = NSLocalizedString(@"Already this album exists!\nAdded %d photos.", @"PTAlbumViewController");
								message = [NSString stringWithFormat:message, countOfPhotos];
							}
							else if (countOfVideos > 0) {
								message = NSLocalizedString(@"Already this album exists!\nAdded %d videos.", @"PTAlbumViewController");
								message = [NSString stringWithFormat:message, countOfVideos];
							}
							else {
								message = NSLocalizedString(@"Already this album exists!", @"PTAlbumViewController");
							}
							NSString *ok = NSLocalizedString(@"OK", @"PTAlbumViewController");
							dispatch_async(dispatch_get_main_queue(), ^{
								UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:ok, nil];
								[alertView show];
								
								isSaving = NO;
							});
							*stop = YES;
						}
					}];
					*stop = YES;
				}
			}
			else {
				[_library
				 addAssetsGroupAlbumWithName:albumData.title
				 resultBlock:^(ALAssetsGroup *group)
				 {
					 int countOfPhotos = 0;
					 int countOfVideos = 0;
					 for (PAPhotoData *photoData in albumData.photoDatas) {
						 [group addAsset:photoData.asset];
						 
						 if (photoData.isVideo == YES) {
							 countOfVideos++;
						 }
						 else {
							 countOfPhotos++;
						 }
					 }
					 
					 NSString *title = NSLocalizedString(@"Saving this album was completed.", @"PTAlbumViewController");
					 NSString *message;
					 if (countOfPhotos > 0 && countOfVideos > 0) {
						 message = NSLocalizedString(@"Created new album!\nAdded %d photos and %d videos.", @"PTAlbumViewController");
						 message = [NSString stringWithFormat:message, countOfPhotos, countOfVideos];
					 }
					 else if (countOfPhotos > 0) {
						 message = NSLocalizedString(@"Created new album!\nAdded %d photos.", @"PTAlbumViewController");
						 message = [NSString stringWithFormat:message, countOfPhotos];
					 }
					 else if (countOfVideos > 0) {
						 message = NSLocalizedString(@"Created new album!\nAdded %d videos.", @"PTAlbumViewController");
						 message = [NSString stringWithFormat:message, countOfVideos];
					 }
					 else {
						 message = NSLocalizedString(@"Created new album!", @"PTAlbumViewController");
					 }
					 NSString *ok = NSLocalizedString(@"OK", @"PTTimelineViewController");
					 dispatch_async(dispatch_get_main_queue(), ^{						 
						 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:ok, nil];
						 [alertView show];
						 
						 isSaving = NO;
					 });
				 }
				 failureBlock:^(NSError *error)
				 {
				 }];
			}
		}
	} failureBlock:^(NSError *error) {
	}];
	
	while (isSaving == YES) {
		[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
	}
	
	_isSavingAlbum = NO;
	
	[self accessPhotoLibrary];
}

@end


@interface PAAlbumData ()
{
	NSDateFormatter *_formatter;
}

@end

@implementation PAAlbumData

- (id)init
{
	self = [super init];
	if (self != nil)
	{
		_photoDatas = [[NSMutableArray alloc] init];
		_date = nil;
		_dateString = nil;
		_endDate = nil;
		_endDateString = nil;
		_displayDateString = nil;
		_countOfPhotos = 0;
		_countOfVideos = 0;
		_displayCountString = nil;
		_title = nil;
		_displayTitleString = nil;
		_comment = nil;
		_thumbnailIndex = 0;
		_thumbnailAssetURL = nil;
		_isNew = NO;
		_createDate = nil;
		_isOpened = NO;
		_showDateInAlbumView = PTShowDateInAlbumViewAuto;
		
		_formatter = [[NSDateFormatter alloc] init];
		[_formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"US"]];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
	self = [super init];
	if (self)
	{
		_photoDatas = [decoder decodeObjectForKey:@"PAAlbumDataPhotoDatas"];
		_date = [decoder decodeObjectForKey:@"PAAlbumDataDate"];
		_dateString = [decoder decodeObjectForKey:@"PAAlbumDataDateString"];
		_endDate = [decoder decodeObjectForKey:@"PAAlbumDataEndDate"];
		_endDateString = [decoder decodeObjectForKey:@"PAAlbumDataEndDateString"];
		_displayDateString = [decoder decodeObjectForKey:@"PTAlbumDataDisplayDateString"];
		_countOfPhotos = [decoder decodeIntegerForKey:@"PAAlbumDataCountOfPhotos"];
		_countOfVideos = [decoder decodeIntegerForKey:@"PAAlbumDataCountOfVideos"];
		_displayCountString = [decoder decodeObjectForKey:@"PTAlbumDataDisplayCountString"];
		_title = [decoder decodeObjectForKey:@"PAAlbumDataTitle"];
		_displayTitleString = [decoder decodeObjectForKey:@"PTAlbumDataDisplayTitleString"];
		_comment = [decoder decodeObjectForKey:@"PAAlbumDataComment"];
		_thumbnailIndex = [decoder decodeIntegerForKey:@"PAAlbumDataThumbnailIndex"];
		_thumbnailAssetURL = [decoder decodeObjectForKey:@"PAAlbumDataThumbnailAssetURL"];
		_isNew = [decoder decodeBoolForKey:@"PAAlbumDataIsNew"];
		_createDate = [decoder decodeObjectForKey:@"PAAlbumDataCreateDate"];
		_isOpened = [decoder decodeBoolForKey:@"PAAlbumDataIsOpened"];
		_showDateInAlbumView = [decoder decodeIntegerForKey:@"PAAlbumDataShowDateInAlbumView"];
		
		_formatter = [[NSDateFormatter alloc] init];
		[_formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"US"]];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
	[encoder encodeObject:_photoDatas forKey:@"PAAlbumDataPhotoDatas"];
	[encoder encodeObject:_date forKey:@"PAAlbumDataDate"];
	[encoder encodeObject:_dateString forKey:@"PAAlbumDataDateString"];
	[encoder encodeObject:_endDate forKey:@"PAAlbumDataEndDate"];
	[encoder encodeObject:_endDateString forKey:@"PAAlbumDataEndDateString"];
	[encoder encodeObject:_displayDateString forKey:@"PTAlbumDataDisplayDateString"];
	[encoder encodeObject:_displayCountString forKey:@"PTAlbumDataDisplayCountString"];
	[encoder encodeInteger:_countOfPhotos forKey:@"PAAlbumDataCountOfPhotos"];
	[encoder encodeInteger:_countOfVideos forKey:@"PAAlbumDataCountOfVideos"];
	[encoder encodeObject:_title forKey:@"PAAlbumDataTitle"];
	[encoder encodeObject:_displayTitleString forKey:@"PTAlbumDataDisplayTitleString"];
	[encoder encodeObject:_comment forKey:@"PAAlbumDataComment"];
	[encoder encodeInteger:_thumbnailIndex forKey:@"PAAlbumDataThumbnailIndex"];
	[encoder encodeObject:_thumbnailAssetURL forKey:@"PAAlbumDataThumbnailAssetURL"];
	[encoder encodeBool:_isNew forKey:@"PAAlbumDataIsNew"];
	[encoder encodeObject:_createDate forKey:@"PAAlbumDataCreateDate"];
	[encoder encodeBool:_isOpened forKey:@"PAAlbumDataIsOpened"];
	[encoder encodeInteger:_showDateInAlbumView forKey:@"PAAlbumDataShowDateInAlbumView"];
}

- (void)checkAlbumData
{
	if (_photoDatas.count > 0) {
		PAPhotoData *firstPhotoData = [_photoDatas objectAtIndex:0];
		[_formatter setDateFormat:NSLocalizedString(@"MMM dd, yyyy", @"PTPhotoData")];
		_dateString = [_formatter stringFromDate:firstPhotoData.date];
		_date = [_formatter dateFromString:_dateString];
		NSDate *newAlbumDataEndDate = [_date dateByAddingTimeInterval:24 * 60 * 60 - 1];
		_endDate = newAlbumDataEndDate;
		_endDateString = [_formatter stringFromDate:newAlbumDataEndDate];
		_displayDateString = nil;
		_countOfPhotos = 0;
		_countOfVideos = 0;
		_thumbnailIndex = 0;
		for (PAPhotoData *photoData in _photoDatas.reverseObjectEnumerator) {
			if (photoData.asset == nil || photoData.isExist == NO) {
				[_photoDatas removeObject:photoData];
			}
			else {
				NSString *newAlbumDataDateString = [_formatter stringFromDate:photoData.date];
				NSDate *newAlbumDataDate = [_formatter dateFromString:newAlbumDataDateString];
				if ([newAlbumDataDate compare:_date] == NSOrderedAscending) {
					_date = newAlbumDataDate;
					_dateString = newAlbumDataDateString;
				}
				else if ([newAlbumDataDate compare:_endDate] == NSOrderedDescending) {
					_endDate = newAlbumDataDate;
					_endDateString = newAlbumDataDateString;
				}
				
				if (photoData.isVideo) {
					_countOfVideos++;
				}
				else {
					_countOfPhotos++;
				}
				
				if (_thumbnailAssetURL != nil) {
					if ([_thumbnailAssetURL.absoluteString isEqualToString:photoData.assetURL.absoluteString]) {
						_thumbnailIndex = [_photoDatas indexOfObject:photoData];
					}
				}
			}
		}
	}
	
	if (_photoDatas.count == 0) {
		_date = nil;
		_dateString = nil;
		_endDate = nil;
		_endDateString = nil;
		_countOfPhotos = 0;
		_countOfVideos = 0;
		_comment = nil;
		_thumbnailIndex = 0;
		_thumbnailAssetURL = nil;
		_isNew = NO;
	}
	
	if (_title != nil && [@"" isEqualToString:_title]) {
		_title = nil;
	}
	if (_title == nil) {
		NSString *untitledAlbum = NSLocalizedString(@"Untitled album", @"PTTimelineViewController");
		_displayTitleString = untitledAlbum;
	}
	else {
		_displayTitleString = _title;
	}
	
	_displayDateString = [self myDisplayDateString];
	
	_displayCountString = [PAAlbumData displayCountString:_photoDatas];
}

- (NSString *)myDisplayDateString
{
	NSString *displayDateString;
	
	if (_dateString != nil && _endDateString != nil) {
		if ([_dateString isEqualToString:_endDateString] == NO) {
			[_formatter setDateFormat:NSLocalizedString(@"yyyy", @"PTPhotoData")];
			NSString *tmpDateString = [_formatter stringFromDate:_date];
			NSString *tmpEndDateString = [_formatter stringFromDate:_endDate];
			if ([tmpDateString isEqualToString:tmpEndDateString]) {
				if ([@"MMM dd" isEqualToString:NSLocalizedString(@"MMM dd", @"PAPhotoData")]) {
					[_formatter setDateFormat:NSLocalizedString(@"MMM dd", @"PTPhotoData")];
				}
				else {
					[_formatter setDateFormat:NSLocalizedString(@"MMM dd, yyyy", @"PAPhotoData")];
				}
				NSString *dateString = [_formatter stringFromDate:_date];
				if ([@"MMM dd" isEqualToString:NSLocalizedString(@"MMM dd", @"PAPhotoData")]) {
					[_formatter setDateFormat:NSLocalizedString(@"MMM dd, yyyy", @"PAPhotoData")];
				}
				else {
					[_formatter setDateFormat:NSLocalizedString(@"MMM dd", @"PTPhotoData")];
				}
				NSString *endDateString = [_formatter stringFromDate:_endDate];
				displayDateString = [NSString stringWithFormat:@"%@ - %@",  dateString, endDateString];
			}
			else {
				[_formatter setDateFormat:NSLocalizedString(@"MMM dd, yyyy", @"PTPhotoData")];
				NSString *dateString = [_formatter stringFromDate:_date];
				NSString *endDateString = [_formatter stringFromDate:_endDate];
				displayDateString = [NSString stringWithFormat:@"%@ - %@", dateString, endDateString];
			}
		}
		else {
			[_formatter setDateFormat:NSLocalizedString(@"MMM dd, yyyy", @"PTPhotoData")];
			NSString *dateString = [_formatter stringFromDate:_date];
			displayDateString = dateString;
		}
	}
	else {
		displayDateString = NSLocalizedString(@"Not dated", @"PAPhotoData");
	}
	
	return displayDateString;
}

+ (NSString *)displayCountString:(NSMutableArray *)photoDatas
{
	NSString *displayCountString;
	
	NSInteger countOfPhotos = 0;
	NSInteger countOfVideos = 0;
	for (PAPhotoData *photoData in photoDatas) {
		if (photoData.isVideo == YES) {
			countOfVideos++;
		}
		else {
			countOfPhotos++;
		}
	}
	
	if (countOfPhotos == 1 && countOfVideos == 1) {
		NSString *photoAndVideo = NSLocalizedString(@"%d Photo, %d Video", @"PAPhotoData");
		displayCountString = [NSString stringWithFormat:photoAndVideo, countOfPhotos, countOfVideos];
	}
	else if (countOfPhotos > 1 && countOfVideos == 1) {
		NSString *photosAndVideo = NSLocalizedString(@"%d Photos, %d Video", @"PAPhotoData");
		displayCountString = [NSString stringWithFormat:photosAndVideo, countOfPhotos, countOfVideos];
	}
	else if (countOfPhotos == 1 && countOfVideos > 1) {
		NSString *photoAndVideos = NSLocalizedString(@"%d Photo, %d Videos", @"PAPhotoData");
		displayCountString = [NSString stringWithFormat:photoAndVideos, countOfPhotos, countOfVideos];
	}
	else if (countOfPhotos > 1 && countOfVideos > 1) {
		NSString *photosAndVideos = NSLocalizedString(@"%d Photos, %d Videos", @"PAPhotoData");
		displayCountString = [NSString stringWithFormat:photosAndVideos, countOfPhotos, countOfVideos];
	}
	else if (countOfPhotos == 1) {
		NSString *photo = NSLocalizedString(@"%d Photo", @"PAPhotoData");
		displayCountString = [NSString stringWithFormat:photo, countOfPhotos];
	}
	else if (countOfPhotos > 1) {
		NSString *photos = NSLocalizedString(@"%d Photos", @"PAPhotoData");
		displayCountString = [NSString stringWithFormat:photos, countOfPhotos];
	}
	else if (countOfVideos == 1) {
		NSString *video = NSLocalizedString(@"%d Video", @"PAPhotoData");
		displayCountString = [NSString stringWithFormat:video, countOfVideos];
	}
	else if (countOfVideos > 1) {
		NSString *videos = NSLocalizedString(@"%d Videos", @"PAPhotoData");
		displayCountString = [NSString stringWithFormat:videos, countOfVideos];
	}
	else {
		NSString *noPhotos = NSLocalizedString(@"No Photos", @"PAPhotoData");
		displayCountString = noPhotos;
	}
	
	return displayCountString;
}

- (void)sortPhotoDataByDate
{
	[_photoDatas sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
		PAPhotoData *photoData1 = (PAPhotoData *)obj1;
		PAPhotoData *photoData2 = (PAPhotoData *)obj2;
		return [photoData2.date compare:photoData1.date];
	}];
}

- (void)sortPhotoDataByDateReverse
{
	[_photoDatas sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
		PAPhotoData *photoData1 = (PAPhotoData *)obj1;
		PAPhotoData *photoData2 = (PAPhotoData *)obj2;
		if ([photoData2.date compare:photoData1.date] == NSOrderedAscending) {
			return NSOrderedDescending;
		}
		else if ([photoData2.date compare:photoData1.date] == NSOrderedDescending) {
			return NSOrderedAscending;
		}
		else {
			return NSOrderedSame;
		}
	}];
}

- (NSMutableArray *)dividePhotosInAlbumByDate
{
	NSMutableArray *dividedAlbum = [NSMutableArray array];
	
	[_formatter setDateFormat:NSLocalizedString(@"MMM dd, yyyy", @"PTPhotoData")];
	
	for (PAPhotoData *photoData in _photoDatas) {
		NSString *dateString = [_formatter stringFromDate:photoData.date];
		if (dividedAlbum.count > 0) {
			NSMutableArray *photoDatas = [dividedAlbum lastObject];
			PAPhotoData *tmpPhotoData = [photoDatas objectAtIndex:0];
			NSString *tmpDateString = [_formatter stringFromDate:tmpPhotoData.date];
			if ([tmpDateString isEqualToString:dateString]) {
				[photoDatas addObject:photoData];
			}
			else {
				NSMutableArray *newPhotoDatas = [NSMutableArray arrayWithObject:photoData];
				[dividedAlbum addObject:newPhotoDatas];
			}
		}
		else {
			NSMutableArray *newPhotoDatas = [NSMutableArray arrayWithObject:photoData];
			[dividedAlbum addObject:newPhotoDatas];
		}
	}
	
	return dividedAlbum;
}


@end


@implementation PAPhotoData

- (id)init
{
	self = [super init];
	if (self != nil)
	{
		_asset = nil;
		_assetURL = nil;
		_assetURLHash = 0;
		_isVideo = NO;
		_date = nil;
		_isNew = NO;
		_isExist = NO;
		_isExistAllPhotos = NO;
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
	self = [super init];
	if (self)
	{
		_asset = nil;
		_assetURL = [decoder decodeObjectForKey:@"PAPhotoDataAssetURL"];
		_assetURLHash = [decoder decodeIntegerForKey:@"PAPhotoDataAssetURLHash"];
		_isVideo = [decoder decodeBoolForKey:@"PAPhotoDataIsVideo"];
		_date = [decoder decodeObjectForKey:@"PAPhotoDataDate"];
		_location = [decoder decodeObjectForKey:@"PAPhotoDataLocation"];
		_isNew = [decoder decodeBoolForKey:@"PAPhotoDataIsNew"];
		_isExist = YES;
		_isExistAllPhotos = YES;
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
	[encoder encodeObject:_assetURL forKey:@"PAPhotoDataAssetURL"];
	[encoder encodeInteger:_assetURLHash forKey:@"PAPhotoDataAssetURLHash"];
	[encoder encodeBool:_isVideo forKey:@"PAPhotoDataIsVideo"];
	[encoder encodeObject:_date forKey:@"PAPhotoDataDate"];
	[encoder encodeObject:_location forKey:@"PAPhotoDataLocation"];
	[encoder encodeBool:_isNew forKey:@"PAPhotoDataIsNew"];
}

- (UIImage *)makeThumbnailImage:(NSInteger)imageSize
{
	ALAssetRepresentation *rep = _asset.defaultRepresentation;
	CFNumberRef thumbnailSize = CFNumberCreate(NULL, kCFNumberIntType, &imageSize);
	
	CFStringRef myKeys[4];
	CFTypeRef myValues[4];
	// Set up the thumbnail options.
	myKeys[0] = kCGImageSourceCreateThumbnailWithTransform;
	myValues[0] = (CFTypeRef)kCFBooleanFalse;
	myKeys[1] = kCGImageSourceCreateThumbnailFromImageIfAbsent;
	myValues[1] = (CFTypeRef)kCFBooleanTrue;
	myKeys[2] = kCGImageSourceThumbnailMaxPixelSize;
	myValues[2] = (CFTypeRef)thumbnailSize;
	myKeys[3] = kCGImageSourceCreateThumbnailFromImageAlways;
	myValues[3] = (CFTypeRef)kCFBooleanTrue;
	
	CFDictionaryRef myOptions = CFDictionaryCreate(NULL, (const void **) myKeys,
												   (const void **) myValues, 4,
												   &kCFTypeDictionaryKeyCallBacks,
												   & kCFTypeDictionaryValueCallBacks);
	CGImageRef decompressedImageRef = [rep CGImageWithOptions:(__bridge NSDictionary *)(myOptions)];
	CFRelease(thumbnailSize);
	CFRelease(myOptions);
	
	UIImage *decompressedImage = [UIImage imageWithCGImage:decompressedImageRef scale:1.0f orientation:(UIImageOrientation)rep.orientation];
	
	return decompressedImage;
}

- (UIImage *)thumbnail
{
	CGImageRef imageRef = _asset.thumbnail;
	if (imageRef != NULL) {
		return [UIImage imageWithCGImage:imageRef];
	}
	else {
		return nil;
	}
}

- (UIImage *)aspectRatioThumbnail
{
	CGImageRef imageRef = _asset.aspectRatioThumbnail;
	if (imageRef != NULL) {
		return [UIImage imageWithCGImage:imageRef];
	}
	else {
		return nil;
	}
}

- (UIImage *)fullScreenImage
{
	return [UIImage imageWithCGImage:_asset.defaultRepresentation.fullScreenImage];
}

- (UIImage *)fullResolutionImage
{
	return [UIImage imageWithCGImage:_asset.defaultRepresentation.fullResolutionImage];
}

- (CGSize)dimensions
{
	return _asset.defaultRepresentation.dimensions;
}

- (UIImage *)makeAlbumCoverThumbnail:(UIImage *)image
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

- (NSString *)dateFullString
{
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"US"]];
	[dateFormatter setDateFormat:NSLocalizedString(@"MMM dd, yyyy", @"PTPhotoData")];
	return [dateFormatter stringFromDate:_date];
}

- (NSString *)dateShortString
{
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"US"]];
	[dateFormatter setDateFormat:NSLocalizedString(@"MMM dd", @"PAPhotoData")];
	return [dateFormatter stringFromDate:_date];
}

- (NSString *)dateFullStringWithHour
{
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"US"]];
	[dateFormatter setDateFormat:NSLocalizedString(@"MMM dd, yyyy HH:mm", @"PTPhotoData")];
	return [dateFormatter stringFromDate:_date];
}

@end
