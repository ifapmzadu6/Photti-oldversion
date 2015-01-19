#import <Foundation/Foundation.h>

#import "ImageScrollView.h"

// forward declaration of our utility functions

static UIImage *_ImageAtIndex(NSUInteger index);

static NSString *_ImageNameAtIndex(NSUInteger index);

#pragma mark -

@interface ImageScrollView () <UIScrollViewDelegate>
{
    UIImageView *_zoomImageView;
    CGSize _imageSize;

    CGPoint _pointToCenterAfterResize;
    CGFloat _scaleToRestoreAfterResize;
	
	BOOL _zooming;
	
	BOOL _isVideo;
	UIButton *_movieButton;
	
	BOOL _isFullResolutinImageDisplayed;
}

@end

@implementation ImageScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.bouncesZoom = YES;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.delegate = self;
		self.autoresizesSubviews = YES;
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		
		UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
		singleTapGesture.numberOfTapsRequired = 1;
		[self addGestureRecognizer:singleTapGesture];
		UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
		doubleTapGesture.numberOfTapsRequired = 2;
		[self addGestureRecognizer:doubleTapGesture];
    }
    return self;
}

- (void)zoomViewFromSuperview
{
	[_zoomImageView removeFromSuperview];
	_zoomImageView = nil;
}

- (void)setIndex:(NSUInteger)index
{
    _index = index;
}

- (void)layoutSubviews 
{
    [super layoutSubviews];
    
    // center the zoom view as it becomes smaller than the size of the screen
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = _zoomImageView.frame;
    
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    else
        frameToCenter.origin.x = 0;
    
    // center vertically
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    else
        frameToCenter.origin.y = 0;
	
	if (_movieButton != nil) {
		_movieButton.center = self.center;
	}
    
    _zoomImageView.frame = frameToCenter;
}

- (void)setFrame:(CGRect)frame
{
    BOOL sizeChanging = !CGSizeEqualToSize(frame.size, self.frame.size);
	
//	NSLog(@"sizeChanging = %d",sizeChanging);
    
	_zooming = YES;
	
    if (sizeChanging) {
        [self prepareToResize];
    }
    
    [super setFrame:frame];
    
    if (sizeChanging) {
        [self recoverFromResizing];
    }
	
	_zooming = NO;
}


#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return  _zoomImageView;
}

#pragma mark - Configure scrollView to display new image (tiled or not)

- (void)initDisplayViewWithThumbnailImageRef:(CGImageRef)thumbnailImageRef isVideo:(BOOL)isVideo size:(CGSize)dimensions orientation:(ALAssetOrientation)orientation;
{
	_zooming = YES;
	
	_isVideo = isVideo;
	
	if (_zoomImageView) {
		[_zoomImageView removeFromSuperview];
	}
	
    // reset our zoomScale to 1.0 before doing any further calculations
    self.zoomScale = 1.0f;
	
	CGFloat imageWidth = dimensions.width;
	CGFloat imageHeight = dimensions.height;
//	NSLog(@"[%f, %f]", imageWidth, imageHeight);
	if (isVideo == YES) {
		if (CGImageGetWidth(thumbnailImageRef) < CGImageGetHeight(thumbnailImageRef)) {
			CGFloat tmp = imageWidth;
			imageWidth = imageHeight;
			imageHeight = tmp;
		}
	}
	if (self.bounds.size.width < self.bounds.size.height) {
		imageHeight = imageHeight * self.bounds.size.width / imageWidth;
		imageWidth = self.bounds.size.width;
	}
	else {
		imageWidth = imageWidth * self.bounds.size.height / imageHeight;
		imageHeight = self.bounds.size.height;
	}
	CGSize imageSize = CGSizeMake(imageWidth, imageHeight);
//	NSLog(@"%f, %f", imageWidth, imageHeight);
	
	_zoomImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, imageWidth, imageHeight)];
	_zoomImageView.contentMode = UIViewContentModeScaleAspectFit;
	_zoomImageView.center = self.center;
	_zoomImageView.image = [UIImage imageWithCGImage:thumbnailImageRef];
	[self addSubview:_zoomImageView];
	
	if (_movieButton != nil) {
		[_movieButton removeFromSuperview];
		_movieButton = nil;
	}
	if (_isVideo == YES) {
		_movieButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 70.0f, 70.0f)];
		_movieButton.center = self.center;
		[_movieButton setImage:[UIImage imageNamed:@"70-play.png"] forState:UIControlStateNormal];
		[_movieButton addTarget:self.myDelegate action:@selector(playMovieButtonAction) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_movieButton];
	}
	
	_isFullResolutinImageDisplayed = NO;
	
	_imageSize = imageSize;
	self.contentSize = imageSize;
    [self setMaxMinZoomScalesForCurrentBounds];
    self.zoomScale = self.minimumZoomScale;
	
	_zooming = NO;
}

- (void)displayNomalImage:(UIImage *)image
{
	_zoomImageView.image = image;
}

- (void)setFullResolutionImage:(UIImage *)image
{
	if (_isFullResolutinImageDisplayed == NO) {
		_zoomImageView.image = image;
		image = nil;
		_isFullResolutinImageDisplayed = YES;
	}
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
	if (_zooming == NO && self.zoomScale > self.minimumZoomScale) {
		_zooming = YES;
		[self.myDelegate zoomingWithSender:self];
	}
}

