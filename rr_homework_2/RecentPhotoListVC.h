//
//  RecentPhotoListVC.h
//  rr_homework_2
//
//  Created by Robert Rivera on 6/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoListVC.h"

@interface RecentPhotoListVC : PhotoListVC <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) IBOutlet UIBarButtonItem* refreshButton;

@end
