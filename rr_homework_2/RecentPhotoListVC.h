//
//  RecentPhotoListVC.h
//  rr_homework_2
//
//  Created by Robert Rivera on 6/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "PhotoListVC.h"
#import "PhotoViewerDataSource.h"

@interface RecentPhotoListVC : PhotoListVC <UITableViewDataSource,UITableViewDelegate,PhotoViewerDataSource,MKMapViewDelegate>

@property (nonatomic,weak) IBOutlet UIBarButtonItem* refreshButton;

-(NSDictionary*) displayedPhoto;

@end
