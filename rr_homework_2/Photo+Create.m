//
//  Photo+Create.m
//  rr_homework_2
//
//  Created by Robert Rivera on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Photo+Create.h"
#import "Place+Create.h"
#import "Tag+Create.h"
#import "FlickrFetcher.h"

@implementation Photo (Create)

+ (NSArray*) photoTags: (NSString*) tagLine {
    
    NSMutableArray* tags = [[NSMutableArray alloc] initWithArray:[tagLine componentsSeparatedByString:@" "]];
    NSArray* resultTags = [[NSArray alloc] init];
    for (NSString* tag in tags) {
        
        if ([tag componentsSeparatedByString:@":"].count < 2)
            resultTags = [resultTags arrayByAddingObject:tag];
        
    }
    return resultTags;

}
+ (Photo*) addPhoto:(NSDictionary*) photo toContext: (NSManagedObjectContext*) context {
    
    Photo* resultingPhoto = nil;

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"photo_id = %@", [photo objectForKey:FLICKR_PHOTO_ID]];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"photo_id" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || ([matches count] > 1)) {
        NSLog(@"Error in adding photo.");
    } else if ([matches count] == 0) {
        resultingPhoto = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
        resultingPhoto.photo_id = [photo objectForKey:FLICKR_PHOTO_ID];
        NSString* potentialTitle = [photo objectForKey:FLICKR_PHOTO_TITLE];
        NSString* potentialSubtitle = [photo objectForKey:FLICKR_PHOTO_DESCRIPTION];
        
        if (potentialTitle.length < 1) {
            if (potentialSubtitle.length > 0)
                resultingPhoto.photo_title = potentialSubtitle;
            else 
                resultingPhoto.photo_title = @"Unknown";
            resultingPhoto.subtitle = @"";
        } else {
            resultingPhoto.photo_title = potentialTitle;
            if (potentialSubtitle.length > 0)
                resultingPhoto.subtitle = potentialSubtitle;
            else
                resultingPhoto.subtitle = @"";
        }
        
        resultingPhoto.photo_url = [[FlickrFetcher urlForPhoto:photo format:FlickrPhotoFormatOriginal] absoluteString];
        resultingPhoto.latitidue = [photo objectForKey:FLICKR_LATITUDE];
        resultingPhoto.longitude = [photo objectForKey:FLICKR_LONGITUDE];
        resultingPhoto.photo_place = [Place createPlace:[photo objectForKey:FLICKR_PHOTO_PLACE_NAME] 
                                            withContext:context];
        
        // Parse tags and create new ones.
        NSArray* tagArray = [self photoTags:[photo objectForKey:FLICKR_TAGS]];
        NSMutableSet* tagSet = [[NSMutableSet alloc] initWithCapacity:tagArray.count];
        if (tagArray.count > 0) {
            for (NSString* tag in tagArray) {
                if (tag.length > 0) {
                    [tagSet addObject:[Tag createTag:tag 
                                         withContext:context]];
                } else {
                    [tagSet addObject:[Tag createTag:@"None" withContext:context]];
                }
            }
        }
        
        resultingPhoto.photo_tags = [tagSet copy];

    } else {
        photo = [matches lastObject];
    }

    return resultingPhoto;
}

+ (void) removePhoto:(Photo*) photo fromVacation: (NSManagedObjectContext*) context {
    
    NSLog(@"Removing photo from database.");
    
    NSMutableSet* tags = [photo.photo_tags mutableCopy];
    
    
    for (Tag* tag in tags) {
        
        NSMutableSet* photos = [tag.photos mutableCopy];
        [photos removeObject:photo];
        tag.photos = [photos copy];
        tag.photo_count = [NSNumber numberWithInt:tag.photos.count];
        NSLog(@"Tag %@ has %d associated photos.",tag.tag_id,[tag.photo_count intValue]);
        if ([tag.photo_count intValue] < 1)
            [Tag removeTag:tag fromVacation: context];
        
    }
    
    NSMutableSet* places = [photo.photo_place.photos mutableCopy];
    
    [places removeObject:photo];
    
    if (places.count < 1) {
        [Place removePlace:photo.photo_place fromVacation:context];
    } else {
        photo.photo_place.photos = [places copy];
    }
    
    [context deleteObject:photo];

}

@end
