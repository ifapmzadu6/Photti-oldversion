//
//  PAPhotoData.h
//  PhotoAlbum
//
//  Created by Karijuku Keisuke on 2013/04/02.
//  Copyright (c) 2013年 Keisuke Karijuku. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MapKit/MapKit.h>
#import <ImageIO/ImageIO.h>

@class PAAlbumData, PAPhotoData;

@protocol PAAlbumDataControllerDelegate <NSObject>

- (void)willAccessPhotoLibrary;
- (void)didAccessPhotoLibrary;

@end


@interface PAAlbumDataController : NSObject

@property (nonatomic) id<PAAlbumDataControllerDelegate> delegate;

@property (strong, nonatomic) ALAssetsLibrary *library;

@property (nonatomic) PAAlbumData *allPhoto;
@property (nonatomic) NSMutableArray *albumDatas;
@property (nonatomic) NSMutableArray *noDatePhotoDatas;

@property (nonatomic) BOOL isEditable;
@property (nonatomic) BOOL isFirstAccess;

- (void)saveAlbumDataController;
- (void)asyncSaveAlbumDataController;

- (void)addNotificationCenter;

- (void)accessPhotoLibrary;

- (void)testAccessPhotoLibrary;

- (PAPhotoData *)newPhotoDataFromAsset:(ALAsset *)asset;
- (PAAlbumData *)newAlbumDataFromPhotoData:(PAPhotoData *)photoData;

- (PAAlbumData *)combinedAlbumDataFromAlbumDatas:(NSArray *)albumDatas;

- (void)sortAlbumDataByDate;

- (void)checkAlbumDataController;

- (void)checkAlbumIsNew;

- (void)resetAlbumDatasWithDivide:(BOOL)isDivide;

- (void)saveAlbumDataToCameraRoll:(PAAlbumData *)albumData;

@end


typedef enum _PTShowDateInAlbumView {
	PTShowDateInAlbumViewAuto = 0,
	PTShowDateInAlbumViewYes = 1,
	PTShowDateInAlbumViewNo = 2
} PTShowDateInAlbumView;

@interface PAAlbumData : NSObject

@property (nonatomic) NSMutableArray *photoDatas;
@property (nonatomic) NSDate *date;
@property (nonatomic) NSString *dateString;
@property (nonatomic) NSDate *endDate;
@property (nonatomic) NSString *endDateString;
@property (nonatomic) NSString *displayDateString;
@property (nonatomic) NSInteger countOfPhotos;
@property (nonatomic) NSInteger countOfVideos;
@property (nonatomic) NSString *displayCountString;
@property (nonatomic) NSString *title;
@property (nonatomic) NSString *displayTitleString;
@property (nonatomic) NSString *comment;
@property (nonatomic) NSInteger thumbnailIndex;
@property (nonatomic) NSURL *thumbnailAssetURL;
@property (nonatomic) BOOL isNew;
@property (nonatomic) NSDate *createDate;
@property (nonatomic) BOOL isOpened;
@property (nonatomic) PTShowDateInAlbumView showDateInAlbumView;

- (void)checkAlbumData;

+ (NSString *)displayCountString:(NSMutableArray *)photoDatas;

- (void)sortPhotoDataByDate;
- (void)sortPhotoDataByDateReverse;

- (NSMutableArray *)dividePhotosInAlbumByDate;

@end

@interface PAPhotoData : NSObject

@property (nonatomic) ALAsset *asset;
@property (nonatomic) NSURL *assetURL;
@property (nonatomic) NSUInteger assetURLHash;
@property (nonatomic) BOOL isVideo;
@property (nonatomic) NSDate *date;
@property (nonatomic) CLLocation *location;
@property (nonatomic) BOOL isNew;
@property (nonatomic) BOOL isExist;
@property (nonatomic) BOOL isExistAllPhotos;

- (UIImage *)makeThumbnailImage:(NSInteger)imageSize;
- (UIImage *)thumbnail;
- (UIImage *)aspectRatioThumbnail;
- (UIImage *)fullScreenImage;
- (UIImage *)fullResolutionImage;
- (CGSize)dimensions;

- (UIImage *)makeAlbumCoverThumbnail:(UIImage *)image;

- (NSString *)dateFullString;
- (NSString *)dateShortString;
- (NSString *)dateFullStringWithHour;

@end
