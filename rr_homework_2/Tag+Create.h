//
//  Tag+Create.h
//  rr_homework_2
//
//  Created by Robert Rivera on 6/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Tag.h"

@interface Tag (Create)

+ (Tag*) createTag: (NSString*) tag withContext:(NSManagedObjectContext*) context;
+ (void) removeTag: (Tag*) tag fromVacation: (NSManagedObjectContext*) context;


@end
