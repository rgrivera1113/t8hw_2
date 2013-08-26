//
//  Photo+Create.h
//  rr_homework_2
//
//  Created by Robert Rivera on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Photo.h"

@interface Photo (Create)

+ (Photo*) addPhoto:(NSDictionary*) photo toContext: (NSManagedObjectContext*) context;
+ (void) removePhoto:(Photo*) photo fromVacation: (NSManagedObjectContext*) context;


@end
