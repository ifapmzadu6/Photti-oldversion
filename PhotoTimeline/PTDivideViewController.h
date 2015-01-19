//
//  PTDivideViewController.h
//  PhotoTimeline
//
//  Created by Karijuku Keisuke on 2013/05/22.
//  Copyright (c) 2013年 Keisuke Karijuku. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PAPhotoData.h"
#import "PTAppDelegate.h"

@protocol PTDivideViewControllerDelegate <NSObject>

- (void)divideAlbum:(PAAlbumData *)albumData;

@end

extern void CGContextFillVarticalGradientRect(CGContextRef context, CGRect gradientRect,CGFloat components[], CGFloat locations[], CGFloat count);

@interface PTDivideViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UIAlertViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

@property (weak, nonatomic) IBOutlet UIImageView *headerViewImage;
@property (weak, nonatomic) IBOutlet UILabel *headerViewTitle;
@property (weak, nonatomic) IBOutlet UILabel *headerViewDate;
@property (weak, nonatomic) IBOutlet UILabel *headerViewPhotos;

@property (weak, nonatomic) IBOutlet UIImageView *footerViewImage;
@property (weak, nonatomic) IBOutlet UILabel *footerViewTitle;
@property (weak, nonatomic) IBOutlet UILabel *footerViewDate;
@property (weak, nonatomic) IBOutlet UILabel *footerViewPhotos;

@property (strong, nonatomic) id<PTDivideViewControllerDelegate> myDelegate;

@property (nonatomic) PAAlbumData *albumData;

- (void)reloadData;

@end



@interface PTDivideViewHeaderView : UIView

@end

@interface PTDivideViewFooterView : UIView

@end


