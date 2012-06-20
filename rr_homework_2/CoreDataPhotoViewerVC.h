//
//  CoreDataPhotoViewerVC.h
//  rr_homework_2
//
//  Created by Robert Rivera on 6/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ImageViewerVC.h"
#import "CoreDataPhotoViewerDataSource.h"
#import "CoreDataPhotoDelegate.h"

@interface CoreDataPhotoViewerVC : ImageViewerVC <CoreDataPhotoDelegate>

@property (nonatomic,weak) id<CoreDataPhotoViewerDataSource> coreDataPhotoDelegate;

- (NSUInteger) photoExistsInVacation: (UIManagedDocument*) vacation;
- (void) handlePhotoForVacation:(UIManagedDocument *)vacation;

@end
