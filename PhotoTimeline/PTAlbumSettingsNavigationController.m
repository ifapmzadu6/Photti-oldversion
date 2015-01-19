//
//  PTAlbumSettingsNavigationController.m
//  PhotoTimeline
//
//  Created by Karijuku Keisuke on 2013/05/23.
//  Copyright (c) 2013年 Keisuke Karijuku. All rights reserved.
//

#import "PTAlbumSettingsNavigationController.h"

@interface PTAlbumSettingsNavigationController ()

@end

@implementation PTAlbumSettingsNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (NSUInteger)supportedInterfaceOrientations
{
	return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
