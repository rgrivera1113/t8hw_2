//
//  TagSearchPhotosVC.h
//  rr_homework_2
//
//  Created by Robert Rivera on 6/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CoreDataTableViewController.h"
#import "Place+Create.h"
#import "CoreDataPhotoViewerDataSource.h"
#import "Tag+Create.h"

@interface TagSearchPhotosVC : CoreDataTableViewController <CoreDataPhotoViewerDataSource>

@property (nonatomic,strong) Tag* tagForPhotos;

- (Photo*) displayedPhoto;


@end
