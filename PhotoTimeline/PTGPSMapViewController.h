//
//  PTGPSMapViewController.h
//  PhotoTimeline
//
//  Created by Karijuku Keisuke on 2013/04/27.
//  Copyright (c) 2013年 Keisuke Karijuku. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "PAPhotoData.h"

@interface PTGPSMapViewController : UIViewController <MKMapViewDelegate>

@property (nonatomic) NSMutableArray *photoDatas;
@property (nonatomic) NSInteger indexOfPhotoDatas;
@property (nonatomic) BOOL isSingle;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (nonatomic) NSString *navigationTopLabelText;
@property (nonatomic) NSString *navigationBottomLabelText;

- (void)reloadData;

@end




//Mapkit
@interface CustomAnnotation : NSObject <MKAnnotation>

@property (readwrite, nonatomic) CLLocationCoordinate2D coordinate;
@property (readwrite, nonatomic) NSString *title;
@property (nonatomic) PAPhotoData *photoData;

@end
