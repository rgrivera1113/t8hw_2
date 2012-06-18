//
//  ItineraryVC.m
//  rr_homework_2
//
//  Created by Robert Rivera on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ItineraryVC.h"
#import "StaticVacationVC.h"

@interface ItineraryVC ()

@property (nonatomic,weak) id<SelectedURLDelegate> parent;

@end

@implementation ItineraryVC

@synthesize dataBase = _dataBase;
@synthesize parent = _parent;

- (void) prepareFetchResults {
    
    // Set up a fetch request to pull places.
    
    
}

- (void) prepareDataBase {
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self.dataBase.fileURL path]]) {
        // does not exist on disk, so create it
        [self.dataBase saveToURL:self.dataBase.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            [self prepareFetchResults];            
        }];
    } else if (self.dataBase.documentState == UIDocumentStateClosed) {
        // exists on disk, but we need to open it
        [self.dataBase openWithCompletionHandler:^(BOOL success) {
            [self prepareFetchResults];
        }];
    } else if (self.dataBase.documentState == UIDocumentStateNormal) {
        // already open and ready to use
        [self prepareFetchResults];
    }
}

- (void) viewWillAppear:(BOOL)animated {
    
    if (!self.dataBase)
        self.dataBase = [[UIManagedDocument alloc] initWithFileURL:[self.parent selectedURL]];
    
}

- (void) setDataBase:(UIManagedDocument *)dataBase {
    
    if (self.dataBase != dataBase) {
        _dataBase = dataBase;
        [self prepareDataBase];
    }
    
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
