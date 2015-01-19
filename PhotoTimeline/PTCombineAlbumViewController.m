//
//  PTCombineAlbumViewController.m
//  PhotoTimeline
//
//  Created by Karijuku Keisuke on 2013/05/10.
//  Copyright (c) 2013年 Keisuke Karijuku. All rights reserved.
//

#import "PTCombineAlbumViewController.h"

@interface PTCombineAlbumViewController ()

@end

@implementation PTCombineAlbumViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.tableView.layer.borderColor = [UIColor blackColor].CGColor;
	self.tableView.layer.borderWidth = 1.0f;
	
	[self.tableView setEditing:YES animated:NO];
	
	[self.tableView registerClass:[PTCombineAlbumViewCell class] forCellReuseIdentifier:@"Cell"];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _selectedAlbumDatas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
	
	PAAlbumData *albumData = [_selectedAlbumDatas objectAtIndex:indexPath.row];
	
	if (albumData.photoDatas.count > 0) {
		PAPhotoData *photoData = [albumData.photoDatas objectAtIndex:albumData.thumbnailIndex];
		cell.imageView.image = [UIImage imageWithCGImage:photoData.asset.thumbnail];
	}
	else {
		UIImage *image = [UIImage imageNamed:@"Picture_mini.png"];
		cell.imageView.image = image;
	}
	
    
	if (albumData.title == nil) {
		cell.textLabel.textColor = [UIColor colorWithRed:0.204f green:0.212f blue:0.239f alpha:0.55f];
	}
	else {
		cell.textLabel.textColor = [UIColor colorWithRed:0.204f green:0.212f blue:0.239f alpha:1.0f];
	}
	cell.textLabel.font = [UIFont boldSystemFontOfSize:16.0f];
	cell.textLabel.text = albumData.displayTitleString;
	
	cell.detailTextLabel.text = albumData.displayDateString;
	
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */


// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
	PAAlbumData *albumData = [_selectedAlbumDatas objectAtIndex:fromIndexPath.row];
	[_selectedAlbumDatas removeObject:albumData];
	[_selectedAlbumDatas insertObject:albumData atIndex:toIndexPath.row];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
		   editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleNone;
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView
shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
	return NO;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end




@interface PTCombineAlbumViewCell ()

@end

@implementation PTCombineAlbumViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    // ignore the style argument, use our own to override
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        // If you need any further customization
    }
    return self;
}

@end