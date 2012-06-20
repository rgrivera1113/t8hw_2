//
//  ItineraryPhotosVC.m
//  rr_homework_2
//
//  Created by Robert Rivera on 6/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ItineraryPhotosVC.h"
#import "Photo+Create.h"
#import "CoreDataPhotoViewerVC.h"

@interface ItineraryPhotosVC ()

@end

@implementation ItineraryPhotosVC

@synthesize photoTakenAt = _photoTakenAt;

- (void) prepareFetchResults {
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"photo_id" 
                                                                                     ascending:YES 
                                                                                      selector:@selector(localizedCaseInsensitiveCompare:)]];
    request.predicate = [NSPredicate predicateWithFormat:@"photo_place.place_id = %@", self.photoTakenAt.place_id];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.photoTakenAt.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
    
    
}

- (void) setPhotoTakenAt:(Place *)photoTakenAt {
    
    _photoTakenAt = photoTakenAt;
    self.title = photoTakenAt.place_id;
    [self prepareFetchResults];
    
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"CDImageSegue"]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        [(CoreDataPhotoViewerVC*) segue.destinationViewController setCoreDataPhotoDelegate:self];
        [(CoreDataPhotoViewerVC*) segue.destinationViewController setPhoto:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
    }
    
    
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PlacePhotoCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    Photo* photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    // Then configure the cell using it ...
    cell.textLabel.text = photo.photo_title;
    
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

- (Photo*) displayedPhoto {
    
    NSIndexPath* selected = [self.tableView indexPathForSelectedRow];
    
    return [self.fetchedResultsController objectAtIndexPath:selected];

}

@end
