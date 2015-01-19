//
//  PTAlbumViewHeaderView.m
//  PhotoTimeline
//
//  Created by Karijuku Keisuke on 2013/05/06.
//  Copyright (c) 2013年 Keisuke Karijuku. All rights reserved.
//

#import "PTAlbumViewHeaderView.h"

@implementation PTAlbumViewHeaderViewImageMaskView

- (void)drawRect:(CGRect)rect
{
    // Drawing code
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGRect shadow3 = CGRectMake(0.0f, 0.0f, CGRectGetMaxX(rect), 80.0f);
	CGFloat components3[] = {
        0.0f, 0.0f, 0.0f, 0.25f,
		0.0f, 0.0f, 0.0f, 0.0f
    };
	CGFloat locations3[] = { 0.0f, 1.0f };
	size_t count3 = sizeof(components3)/ (sizeof(CGFloat)* 4);
	CGContextFillVarticalGradientRect(context, shadow3, components3, locations3, count3);
	
	CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.1f].CGColor);
	CGContextFillRect(context, rect);
}

void CGContextFillVarticalGradientRect(CGContextRef context, CGRect gradientRect,CGFloat components[], CGFloat locations[], CGFloat count)
{
	CGContextSaveGState(context);
	
	CGContextAddRect(context, gradientRect);
	CGContextClip(context);
	
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
	
	
    CGGradientRef gradientRef =
	CGGradientCreateWithColorComponents(colorSpaceRef, components, locations, count);
	
    CGContextDrawLinearGradient(context,
                                gradientRef,
                                CGPointMake(CGRectGetMidX(gradientRect), CGRectGetMinY(gradientRect)),
                                CGPointMake(CGRectGetMidX(gradientRect), CGRectGetMaxY(gradientRect)),
                                0);
	
    CGGradientRelease(gradientRef);
    CGColorSpaceRelease(colorSpaceRef);
	
	CGContextRestoreGState(context);
}

@end


@implementation PTAlbumViewHeaderViewAccessory

- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();

	CGContextSetLineWidth(context, 1.25f);
	CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
	CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0.5f green:0.5f blue:0.5f alpha:1.0f].CGColor);
	CGContextMoveToPoint(context, 0.0f, 10.0f);
	CGContextAddLineToPoint(context, 10.0f, 0.0f);
	CGContextAddLineToPoint(context, 20.0f, 10.0f);
	CGContextClosePath(context);
	CGContextFillPath(context);
}

@end
