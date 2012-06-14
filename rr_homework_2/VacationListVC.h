//
//  VacationListVC.h
//  rr_homework_2
//
//  Created by Robert Rivera on 6/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RotatingViewController.h"

@interface VacationListVC : RotatingViewController <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) NSArray* vacationList;
@property (nonatomic,weak) IBOutlet UIBarButtonItem* vacationButton;

@end
