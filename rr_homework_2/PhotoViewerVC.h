//
//  PhotoViewerVC.h
//  rr_homework_2
//
//  Created by Robert Rivera on 6/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SplitViewPresenter.h"

@interface PhotoViewerVC : UIViewController <UIScrollViewDelegate, SplitViewPresenter>

@property (nonatomic,strong) NSDictionary* photo;

@end
