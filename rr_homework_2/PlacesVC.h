//
//  ViewController.h
//  rr_homework_2
//
//  Created by Robert Rivera on 5/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RotatingViewController.h"

@interface PlacesVC : RotatingViewController <UISplitViewControllerDelegate, 
                                                UITableViewDelegate,
                                                UITableViewDataSource>

@property (nonatomic,strong) NSArray* locationList;
@property (nonatomic,strong) IBOutlet UIBarButtonItem* refreshButton;

@end
