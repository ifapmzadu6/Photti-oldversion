//
//  PTTutorialViewController.h
//  PhotoTimeline
//
//  Created by Karijuku Keisuke on 2013/08/17.
//  Copyright (c) 2013年 Keisuke Karijuku. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "PTAppDelegate.h"

@interface PTTutorialViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *authorizationLabel;

- (IBAction)startTutorialButtonAction:(id)sender;

- (IBAction)endTutorialButtonAction:(id)sender;

@end
