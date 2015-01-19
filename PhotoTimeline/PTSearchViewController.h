//
//  PTSearchViewController.h
//  PhotoTimeline
//
//  Created by Karijuku Keisuke on 2013/07/29.
//  Copyright (c) 2013年 Keisuke Karijuku. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PTAppDelegate.h"

#import "PAPhotoData.h"

#import "PTNavigationController.h"
#import "PTAlbumViewController.h"

@interface PTSearchViewController : UITableViewController <UISearchBarDelegate>

@property (nonatomic) UIView *overlayView;

- (void)reloadData;

@end
