//
//  PTNavigationController.h
//  PhotoTimeline
//
//  Created by Karijuku Keisuke on 2013/04/03.
//  Copyright (c) 2013年 Keisuke Karijuku. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PAPhotoData.h"

#import "PTViewController.h"
#import "PTAlbumViewController.h"


@interface PTNavigationController : UINavigationController

@property (strong, nonatomic) PTAppDelegate *ptAppDelegate;

@property (strong, nonatomic) PTViewController *viewController;

@property (nonatomic) BOOL isAllPhotos;


//- (void)showTimelineView;
- (void)moveTimelineAtIndex:(NSInteger)index;

- (void)showLeftPanel;

- (void)enableRecognizesPanGesture;
- (void)disableRecognizesPanGesture;

- (void)leftPanelShow;

- (void)albumDataChanged;
- (void)reloadData;
- (void)requestReloadData;

@end
