
#import "PhotoViewController.h"
#import "ImageScrollView.h"

#import "PAPhotoViewController.h"

@interface PhotoViewController ()
{
	PTAppDelegate *_appDelegate;
	
    NSUInteger _pageIndex;
	
	ImageScrollView *_scrollView;
		
	BOOL _displayFullResolutionImage;
	
	BOOL _viewDidDisappear;
		
	UIImage *_fullResolutionImage;
	UIImage *_normalImage;
}
@end

@implementation PhotoViewController


- (id)initWithPageIndex:(NSInteger)pageIndex
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        _pageIndex = pageIndex;
    }
    return self;
}

- (void)loadView
{
	_appDelegate = (PTAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	self.wantsFullScreenLayout = YES;
		
	_scrollView = [[ImageScrollView alloc] initWithFrame:[UIScreen mainScreen].bounds];
	
    _scrollView.index = _pageIndex;
	_scrollView.myDelegate = self;
	
	_scrollView.exclusiveTouch = YES;
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view = _scrollView;
	
//	CGSize size = _photoData.asset.defaultRepresentation.dimensions;
//	[_scrollView initDisplayViewForImageSize:size isVideo:NO];
	
//	NSLog(@"loadView at %d", _pageIndex + 1);
}

- (void)viewWillAppear:(BOOL)animated
{
	_viewDidDisappear = NO;
	
	_fullResolutionImage = nil;
	_displayFullResolutionImage = NO;
	
	[self.myDelegate viewWillAppearWithPhotoData:_photoData];
	
	if (_normalImage != nil) {
		[_scrollView displayNomalImage:_normalImage];
		_normalImage = nil;
	}
		
//	NSLog(@"viewWillAppear at %d", _pageIndex + 1);
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	
	_viewDidDisappear = YES;
	
	_fullResolutionImage = nil;
	_normalImage = nil;
	
	_scrollView.zoomScale = _scrollView.minimumZoomScale;
	
//	NSLog(@"viewDodDisappear at %d", _pageIndex + 1);
}

- (void)zoomViewFromSuperview
{
	[_scrollView zoomViewFromSuperview];
}

- (void)zoomingWithSender:(id)sender
{
	if (_photoData.isVideo == NO) {
		[_fullResolutionQueue addOperationWithBlock:^{
			[_appDelegate.albumDataController.library assetForURL:_photoData.assetURL resultBlock:^(ALAsset *asset) {
				UIImage *image = [self decodedImageWithImage:asset.defaultRepresentation.fullResolutionImage orientation:(UIImageOrientation)asset.defaultRepresentation.orientation];
				if (!_viewDidDisappear) {
					dispatch_async(dispatch_get_main_queue(), ^{
						[_scrollView setFullResolutionImage:image];
					});
				}
				else {
					_fullResolutionImage = image;
				}
			} failureBlock:^(NSError *error) {
			}];
		}];
	}
}

- (void)recycleView
{
	_normalImage = nil;
	
//	NSLog(@"recycleView");
	
	dispatch_async(dispatch_get_main_queue(), ^{
		[_scrollView initDisplayViewWithThumbnailImageRef:_photoData.asset.aspectRatioThumbnail
												  isVideo:_photoData.isVideo
													 size:_photoData.asset.defaultRepresentation.dimensions
											  orientation:_photoData.asset.defaultRepresentation.orientation];
				
		NSBlockOperation *operation = [[NSBlockOperation alloc] init];
		[operation addExecutionBlock:^{
			_normalImage = [UIImage imageWithCGImage:_photoData.asset.defaultRepresentation.fullScreenImage];
			
			if (_viewDidDisappear == NO) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[_scrollView displayNomalImage:_normalImage];
					_normalImage = nil;
				});
			}
		}];
		
		[_queue addOperation:operation];
	});
}

- (void)playMovieButtonAction
{
	[self.myDelegate playMovie];
}

- (NSUInteger)supportedInterfaceOrientations
{
	return UIInterfaceOrientationMaskAllButUpsideDown;
}

