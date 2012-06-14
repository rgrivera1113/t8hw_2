//
//  FlickrCacher.h
//  rr_homework_2
//
//  Created by Robert Rivera on 6/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MAX_CACHE_SIZE 10000000


@interface FlickrCacher : NSObject

+ (void) sendPhotoToCache: (NSData*) photo as: (NSString*) photoName;
+ (NSData*) grabPhotoFromCache: (NSString*) photoName;
+ (NSURL*) urlForCachedImage: (NSString*) photoName;

@end
