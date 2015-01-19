//
//  PTTimelineViewCell.m
//  PhotoTimeline
//
//  Created by Karijuku Keisuke on 2013/04/03.
//  Copyright (c) 2013年 Keisuke Karijuku. All rights reserved.
//

#import "PTTimelineViewCell.h"

@implementation PTTimelineViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//void CGContextFillStrokeRoundedRect( CGContextRef context, CGRect rect, CGFloat radius )
//{
//	CGContextMoveToPoint( context, CGRectGetMinX( rect ), CGRectGetMidY( rect ));
//	CGContextAddArcToPoint( context, CGRectGetMinX( rect ), CGRectGetMinY( rect ), CGRectGetMidX( rect ), CGRectGetMinY( rect ), radius );
//	CGContextAddArcToPoint( context, CGRectGetMaxX( rect ), CGRectGetMinY( rect ), CGRectGetMaxX( rect ), CGRectGetMidY( rect ), radius );
//	CGContextAddArcToPoint( context, CGRectGetMaxX( rect ), CGRectGetMaxY( rect ), CGRectGetMidX( rect ), CGRectGetMaxY( rect ), radius );
//	CGContextAddArcToPoint( context, CGRectGetMinX( rect ), CGRectGetMaxY( rect ), CGRectGetMinX( rect ), CGRectGetMidY( rect ), radius );
//	CGContextClosePath( context );
//	CGContextDrawPath( context, kCGPathFillStroke );
//}

//void CGContextFillStrokeRect(CGContextRef context, CGRect rect, CGFloat rotation)
//{
//	CGContextMoveToPoint(context,
//						 rect.origin.x - rotation,
//						 rect.origin.y + rotation);
//	CGContextAddLineToPoint(context,
//							rect.origin.x + rect.size.width - rotation,
//							rect.origin.y - rotation);
//	CGContextAddLineToPoint(context,
//							rect.origin.x + rect.size.width + rotation,
//							rect.origin.y + rect.size.height - rotation);
//	CGContextAddLineToPoint(context,
//							rect.origin.x + rotation,
//							rect.origin.y + rect.size.height + rotation);
//	CGContextClosePath(context);
//	CGContextDrawPath(context, kCGPathEOFillStroke);
//}

- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	//背景
	CGContextSetRGBFillColor(context, 0.9f, 0.9f, 0.9f, 1.0f);
	CGContextFillRect(context, rect);
	
	CGFloat insetWidth = 10.0f;
	CGFloat insetHeight = 7.0f;
	
	CGContextSaveGState(context);
	CGContextSetLineWidth(context, 0.0f);
	CGContextSetShadow(context, CGSizeMake(0.0f, 1.0f), 2.5f);
	
	CGContextSetRGBFillColor(context, 1.0f, 1.0f, 1.0f, 1.0f);
	CGRect backRect = CGRectMake(insetWidth,
								 insetHeight,
								 rect.size.width - insetWidth*2.0f,
								 rect.size.height - insetHeight*2.0f);
	CGContextFillRect(context, backRect);
	
	CGContextRestoreGState(context);
}

@end



