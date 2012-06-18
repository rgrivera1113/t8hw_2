//
//  VactionListPopoverVC.m
//  rr_homework_2
//
//  Created by Robert Rivera on 6/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VacationListPopoverVC.h"

@interface VacationListPopoverVC ()

@end

@implementation VacationListPopoverVC

@synthesize parent;


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    [parent handlePhotoForVacation:[self.vacationList objectAtIndex:indexPath.row]];
        
}

@end
