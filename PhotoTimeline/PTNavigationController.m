//
//  PTNavigationController.m
//  PhotoTimeline
//
//  Created by Karijuku Keisuke on 2013/04/03.
//  Copyright (c) 2013年 Keisuke Karijuku. All rights reserved.
//

#import "PTNavigationController.h"

#import "PTTimelineViewController.h"

@interface PTNavigationController ()
{
	UIView *_statusbarBackgroundView;
}

@end

@implementation PTNavigationController


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
	
	[self.navigationBar setTintColor:[UIColor whiteColor]];
		
	//ジェスチャーの追加（左スワイプで戻る）
//	UISwipeGestureRecognizer* swipeRightGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(myPopViewController)];
//	swipeRightGesture.direction = UISwipeGestureRecognizerDirectionRight;
//	[self.toolbar addGestureRecognizer:swipeRightGesture];
	
	//ステータスバー
	_statusbarBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 20.0f)];
	_statusbarBackgroundView.backgroundColor = [UIColor whiteColor];
	_statusbarBackgroundView.autoresizingMask =  UIViewAutoresizingFlexibleWidth;
	[self.view addSubview:_statusbarBackgroundView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated
{
	[super setNavigationBarHidden:hidden animated:animated];
	
	if (hidden == YES) {
		_statusbarBackgroundView.hidden = YES;
	}
	else {
		_statusbarBackgroundView.hidden = NO;
	}
}

- (void)moveTimelineAtIndex:(NSInteger)index
{
	PTTimelineViewController *timelineViewController = (PTTimelineViewController *)self.topViewController;
	
	if ([timelineViewController.tableView numberOfRowsInSection:0] > 0) {
		[timelineViewController.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
	}
}

- (void)showLeftPanel;
{
	[_viewController showLeftPanelAnimated:YES];
}

- (void)enableRecognizesPanGesture
{
	_viewController.recognizesPanGesture = YES;
}

- (void)disableRecognizesPanGesture
{
	_viewController.recognizesPanGesture = NO;
}

- (void)leftPanelShow
{
	[_viewController showLeftPanelAnimated:YES];
}

- (void)albumDataChanged
{
	[_ptAppDelegate.albumDataController checkAlbumDataController];
	[_viewController reloadData];
}

- (void)reloadData
{
	for (UIViewController *viewController in self.childViewControllers) {
		[viewController performSelector:@selector(reloadData)];
	}
}

- (void)requestReloadData
{
	[_viewController reloadData];
}


- (NSUInteger)supportedInterfaceOrientations
{
	return [self.viewControllers.lastObject supportedInterfaceOrientations];
}

- (void)myPopViewController
{
	[self popViewControllerAnimated:YES];
}

@end
