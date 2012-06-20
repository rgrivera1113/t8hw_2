//
//  VactionListPopoverVC.m
//  rr_homework_2
//
//  Created by Robert Rivera on 6/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VacationListPopoverVC.h"
#import "VacationListPopoverCell.h"
#import <CoreData/CoreData.h>

@interface VacationListPopoverVC ()

@property (nonatomic,strong) NSMutableArray* vacationDocs;

@end

@implementation VacationListPopoverVC

@synthesize parent;
@synthesize vacationDocs;


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"VacationPopoverCell";
    VacationListPopoverCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[VacationListPopoverCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                              reuseIdentifier:CellIdentifier];
    }
    
    cell.vacationName.text = [[self.vacationList objectAtIndex:indexPath.row] lastPathComponent];
    // Open the document at the selected index and do a fetch on the photo ID provided by the
    // parent.
    NSURL* filePath = [self.vacationList objectAtIndex:indexPath.row];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath.path]) {
        // does not exist on disk, Display an error.
        cell.visitLabel.text = @"Error";
    } else {
        // Grab the document and open it.
        UIManagedDocument* doc = [[UIManagedDocument alloc] initWithFileURL:filePath];
        __block NSUInteger result = -1;
        
        if (doc.documentState == UIDocumentStateClosed) {
            // exists on disk, but we need to open it
            [doc openWithCompletionHandler:^(BOOL success) {
                result = [self.parent photoExistsInVacation:doc];
                if (result == 1) {
                    cell.visitLabel.text = @"Unvisit";
                } else if (result == 0) {
                    cell.visitLabel.text = @"Visit";
                } else {
                    cell.visitLabel.text = @"Error";
                }
            }];
        } else if (doc.documentState == UIDocumentStateNormal) {
            // already open and ready to use
            result = [self.parent photoExistsInVacation:doc];
            if (result == 1) {
                cell.visitLabel.text = @"Unvisit";
            } else if (result == 0) {
                cell.visitLabel.text = @"Visit";
            } else {
                cell.visitLabel.text = @"Error";
            }
        }

    }

    return cell;

}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Send the selected managed object back to the parent for processing.
    NSURL* filePath = [self.vacationList objectAtIndex:indexPath.row];
    [self.parent handlePhotoForVacation:[[UIManagedDocument alloc] initWithFileURL:filePath]];
    
        
}

@end
