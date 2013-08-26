//
//  TagSearchViewController.h
//  rr_homework_2
//
//  Created by Robert Rivera on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CoreDataTableViewController.h"
#import <CoreData/CoreData.h>
#import "StaticVacationVC.h"

@interface TagSearchViewController : CoreDataTableViewController

@property (nonatomic,strong) UIManagedDocument* dataBase;
@property (nonatomic,weak) id<SelectedURLDelegate> parentDelegate;

@end
