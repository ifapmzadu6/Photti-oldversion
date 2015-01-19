//
//  PTViewController.h
//  PhotoTimeline
//
//  Created by Karijuku Keisuke on 2013/04/03.
//  Copyright (c) 2013年 Keisuke Karijuku. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <QuartzCore/QuartzCore.h>
#import <ImageIO/ImageIO.h>

#import "PTAppDelegate.h"
#import "PAPhotoData.h"

#import "JASidePanelController.h"

@class PTNavigationController, PTLeftViewController, PTTimelineViewController, PTAllPhotoViewController;

@interface PTViewController : JASidePanelController <PAAlbumDataControllerDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) PTNavigationController *navigationController;
@property (strong, nonatomic) PTLeftViewController *leftViewController;

//- (void)centerPanelShowTimeline;

- (void)centerPanelShowAllPhotos;

- (void)centerPanelShowAlbumWithIndex:(NSInteger)index;

- (void)centerPanelShowSettings;

- (void)reloadData;

@end
