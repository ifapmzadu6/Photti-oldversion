//
//  PTSettingsViewController.h
//  PhotoTimeline
//
//  Created by Karijuku Keisuke on 2013/05/16.
//  Copyright (c) 2013年 Keisuke Karijuku. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "PTAppDelegate.h"

@class PTViewController;

@interface PTSettingsViewController : UITableViewController <UIActionSheetDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *appIconImageView;
//@property (weak, nonatomic) IBOutlet UILabel *orderModeLabel;

@property (strong, nonatomic) PTViewController *viewController;


@property (weak, nonatomic) IBOutlet UISwitch *makeByDateButton;
@property (weak, nonatomic) IBOutlet UISwitch *photoStreamButton;

- (IBAction)makeByDateButtonAction:(id)sender;
- (IBAction)photoStreamButtonAction:(id)sender;


@end
