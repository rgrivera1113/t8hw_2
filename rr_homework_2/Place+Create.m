//
//  Place+Create.m
//  rr_homework_2
//
//  Created by Robert Rivera on 6/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Place+Create.h"
#import "FlickrFetcher.h"

@implementation Place (Create)

+ (Place*) createPlace: (NSString*) place withContext:(NSManagedObjectContext*) context {
    
    Place* resultingPlace = nil;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Place"];
    request.predicate = [NSPredicate predicateWithFormat:@"place_id = %@", place];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"place_id" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || ([matches count] > 1)) {
        NSLog(@"Error in adding place.");
    } else if ([matches count] == 0) {
        resultingPlace = [NSEntityDescription insertNewObjectForEntityForName:@"Place" inManagedObjectContext:context];
        resultingPlace.place_id = place;
        resultingPlace.visited_on = [NSDate date];
        NSLog(@"Creating Place: %@ on %@",resultingPlace.place_id, [resultingPlace.visited_on description]);
    } else {
        resultingPlace = [matches lastObject];
        NSLog(@"Returning Place: %@",resultingPlace.place_id);
    }
    
    return resultingPlace;
}

@end
