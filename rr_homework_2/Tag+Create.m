//
//  Tag+Create.m
//  rr_homework_2
//
//  Created by Robert Rivera on 6/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Tag+Create.h"

@implementation Tag (Create)

+ (Tag*) createTag: (NSString*) tag withContext:(NSManagedObjectContext*) context {
    
    Tag* resultTag = nil;

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tag"];
    request.predicate = [NSPredicate predicateWithFormat:@"tag_id = %@", tag];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"tag_id" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || ([matches count] > 1)) {
        NSLog(@"Error in adding tag.");
    } else if ([matches count] == 0) {
        resultTag = [NSEntityDescription insertNewObjectForEntityForName:@"Tag" inManagedObjectContext:context];
        resultTag.tag_id = tag;
        resultTag.photo_count = [NSNumber numberWithInt:1];
        NSLog(@"Creating Tag: %@",resultTag.tag_id);
    } else {
        resultTag = [matches lastObject];
        int photoCount = [resultTag.photo_count intValue];
        photoCount++;
        resultTag.photo_count = [NSNumber numberWithInt:photoCount];
        NSLog(@"Returning Existing Tag: %@ with %d attached photos.",
              resultTag.tag_id,
              resultTag.photo_count.intValue);
    }

    return resultTag;
    
}


@end