- (void)setMaxMinZoomScalesForCurrentBounds
{
    CGSize boundsSize = self.bounds.size;
		
    // calculate min/max zoomscale
    CGFloat xScale = boundsSize.width  / _imageSize.width;    // the scale needed to perfectly fit the image width-wise
    CGFloat yScale = boundsSize.height / _imageSize.height;   // the scale needed to perfectly fit the image height-wise
	    
    // fill width if the image and phone are both portrait or both landscape; otherwise take smaller scale
//    BOOL imagePortrait = _imageSize.height > _imageSize.width;
//    BOOL phonePortrait = boundsSize.height > boundsSize.width;
//    CGFloat minScale = (imagePortrait == phonePortrait ? MIN(xScale, yScale) : MIN(xScale, yScale));
	CGFloat minScale = MIN(xScale, yScale);
	
    // on high resolution screens we have double the pixel density, so we will be seeing every pixel if we limit the
    // maximum zoom scale to 0.5.
//    CGFloat maxScale = 1.0f / [[UIScreen mainScreen] scale];
//	CGFloat maxScale = 7.0f;
	
    // don't let minScale exceed maxScale. (If the image is smaller than the screen, we don't want to force it to be zoomed.) 
//    if (minScale > maxScale) {
//        minScale = maxScale;
//    }
	
    self.minimumZoomScale = minScale;
	
//	NSLog(@"%f", minScale);
	
	if (_isVideo == YES) {
		self.maximumZoomScale = self.minimumZoomScale;
	}
	else {
		self.maximumZoomScale = minScale * 9.0f;
	}
}

#pragma mark -
#pragma mark Methods called during rotation to preserve the zoomScale and the visible portion of the image

#pragma mark - Rotation support

- (void)prepareToResize
{
    CGPoint boundsCenter = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    _pointToCenterAfterResize = [self convertPoint:boundsCenter toView:_zoomImageView];
	
    _scaleToRestoreAfterResize = self.zoomScale;
    
    // If we're at the minimum zoom scale, preserve that by returning 0, which will be converted to the minimum
    // allowable scale when the scale is restored.
    if (_scaleToRestoreAfterResize <= self.minimumZoomScale + FLT_EPSILON)
        _scaleToRestoreAfterResize = 0;
}

- (void)recoverFromResizing
{
    [self setMaxMinZoomScalesForCurrentBounds];
    
    // Step 1: restore zoom scale, first making sure it is within the allowable range.
    CGFloat maxZoomScale = MAX(self.minimumZoomScale, _scaleToRestoreAfterResize);
    self.zoomScale = MIN(self.maximumZoomScale, maxZoomScale);
	
    // Step 2: restore center point, first making sure it is within the allowable range.
    
    // 2a: convert our desired center point back to our own coordinate space
    CGPoint boundsCenter = [self convertPoint:_pointToCenterAfterResize fromView:_zoomImageView];

    // 2b: calculate the content offset that would yield that center point
    CGPoint offset = CGPointMake(boundsCenter.x - self.bounds.size.width / 2.0,
                                 boundsCenter.y - self.bounds.size.height / 2.0);

    // 2c: restore offset, adjusted to be within the allowable range
    CGPoint maxOffset = [self maximumContentOffset];
    CGPoint minOffset = [self minimumContentOffset];
    
    CGFloat realMaxOffset = MIN(maxOffset.x, offset.x);
    offset.x = MAX(minOffset.x, realMaxOffset);
    
    realMaxOffset = MIN(maxOffset.y, offset.y);
    offset.y = MAX(minOffset.y, realMaxOffset);
    
    self.contentOffset = offset;
}

- (CGPoint)maximumContentOffset
{
    CGSize contentSize = self.contentSize;
    CGSize boundsSize = self.bounds.size;
    return CGPointMake(contentSize.width - boundsSize.width, contentSize.height - boundsSize.height);
}

- (CGPoint)minimumContentOffset
{
    return CGPointZero;
}

- (void)handleSingleTap:(UIGestureRecognizer *)sender
{
	if (sender.state == UIGestureRecognizerStateEnded){
		[self performSelector:@selector(singleTap) withObject:nil afterDelay:0.25f];
	}
}

- (void)singleTap
{
	[self.myDelegate singleTap];
}

- (void)desableSingleTap
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)handleDoubleTap:(UIGestureRecognizer *)sender
{
	if (sender.state == UIGestureRecognizerStateEnded){
		[NSObject cancelPreviousPerformRequestsWithTarget:self];
		
		if (_isVideo == YES) {
			return;
		}
		
		//NSLog(@"maximum %f  : minimum %f => %f", self.maximumZoomScale, self.minimumZoomScale, self.minimumZoomScale * 3.0f);
		if (self.zoomScale == self.minimumZoomScale * 3.0f) {
			CGFloat width = [sender locationInView:_zoomImageView].x;;
			CGFloat height = [sender locationInView:_zoomImageView].y;
			CGPoint center = CGPointMake(width, height);
			CGFloat scale = self.maximumZoomScale;
			CGRect zoomRect = [self zoomRectForScrollView:self
												withScale:scale
											   withCenter:center];
			
			[self zoomToRect:zoomRect animated:YES];
		}
		else if (self.zoomScale > self.minimumZoomScale) {
			[self setZoomScale:self.minimumZoomScale animated:YES];
		} else {
			CGFloat width = [sender locationInView:_zoomImageView].x;;
			CGFloat height = [sender locationInView:_zoomImageView].y;
			CGPoint center = CGPointMake(width, height);
			CGFloat scale = self.minimumZoomScale * 3.0f;
			CGRect zoomRect = [self zoomRectForScrollView:self
												withScale:scale
											   withCenter:center];
			[self zoomToRect:zoomRect animated:YES];
		}
	}
}
- (CGRect)zoomRectForScrollView:(UIScrollView *)scrollView withScale:(float)scale withCenter:(CGPoint)center
{
    CGRect zoomRect;
    zoomRect.size.height = scrollView.frame.size.height / scale;
    zoomRect.size.width  = scrollView.frame.size.width  / scale;
    zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0f);
    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0f);
	
    return zoomRect;
}

@end