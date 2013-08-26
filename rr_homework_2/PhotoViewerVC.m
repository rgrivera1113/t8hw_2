//
//  PhotoViewerVC.m
//  rr_homework_2
//
//  Created by Robert Rivera on 6/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotoViewerVC.h"
#import "FlickrFetcher.h"
#import "FlickrCacher.h"
#import "PhotoListVC.h"
#import "PhotoViewerDataSource.h"
#import "VacationListPopoverVC.h"
#import <CoreData/CoreData.h>
#import "Photo+Create.h"

@interface PhotoViewerVC ()

@end

@implementation PhotoViewerVC

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (NSString*) updatePhotoTitle {
    
    NSString* photoTitle = [self.photo valueForKey:FLICKR_PHOTO_TITLE];
    NSString* photoDescription = [self.photo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
    if (photoTitle.length < 1) {
        if (photoDescription.length > 0){
            if (photoDescription.length < 25)
                photoTitle = [photoDescription substringToIndex:photoDescription.length];
            else
                photoTitle = [photoDescription substringToIndex:25]; 
        } else 
            photoTitle = @"Unknown";
    } else if (photoTitle.length > 25){
        photoTitle = [photoTitle substringToIndex:25];
    }
    
    return photoTitle;
    
}

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    // Set all of the values for the toolbar.
    
    self.navigationItem.title = [self updatePhotoTitle];
    [self refreshSplitView: [self updatePhotoTitle]];
    // Start the activity indicator before kicking off the load block.
    [self animateLoadingIndicator:YES];
    
    // Get the possible URL for a cached photo.
    dispatch_queue_t downloadQueue = dispatch_queue_create("flickr downloader", NULL);
    dispatch_async(downloadQueue, ^{

        NSString* fileName = [self.photo valueForKey:FLICKR_PHOTO_ID];
        NSData* requestedImage = [FlickrCacher grabPhotoFromCache:fileName];

        if (!requestedImage)
            requestedImage = [NSData dataWithContentsOfURL:[FlickrFetcher urlForPhoto:self.photo format:FlickrPhotoFormatOriginal]];

        // Dictionary or Managed Object.
        NSDictionary* displayedImage = [self.photoDelegate displayedPhoto];
        
        if (!displayedImage) {
        
            dispatch_async(dispatch_get_main_queue(), ^{
                [self animateLoadingIndicator:NO];
            });
            
        }
        else if (self.photo == displayedImage) {

            // Only cache the image if it is still selected.
            dispatch_queue_t cacheWriter = dispatch_queue_create("cache writer", NULL);
            // Derive the filename from the last element of the NSURL.
            dispatch_async(cacheWriter, ^{
                [FlickrCacher sendPhotoToCache:requestedImage as:fileName];
            });
            
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage* image = [UIImage imageWithData:requestedImage];
                self.photoView.image = image;
                self.photoScroll.contentSize = self.photoView.image.size;
                [self.photoScroll zoomToRect:CGRectMake(0, 0, 
                                                        self.photoScroll.contentSize.width, 
                                                        self.photoScroll.contentSize.height) 
                                    animated:NO];
                [self animateLoadingIndicator:NO];
            });
        } 
    });
    dispatch_release(downloadQueue);
    
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"VacationListPopover"]) {
        
        if([segue isKindOfClass: [UIStoryboardPopoverSegue class]]) {
            self.vcp = [(UIStoryboardPopoverSegue*) segue popoverController];
            self.vcp.delegate = self;
        }
        [(VacationListPopoverVC*) segue.destinationViewController setParent: self];
        
    }
    
}

- (void) dismissPopover {
    
    [self.vcp dismissPopoverAnimated:YES];
    self.vcp = nil;

}

- (NSUInteger) photoExistsInVacation: (UIManagedDocument*) vacation {
    
    // Create a fetch to find the requested photo in the database.
    NSManagedObjectContext* context = [vacation managedObjectContext];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"photo_id = %@", 
                         [self currentPhotoIdentification]];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"photo_id" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *photos = [context executeFetchRequest:request error:&error];
    
    return photos.count;    
}


- (void) prepVacation: (UIManagedDocument*) vacation {
    
    __block NSUInteger result = -1;
    
    if (vacation.documentState == UIDocumentStateClosed) {
        // exists on disk, but we need to open it
        [vacation openWithCompletionHandler:^(BOOL success) {
            result = [self photoExistsInVacation:vacation];
            if (result == 1) {
                [self removePhotoFromVacation:vacation];
            } else if (result == 0) {
                [self addPhotoToVacation:vacation];
            } else {
                NSLog(@"Error opening managed document.");
            }
        }];
    } else if (vacation.documentState == UIDocumentStateNormal) {
        // already open and ready to use
        result = [self photoExistsInVacation:vacation];
        if (result == 1) {
            [self removePhotoFromVacation:vacation];
        } else if (result == 0) {
            [self addPhotoToVacation:vacation];
        } else {
            NSLog(@"Error opening managed document.");
        }
    }
}

- (void) handlePhotoForVacation:(UIManagedDocument *)vacation {
    
    [self dismissPopover];
    [self prepVacation:vacation];
    // Create a fetch to find the requested photo in the database.
}

- (void) removePhotoFromVacation: (UIManagedDocument*) vacation {
    
    NSLog(@"Removing photo from vacation.");
    NSManagedObjectContext* context = [vacation managedObjectContext];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"photo_id = %@", 
                         [self currentPhotoIdentification]];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"photo_id" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *photos = [context executeFetchRequest:request error:&error];
    
    if (photos.count != 1) {
        NSLog(@"Problem deleting photo from vacation.  Abort.");
    } else {
        [context performBlock:^{
            [Photo removePhoto:[photos lastObject] fromVacation:vacation.managedObjectContext];
            [vacation saveToURL:vacation.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:NULL];
        }];
    }
    
}

- (void) addPhotoToVacation: (UIManagedDocument*) vacation {
    
    NSLog(@"Adding photo to vacation.");
    NSManagedObjectContext* context = [vacation managedObjectContext];
    [context performBlock:^{
        [Photo addPhoto:self.photo toContext:[vacation managedObjectContext]];
        [vacation saveToURL:vacation.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:NULL];
    }];

}


- (NSString*) currentPhotoIdentification {
    
    return [self.photo valueForKey:FLICKR_PHOTO_ID];
    
}


@end
