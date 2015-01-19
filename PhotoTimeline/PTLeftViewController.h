//
//  PTLeftViewController.h
//  PhotoTimeline
//
//  Created by Karijuku Keisuke on 2013/04/03.
//  Copyright (c) 2013年 Keisuke Karijuku. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTAppDelegate.h"
#import "PTViewController.h"


@interface PTLeftViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) PTViewController *viewController;

@property (strong, nonatomic) PTAppDelegate *ptAppDelegate;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (void)reloadData;

@end


@interface PTSectionHeader : UIView

@end
