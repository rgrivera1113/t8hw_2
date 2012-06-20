//
//  Place+Create.h
//  rr_homework_2
//
//  Created by Robert Rivera on 6/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Place.h"

@interface Place (Create)

+ (Place*) createPlace: (NSString*) place withContext:(NSManagedObjectContext*) context;

@end
