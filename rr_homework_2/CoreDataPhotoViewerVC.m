//
//  CoreDataPhotoViewerVC.m
//  rr_homework_2
//
//  Created by Robert Rivera on 6/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CoreDataPhotoViewerVC.h"
#import <CoreData/CoreData.h>
#import "FlickrFetcher.h"
#import "Photo+Create.h"
#import "FlickrCacher.h"
#import "VacationListPopoverVC.h"

@interface CoreDataPhotoViewerVC ()

@end

@implementation CoreDataPhotoViewerVC

@synthesize coreDataPhotoDelegate = _coreDataPhotoDelegate;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (NSString*) updatePhotoTitle {
    
    NSString* photoTitle = [self.photo photo_title];
    NSString* photoDescription = [self.photo subtitle];
    if (photoTitle.length < 1) {
        if (photoDescription.length > 0)
            photoTitle = [photoDescription substringToIndex:25];
        else 
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
        
        NSData* requestedImage = [FlickrCacher grabPhotoFromCache:[self.photo photo_id]];
        
        if (!requestedImage)
            requestedImage = [NSData dataWithContentsOfURL: [NSURL URLWithString:[self.photo photo_url]]];
        
        // Dictionary or Managed Object.
        Photo* displayedImage = [self.coreDataPhotoDelegate displayedPhoto];
        
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
                [FlickrCacher sendPhotoToCache:requestedImage as:[self.photo photo_url]];
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
                         [self.photo photo_id]];
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
    
}

- (void) addPhotoToVacation: (UIManagedDocument*) vacation {
    
    NSLog(@"Adding photo to vacation.");
    NSManagedObjectContext* context = [vacation managedObjectContext];
    [context performBlock:^{
        [Photo addPhoto:self.photo toContext:[vacation managedObjectContext]];
        [vacation saveToURL:vacation.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:NULL];
    }];
    
}

@end
