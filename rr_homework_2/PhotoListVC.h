//
//  PhotoListVCViewController.h
//  rr_homework_2
//
//  Created by Robert Rivera on 6/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RotatingViewController.h"

@interface PhotoListVC : RotatingViewController <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) NSArray* photoList;

- (NSDictionary*) displayedPhoto: (NSIndexPath*) atIndex;

@end
