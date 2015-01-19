//
//  PAPhotoViewController.h
//  PhotoTimeline
//
//  Created by Karijuku Keisuke on 2013/04/17.
//  Copyright (c) 2013年 Keisuke Karijuku. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

#import "MBProgressHUD.h"

#import "PAPhotoData.h"
#import "PhotoViewController.h"

#import "PTGPSMapViewController.h"


@interface PAPhotoViewController : UIViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate, PhotoViewControllerDelegate>

@property (nonatomic) NSInteger indexOfPhotoDatas;
@property (nonatomic) PAAlbumData *albumData;

@property (nonatomic, strong) UIDocumentInteractionController *docController;
@property (nonatomic, strong) UIActivityViewController *activityViewController;

- (void)reloadData;

@end