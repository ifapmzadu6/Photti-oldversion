//
//  PTImageView.m
//  PhotoTimeline
//
//  Created by Karijuku Keisuke on 2013/06/28.
//  Copyright (c) 2013年 Keisuke Karijuku. All rights reserved.
//

#import "PTImageView.h"

@interface PTImageView ()
{
	NSOperationQueue *_queue;
}

@end

@implementation PTImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)loadImageFromAsset:(ALAsset *)asset thumbnail:(UIImage *)thumbnail
{
	if (_queue == nil) {
		_queue = [[NSOperationQueue alloc] init];
		_queue.maxConcurrentOperationCount = 1;
	}
	else {
		[_queue cancelAllOperations];
	}
	
	UIImage *thumbnailImage = thumbnail;
	if ([NSThread isMainThread]) {
		self.image = thumbnailImage;
	}
	else {
		dispatch_async(dispatch_get_main_queue(), ^{
			self.image = thumbnailImage;
		});
	}
	
	NSBlockOperation *operation = [[NSBlockOperation alloc] init];
    __weak NSBlockOperation *weakOperation = operation;
    [operation addExecutionBlock:^{
		if (weakOperation.isCancelled == YES) return;
		
		if (thumbnailImage == nil) {
			dispatch_async(dispatch_get_main_queue(), ^{
				self.image = nil;
				[self setNeedsDisplay];
			});
			
			return;
		}
		
		NSData *data = UIImageJPEGRepresentation(thumbnailImage, 1.0f);
		unsigned char result[16];
		CC_MD5(data.bytes, data.length, result );
		NSString *md5 = [NSString stringWithFormat:
						 @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
						 result[0], result[1], result[2], result[3],
						 result[4], result[5], result[6], result[7],
						 result[8], result[9], result[10], result[11],
						 result[12], result[13], result[14], result[15]
						 ];
		
		if (weakOperation.isCancelled == YES) return;
		
		SDWebImageManager *imageManager = [SDWebImageManager sharedManager];
		UIImage *normalImage = [imageManager.imageCache imageFromMemoryCacheForKey:md5];
		
		if (normalImage != nil) {
			if (weakOperation.isCancelled == NO) {
				dispatch_async(dispatch_get_main_queue(), ^{
					self.image = normalImage;
				});
			}
		}
		else {
			normalImage = [imageManager.imageCache imageFromDiskCacheForKey:md5];
			
			if (normalImage != nil) {
				if (weakOperation.isCancelled == NO) {
					dispatch_async(dispatch_get_main_queue(), ^{
						self.image = normalImage;
					});
				}
			}
			else {
				normalImage = [UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
				normalImage = [self createThumbnail:normalImage];
				
				if (weakOperation.isCancelled == NO) {
					dispatch_async(dispatch_get_main_queue(), ^{
						self.image = normalImage;
					});
				}
				
				[imageManager.imageCache storeImage:normalImage forKey:md5 toDisk:YES];
			}
		}
	}];
	
	[_queue addOperation:operation];
}

- (void)DisplayNoPhotos
{
	if (_queue == nil) {
		_queue = [[NSOperationQueue alloc] init];
		_queue.maxConcurrentOperationCount = 1;
	}
	else {
		[_queue cancelAllOperations];
	}
	
	NSBlockOperation *operation = [[NSBlockOperation alloc] init];
    __weak NSBlockOperation *weakOperation = operation;
    [operation addExecutionBlock:^{
		if (weakOperation.isCancelled == NO) {
			UIImage *noPhotosImage = [UIImage imageNamed:@"Picture.png"];
			if (weakOperation.isCancelled == NO) {
				dispatch_async(dispatch_get_main_queue(), ^{
					self.image = noPhotosImage;
				});
			}
		}
	}];
	
	[_queue addOperation:operation];
}

- (void)setImageNil
{
	if (_queue == nil) {
		_queue = [[NSOperationQueue alloc] init];
		_queue.maxConcurrentOperationCount = 1;
	}
	else {
		[_queue cancelAllOperations];
	}
	
	NSBlockOperation *operation = [[NSBlockOperation alloc] init];
    __weak NSBlockOperation *weakOperation = operation;
    [operation addExecutionBlock:^{
		if (weakOperation.isCancelled == NO) {
			dispatch_async(dispatch_get_main_queue(), ^{
				self.image = nil;
				[self setNeedsDisplay];
			});
		}
	}];
	
	[_queue addOperation:operation];
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
	UIImage *thumbnailImage = [UIImage imageWithCGImage:imageRef scale:2.0f orientation:UIImageOrientationUp];
	CGImageRelease(imageRef);
	
	return thumbnailImage;
}

@end
