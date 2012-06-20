//
//  ItineraryVC.m
//  rr_homework_2
//
//  Created by Robert Rivera on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ItineraryVC.h"
#import "Place+Create.h"
#import "ItineraryPhotosVC.h"

@interface ItineraryVC ()

@end

@implementation ItineraryVC

@synthesize dataBase = _dataBase;
@synthesize parentDelegate= _parentDelegate;

- (void) prepareFetchResults {
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Place"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"visited_on" 
                                                                                     ascending:YES 
                                                                                      selector:@selector(localizedCaseInsensitiveCompare:)]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.dataBase.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
    
    
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
        self.dataBase = [[UIManagedDocument alloc] initWithFileURL:[self.parentDelegate selectedURL]];
    
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

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"PhotosFromItinerary"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        [segue.destinationViewController setPhotoTakenAt: [self.fetchedResultsController objectAtIndexPath:indexPath]];
    }
    
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PlaceCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    Place* place = [self.fetchedResultsController objectAtIndexPath:indexPath];
    // Then configure the cell using it ...
    cell.textLabel.text = place.place_id;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d photos", [place.photos count]];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

- (NSURL*) selectedURL {
    
    return [self.parentDelegate selectedURL];
    
}


@end
