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

@interface ImageViewerVC : RotatingViewController <SplitViewPresenter,UIScrollViewDelegate,UIPopoverControllerDelegate>

@property (nonatomic,strong) id photo;
@property (nonatomic,weak) id<PhotoViewerDataSource> photoDelegate;
@property (nonatomic,weak) IBOutlet UIScrollView* photoScroll;
@property (nonatomic,weak) IBOutlet UIImageView* photoView;
@property (nonatomic,strong) UIPopoverController* vcp;

- (void) refreshSplitView: (NSString*) photoTitle;
- (void) animateLoadingIndicator: (BOOL) setting;

@end
