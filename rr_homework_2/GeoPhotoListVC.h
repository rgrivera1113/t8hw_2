//
//  PhotoListVC.h
//  rr_homework_2
//
//  Created by Robert Rivera on 6/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoListVC.h"

@interface GeoPhotoListVC : PhotoListVC <UITableViewDelegate,UITableViewDataSource>

//@property (nonatomic,strong) NSArray* photoList;
@property (nonatomic,strong) NSDictionary* photoLocation;
@property (nonatomic,strong) IBOutlet UIBarButtonItem* refreshButton;


@end
