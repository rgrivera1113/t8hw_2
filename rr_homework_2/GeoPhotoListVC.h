//
//  PhotoListVC.h
//  rr_homework_2
//
//  Created by Robert Rivera on 6/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "PhotoListVC.h"
#import "PhotoViewerDataSource.h"
#import "ImageAnnotations.h"

@interface GeoPhotoListVC : PhotoListVC <UITableViewDelegate,UITableViewDataSource,PhotoViewerDataSource,MKMapViewDelegate>

@property (nonatomic,strong) NSDictionary* photoLocation;

- (NSDictionary*) displayedPhoto;

@end
