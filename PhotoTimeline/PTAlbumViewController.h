//
//  PTAlbumViewController.h
//  PhotoTimeline
//
//  Created by Karijuku Keisuke on 2013/04/03.
//  Copyright (c) 2013年 Keisuke Karijuku. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <Social/Social.h>
#import <MessageUI/MessageUI.h>
#import <CommonCrypto/CommonDigest.h>

#import "SDWebImageManager.h"

#import "PAPhotoData.h"
#import "MBProgressHUD.h"
#import "LXReorderableCollectionViewFlowLayout.h"

#import "PAPhotoViewController.h"
#import "PTAlbumSettingsNavigationController.h"
#import "PTCombineViewController.h"
#import "PTDivideViewController.h"

#import "PTImageView.h"

typedef enum _EditingModeType {
	EditingModeTypeNone = 0,
	EditingModeTypeAddNewOne = (1 << 0),
	EditingModeTypeSaveAlbum = (1 << 1),
	EditingModeTypeEtcAction = (1 << 2),
	EditingModeTypeRemove = (1 << 3),
	EditingModeTypeMail = (1 << 4),
	EditingModeTypeFacebook = (1 << 5),
	EditingModeTypeThumbnail = (1 << 6),
	EditingModeTypeSort = (1 << 7),
	EditingModeTypeTwitter = (1 << 8),
	EditingModeTypeLine = (1 << 9),
	EditingModeTypeOpenIn = (1 << 10)
} EditingModeType;


@interface PTAlbumViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UIActionSheetDelegate, UIAlertViewDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, LXReorderableCollectionViewDataSource, PTCombineViewControllerDelegate, PTDivideViewControllerDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (weak, nonatomic) IBOutlet UIView *headerViewToolBar;
@property (weak, nonatomic) IBOutlet UILabel *headerViewToolBarLabel;
@property (weak, nonatomic) IBOutlet UIButton *headerViewAddButton;
@property (weak, nonatomic) IBOutlet UIButton *headerViewSortButton;
@property (weak, nonatomic) IBOutlet UIButton *headerViewSaveAlbumButton;
@property (weak, nonatomic) IBOutlet UIButton *headerViewShareButton;
@property (weak, nonatomic) IBOutlet UIButton *headerViewRemoveButton;

- (IBAction)headerViewAddButtonAction:(id)sender;
- (IBAction)headerViewSortButtonAction:(id)sender;
- (IBAction)headerViewSaveAlbumButtonAction:(id)sender;
- (IBAction)headerViewShareButtonAction:(id)sender;
- (IBAction)headerViewRemoveButtonAction:(id)sender;
//- (IBAction)headerViewGPSButtonAction:(id)sender;

@property (nonatomic) NSString *returnSegueIdentifier;

@property (nonatomic) BOOL isAllPhotos;
@property (nonatomic) BOOL isEditing;

@property (nonatomic) PAAlbumData *albumData;
@property (nonatomic) PAAlbumData *allPhoto;

@property (nonatomic) BOOL isDeleteAlbum;
@property (nonatomic) BOOL isCombineAlbum;

- (void)reloadData;

@end
