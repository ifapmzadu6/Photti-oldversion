//
//  PTCombineViewController.h
//  PhotoTimeline
//
//  Created by Karijuku Keisuke on 2013/05/21.
//  Copyright (c) 2013年 Keisuke Karijuku. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PTAppDelegate.h"
#import "PAPhotoData.h"

#import "PTCombineAlbumViewController.h"

#import "PTLeftViewController.h"

@protocol PTCombineViewControllerDelegate <NSObject>

- (void)combineAlbums:(NSMutableArray *)selectedAlbumDatas;

@end


@interface PTCombineViewController : UITableViewController

@property (nonatomic) NSMutableArray *albumDatas;

@property (nonatomic) NSIndexPath *firstIndexPath;

@property (strong, nonatomic) id<PTCombineViewControllerDelegate>myDelegate;

- (void)reloadData;

@end
