//
//  ImageViewerVC.h
//  rr_homework_2
//
//  Created by Robert Rivera on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoViewerDataSource.h"
#import "SplitViewPresenter.h"
#import "RotatingViewController.h"

@interface ImageViewerVC : RotatingViewController <SplitViewPresenter>

@property (nonatomic,strong) NSDictionary* photo;
@property (nonatomic,weak) id<PhotoViewerDataSource> photoDelegate;

- (NSString*) refreshSplitView;
- (void) animateLoadingIndicator: (BOOL) setting;

@end
