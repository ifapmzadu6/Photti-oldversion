//
//  PTTutorialViewController.m
//  PhotoTimeline
//
//  Created by Karijuku Keisuke on 2013/08/17.
//  Copyright (c) 2013年 Keisuke Karijuku. All rights reserved.
//

#import "PTTutorialViewController.h"

@interface PTTutorialViewController ()
{
	PTAppDelegate *_appDelegate;
}

@end

@implementation PTTutorialViewController

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
	
	self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
	
	UIView *statusbarView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 20.0f)];
	statusbarView.backgroundColor = [UIColor whiteColor];
	[self.navigationController.view addSubview:statusbarView];
	
	if ([self.navigationController.viewControllers objectAtIndex:0] != self) {
		UIButton *customView = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 36.0f, 36.0f)];
		[customView setImage:[UIImage imageNamed:@"09-arrow-west_touched.png"] forState:UIControlStateNormal];
		[customView setImage:[UIImage imageNamed:@"09-arrow-west.png"] forState:UIControlStateHighlighted];
		customView.showsTouchWhenHighlighted = YES;
		customView.exclusiveTouch = YES;
		[customView addTarget:self action:@selector(backBarUIButton) forControlEvents:UIControlEventTouchUpInside];
		UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:customView];
		self.navigationItem.leftBarButtonItem = buttonItem;
	}
	else {
		
	}
	
	_appDelegate = (PTAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)backBarUIButton
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)startTutorialButtonAction:(id)sender
{	
	dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
		if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusNotDetermined) {
			[_appDelegate.albumDataController testAccessPhotoLibrary];
		}
		
		while ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusNotDetermined) {
			[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
		};
		
		dispatch_async(dispatch_get_main_queue(), ^{
			[self performSegueWithIdentifier:@"Page0ToPage1" sender:self];
		});
	});
}

- (IBAction)endTutorialButtonAction:(id)sender
{
	[self dismissViewControllerAnimated:YES completion:nil];
}
@end
