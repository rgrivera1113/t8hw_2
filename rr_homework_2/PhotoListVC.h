//
//  PhotoListVCViewController.h
//  rr_homework_2
//
//  Created by Robert Rivera on 6/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoListVC : UIViewController <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) NSArray* photoList;

@end
