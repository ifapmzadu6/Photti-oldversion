//
//  PTAppDelegate.h
//  PhotoTimeline
//
//  Created by Karijuku Keisuke on 2013/04/03.
//  Copyright (c) 2013年 Keisuke Karijuku. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PAPhotoData.h"
#import "PTViewController.h"

#import "SDWebImageManager.h"

@interface PTAppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIViewController *viewController;

@property (strong, nonatomic) PAAlbumDataController *albumDataController;

@property (nonatomic) BOOL isViewLoaded;

@end
