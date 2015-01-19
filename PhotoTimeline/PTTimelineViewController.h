//
//  PTTimelineViewController.h
//  PhotoTimeline
//
//  Created by Karijuku Keisuke on 2013/04/03.
//  Copyright (c) 2013年 Keisuke Karijuku. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CommonCrypto/CommonDigest.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "SDWebImageManager.h"

#import "PTAppDelegate.h"
#import "PAPhotoData.h"

#import "PTSearchViewController.h"

#import "PTAlbumSettingsNavigationController.h"
#import "PTCombineViewController.h"
#import "PTDivideViewController.h"

#import "PTImageView.h"

@interface PTTimelineViewController : UIViewController <UITableViewDataSource, UITableViewDelegate,UIActionSheetDelegate, UIAlertViewDelegate, PTCombineViewControllerDelegate, PTDivideViewControllerDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) PTAppDelegate *ptAppDelegate;

@property (nonatomic) NSUInteger firstNumberOfRows;

@property (nonatomic) BOOL isLeftPanelOpened;

- (IBAction)settingsAlbumButtonAction:(id)sender;
- (IBAction)saveAlbumButtonAction:(id)sender;
- (IBAction)facebookAlbumButtonAction:(id)sender;

- (IBAction)timelineViewReturnActionForSegue:(UIStoryboardSegue *)segue;

- (void)reloadData;

@end



@interface CustomToolbar : UIToolbar

@end
