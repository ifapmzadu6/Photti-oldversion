//
//  PTImageView.h
//  PhotoTimeline
//
//  Created by Karijuku Keisuke on 2013/06/28.
//  Copyright (c) 2013年 Keisuke Karijuku. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <CommonCrypto/CommonDigest.h>
#import <SDWebImageManager.h>


@interface PTImageView : UIImageView

- (void)loadImageFromAsset:(ALAsset *)asset thumbnail:(UIImage *)thumbnail;

- (void)DisplayNoPhotos;

- (void)setImageNil;

@end
