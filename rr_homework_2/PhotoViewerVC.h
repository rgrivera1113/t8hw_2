//
//  PhotoViewerVC.h
//  rr_homework_2
//
//  Created by Robert Rivera on 6/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SplitViewPresenter.h"
#import "PhotoViewerDataSource.h"
#import "ImageViewerVC.h"
#import "CoreDataPhotoDelegate.h"

@interface PhotoViewerVC : ImageViewerVC <UIScrollViewDelegate, SplitViewPresenter,CoreDataPhotoDelegate>

- (void) handlePhotoForVacation: (UIManagedDocument*) vacation;
- (NSString*) currentPhotoIdentification;
- (NSUInteger) photoExistsInVacation: (UIManagedDocument*) vacation;

@end
