//
//  ImageScrollView.h
//  PhotoTimeline
//
//  Created by Karijuku Keisuke on 2013/04/03.
//  Copyright (c) 2013年 Keisuke Karijuku. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "PAPhotoData.h"

@protocol myDelegate <NSObject>

- (void)zoomingWithSender:(id)sender;
- (void)playMovieButtonAction;
- (void)singleTap;

@end

@interface ImageScrollView : UIScrollView

@property (nonatomic) NSUInteger index;

- (void)initDisplayViewWithThumbnailImageRef:(CGImageRef)thumbnailImageRef isVideo:(BOOL)isVideo size:(CGSize)dimensions orientation:(ALAssetOrientation)orientation;
- (void)displayNomalImage:(UIImage *)image;
- (void)setFullResolutionImage:(UIImage *)image;

- (void)zoomViewFromSuperview;

- (void)desableSingleTap;

@property (strong, nonatomic) id<myDelegate> myDelegate;

@property (nonatomic) BOOL isFullResolution;


@end
