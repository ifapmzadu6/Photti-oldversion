//
//  PTAppDelegate.m
//  PhotoTimeline
//
//  Created by Karijuku Keisuke on 2013/04/03.
//  Copyright (c) 2013年 Keisuke Karijuku. All rights reserved.
//

#import "PTAppDelegate.h"

@interface PTAppDelegate ()
{
	BOOL _isAuthorizationAlertViewDisplayed;
	BOOL _isFirstAlertViewDisplayed;
	
	UIAlertView *_authorizationAlertView;
}
@end

@implementation PTAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
	[[UINavigationBar appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor colorWithRed:0.204f green:0.212f blue:0.239f alpha:1.0f] /*#34363d*/,
      UITextAttributeTextColor,
      [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.0f],
      UITextAttributeTextShadowColor,
      [NSValue valueWithUIOffset:UIOffsetMake(0.0f, 0.0f)],
      UITextAttributeTextShadowOffset,
      [UIFont fontWithName:@"Helvetica-Neue" size:0.0f],
      UITextAttributeFont,
      nil]];
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		
	if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusAuthorized) {
		NSString *filePath = [NSString stringWithFormat:@"%@/UserData.plist",[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]];
		NSFileManager* a_file_mgr = [NSFileManager defaultManager];
		if ([a_file_mgr fileExistsAtPath:filePath])
		{
			NSData *tmpData = [[NSData alloc] initWithContentsOfFile:filePath];
			PAAlbumDataController *tmpApplicationData = [NSKeyedUnarchiver unarchiveObjectWithData:tmpData];
			_albumDataController = tmpApplicationData;
			
			[_albumDataController checkAlbumIsNew];
			
			[a_file_mgr removeItemAtPath:filePath error:nil];
		}
		else {
			NSData *tmpData = [userDefaults objectForKey:@"MainDataBase"];
			if (tmpData == nil) {
				_albumDataController = [[PAAlbumDataController alloc] init];
			}
			else {
				_albumDataController = [NSKeyedUnarchiver unarchiveObjectWithData:tmpData];
			}
			
			[_albumDataController checkAlbumIsNew];
		}
	}
	else {
		_albumDataController = [[PAAlbumDataController alloc] init];
	}
	
	[_albumDataController addNotificationCenter];
	
	dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
		while ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusNotDetermined) {
			[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
		};
		[self checkAssetsLibrary];
		
		[self checkOpenReview];
		
		[_albumDataController accessPhotoLibrary];
		
		NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		NSInteger count = [userDefaults integerForKey:@"CountOfLaunched"];
		[userDefaults setInteger:count + 1 forKey:@"CountOfLaunched"];
	});
	
	dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
		NSString* a_doc_tmp_video = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp/video.mp4"];
		NSString* a_doc_tmp_image = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp/image.jpg"];
		NSFileManager* a_file_mgr = [NSFileManager defaultManager];
		if ([a_file_mgr fileExistsAtPath:a_doc_tmp_video]) {
			[a_file_mgr removeItemAtURL:[NSURL URLWithString:a_doc_tmp_video] error:nil];
		}
		if ([a_file_mgr fileExistsAtPath:a_doc_tmp_image]) {
			[a_file_mgr removeItemAtURL:[NSURL URLWithString:a_doc_tmp_image] error:nil];
		}
	});
	
	return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults synchronize];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	
	[self checkAssetsLibrary];
	
	[self checkOpenReview];
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSInteger count = [userDefaults integerForKey:@"CountOfLaunched"];
	[userDefaults setInteger:count + 1 forKey:@"CountOfLaunched"];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)checkAssetsLibrary
{
	if (_isAuthorizationAlertViewDisplayed == YES) {
		return;
	}
	
	if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusNotDetermined) {
		
		_isAuthorizationAlertViewDisplayed = YES;
		dispatch_async(dispatch_get_main_queue(), ^{
			[self performSelector:@selector(showAuthorizationAlertView) withObject:nil afterDelay:0.3f];
		});
	}
	else if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusRestricted) {
		
		_isAuthorizationAlertViewDisplayed = YES;
		dispatch_async(dispatch_get_main_queue(), ^{
			[self performSelector:@selector(showAuthorizationAlertView) withObject:nil afterDelay:0.3f];
		});	}
	else if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusDenied) {
		
		_isAuthorizationAlertViewDisplayed = YES;
		dispatch_async(dispatch_get_main_queue(), ^{
			[self performSelector:@selector(showAuthorizationAlertView) withObject:nil afterDelay:0.3f];
		});	}
	else {
		//[ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusAuthorized
//		NSLog(@"ALAuthorizationStatusAuthorized");
		
		if (_isAuthorizationAlertViewDisplayed == YES) {
			dispatch_async(dispatch_get_main_queue(), ^{
				[_authorizationAlertView dismissWithClickedButtonIndex:0 animated:NO];
			});
				
			_isAuthorizationAlertViewDisplayed = NO;
		}
	}
}

- (void)showAuthorizationAlertView
{
	NSString *title = NSLocalizedString(@"Allow Photti access to your photos.", @"PTAppDelegate");
	NSString *message = NSLocalizedString(@"Just go to Settings > Privacy > Photos and switch Photti to ON.", @"PTAppDelegate");
	NSString *ok = NSLocalizedString(@"OK", @"PTAppDelegate");
	_authorizationAlertView= [[UIAlertView alloc] initWithTitle:title
											message:message
										   delegate:self
								  cancelButtonTitle:ok
								  otherButtonTitles:nil];
	_authorizationAlertView.tag = 555;
	
	[_authorizationAlertView show];
}

- (void)checkOpenReview
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	if ([userDefaults boolForKey:@"DidReview"] == NO) {
		NSInteger count = [userDefaults integerForKey:@"CountOfLaunched"];
		if (count < 150 && (count + 3)%25 == 0) {
			dispatch_async(dispatch_get_main_queue(), ^{
				[self performSelector:@selector(showReviewAlertView) withObject:nil afterDelay:0.3f];
			});
		}
		else if (count >= 150 && (count + 3) % 100 == 0) {
			dispatch_async(dispatch_get_main_queue(), ^{
				[self performSelector:@selector(showReviewAlertView) withObject:nil afterDelay:0.3f];
			});
		}
		else if (count >= 1000 && (count + 3) % 200 == 0) {
			dispatch_async(dispatch_get_main_queue(), ^{
				[self performSelector:@selector(showReviewAlertView) withObject:nil afterDelay:0.3f];
			});
		}
	}
}

- (void)showReviewAlertView
{
	NSString *title = NSLocalizedString(@"Doesn't it review about this application?", @"PTAppDelegate");
	NSString *message = NSLocalizedString(@"I am an individual developer. Your review leads to my motivation!", @"PTAppDelegate");
	NSString *cancel = NSLocalizedString(@"Cancel", @"PTAppDelegate");
	NSString *review = NSLocalizedString(@"Review", @"PTAppDelegate");
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
														message:message
													   delegate:self
											  cancelButtonTitle:cancel
											  otherButtonTitles:review, nil];
	alertView.tag = 111;
	
	[alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertView.tag == 555) {
		_isAuthorizationAlertViewDisplayed = NO;
	}
	else if (alertView.tag == 111) {
		if (buttonIndex == 1) {
			NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
			[userDefaults setBool:YES forKey:@"DidReview"];
			
			NSURL *url = [NSURL URLWithString:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=663410888&mt=8&type=Purple+Software"];
			[[UIApplication sharedApplication] openURL:url];
		}
	}
	else if (alertView.tag == 333) {
		_isFirstAlertViewDisplayed = NO;
	}
}

@end
