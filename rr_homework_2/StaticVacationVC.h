//
//  StaticVacationVC.h
//  rr_homework_2
//
//  Created by Robert Rivera on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SelectedURLDelegate <NSObject>

- (NSURL*) selectedURL;

@end

@interface StaticVacationVC : UITableViewController <SelectedURLDelegate>

@property (nonatomic,weak) id<SelectedURLDelegate> parentDelegate;

@end
