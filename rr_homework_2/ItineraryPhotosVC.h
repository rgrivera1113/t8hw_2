//
//  ItineraryPhotosVC.h
//  rr_homework_2
//
//  Created by Robert Rivera on 6/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CoreDataTableViewController.h"
#import "Place+Create.h"
#import "CoreDataPhotoViewerDataSource.h"

@interface ItineraryPhotosVC : CoreDataTableViewController <CoreDataPhotoViewerDataSource>

@property (nonatomic,strong) Place* photoTakenAt;

- (Photo*) displayedPhoto;

@end