//UIImage *loadThumbnailImageWithAsset(ALAsset *asset, CGFloat imageSize, CGFloat maxImageSize)
//{
//	ALAssetRepresentation *rep = [asset defaultRepresentation];
//	Byte *buffer = (Byte *)malloc(rep.size);
//	NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:rep.size error:nil];
//	NSData *data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
//	CIImage *ciImage = [[CIImage alloc] initWithData:data];
//	buffer = nil;
//	
//	CGRect imageRect = [ciImage extent];
//	CGFloat scale, width, height;
//	scale = imageRect.size.width < imageRect.size.height ? imageSize / imageRect.size.width : imageSize / imageRect.size.height;
//	width = scale * imageRect.size.width;
//	height = scale * imageRect.size.height;
//	
//	if (width > maxImageSize || height > maxImageSize) {
//		scale = imageRect.size.width < imageRect.size.height ? maxImageSize / imageRect.size.width : maxImageSize / imageRect.size.height;
//		width = scale * imageRect.size.width;
//		height = scale * imageRect.size.height;
//	}
//	
//	CIImage *filteredImage = [ciImage imageByApplyingTransform:CGAffineTransformMakeScale(scale, scale)];
//	ciImage = nil;
//	filteredImage = [filteredImage imageByCroppingToRect:CGRectMake(0.0f, 0.0f, width, height)];
//	
//	CIContext *ciContext = [CIContext contextWithOptions:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:kCIContextUseSoftwareRenderer]];
//	
//	CGImageRef imageRef = [ciContext createCGImage:filteredImage fromRect:[filteredImage extent]];
//	filteredImage = nil;
//	ciContext = nil;
//	
//	UIImage *decompressedImage;
//	ALAssetOrientation orientation = rep.orientation;
//	if (orientation == ALAssetOrientationUp) {
//		decompressedImage = [UIImage imageWithCGImage:imageRef scale:2.0f orientation:UIImageOrientationUp];
//	}
//	else if (orientation == ALAssetOrientationRight) {
//		decompressedImage = [UIImage imageWithCGImage:imageRef scale:2.0f orientation:UIImageOrientationRight];
//	}
//	else if (orientation == ALAssetOrientationLeft) {
//		decompressedImage = [UIImage imageWithCGImage:imageRef scale:2.0f orientation:UIImageOrientationLeft];
//	}
//	else {
//		decompressedImage = [UIImage imageWithCGImage:imageRef scale:2.0f orientation:UIImageOrientationDown];
//	}
//	CGImageRelease(imageRef);
//	
//	//	NSLog(@"load %d ThumbnailImage", _pageIndex);
//	
//	return decompressedImage;
//}

UIImage *loadFullResolutionImageWithAsset(ALAsset *asset)
{
	UIImage *image = [UIImage imageWithCGImage:asset.defaultRepresentation.fullResolutionImage];
	
	return image;
}

- (void)singleTap
{
	[_myDelegate singleTap];
}

- (void)desableSingleTap
{
	[_scrollView desableSingleTap];
}

- (UIImage *)decodedImageWithImage:(CGImageRef)imageRef orientation:(UIImageOrientation)orientation
{
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imageRef), CGImageGetHeight(imageRef));
    CGRect imageRect = (CGRect){.origin = CGPointZero, .size = imageSize};
		
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
	
    int infoMask = (bitmapInfo & kCGBitmapAlphaInfoMask);
    BOOL anyNonAlpha = (infoMask == kCGImageAlphaNone ||
                        infoMask == kCGImageAlphaNoneSkipFirst ||
                        infoMask == kCGImageAlphaNoneSkipLast);
	
    // CGBitmapContextCreate doesn't support kCGImageAlphaNone with RGB.
    // https://developer.apple.com/library/mac/#qa/qa1037/_index.html
    if (infoMask == kCGImageAlphaNone && CGColorSpaceGetNumberOfComponents(colorSpace) > 1)
    {
        // Unset the old alpha info.
        bitmapInfo &= ~kCGBitmapAlphaInfoMask;
		
        // Set noneSkipFirst.
        bitmapInfo |= kCGImageAlphaNoneSkipFirst;
    }
    // Some PNGs tell us they have alpha but only 3 components. Odd.
    else if (!anyNonAlpha && CGColorSpaceGetNumberOfComponents(colorSpace) == 3)
    {
        // Unset the old alpha info.
        bitmapInfo &= ~kCGBitmapAlphaInfoMask;
        bitmapInfo |= kCGImageAlphaPremultipliedFirst;
    }
	
    // It calculates the bytes-per-row based on the bitsPerComponent and width arguments.
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 imageSize.width,
                                                 imageSize.height,
                                                 CGImageGetBitsPerComponent(imageRef),
                                                 0,
                                                 colorSpace,
                                                 bitmapInfo);
    CGColorSpaceRelease(colorSpace);
	
	CGContextSetBlendMode(context, kCGBlendModeCopy);
    CGContextDrawImage(context, imageRect, imageRef);
    CGImageRef decompressedImageRef = CGBitmapContextCreateImage(context);
	
    CGContextRelease(context);
	
	UIImage *image = [UIImage imageWithCGImage:decompressedImageRef scale:1.0f orientation:orientation];
	CGImageRelease(decompressedImageRef);
	
    return image;
}

@end
