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

@interface ImageViewerVC : UIViewController <SplitViewPresenter>

@property (nonatomic,strong) NSDictionary* photo;
@property (nonatomic,weak) id<PhotoViewerDataSource> photoDelegate;

- (void) refreshSplitViewButton;
- (NSString*) updatePhotoTitle;
- (void) animateLoadingIndicator: (BOOL) setting;

@end
