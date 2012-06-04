//
//  RecentPhotoListVC.h
//  rr_homework_2
//
//  Created by Robert Rivera on 6/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecentPhotoListVC : UITableViewController

@property (nonatomic,strong) NSArray* photoList;
@property (nonatomic,strong) IBOutlet UIBarButtonItem* refreshButton;

@end
