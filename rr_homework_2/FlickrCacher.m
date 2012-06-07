//
//  FlickrCacher.m
//  rr_homework_2
//
//  Created by Robert Rivera on 6/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FlickrCacher.h"

@implementation FlickrCacher

+ (void) sendPhotoToCache: (NSData*) photo as: (NSString*) photoName {
    
    NSFileManager* fm = [[NSFileManager alloc] init];
    NSArray* directory = [fm URLsForDirectory: NSCachesDirectory inDomains:NSUserDomainMask];
    NSURL* filePath = [[directory objectAtIndex:0] URLByAppendingPathComponent:@"images" isDirectory:YES];
    
    NSError* error;
    if (![fm fileExistsAtPath:filePath.path])
        [fm createDirectoryAtURL:filePath withIntermediateDirectories:NO attributes:NULL error:&error];

    filePath = [filePath URLByAppendingPathComponent:photoName isDirectory:NO];
    
    // Check the size of the cache directory.
    // Remove the oldest photo in the cache, if necessary.
    // Write the new file to the cache.
    [fm createFileAtPath:filePath.path contents:photo attributes:NULL];
    
}

+ (NSData*) grabPhotoFromCache: (NSString*) photoName {

    if (!photoName || photoName.length < 1)
        return nil;
    
    NSFileManager* fm = [[NSFileManager alloc] init];
    NSArray* directory = [fm URLsForDirectory: NSCachesDirectory inDomains:NSUserDomainMask];
    NSURL* filePath = [[directory objectAtIndex:0] URLByAppendingPathComponent:@"images" isDirectory:YES];

    filePath = [filePath URLByAppendingPathComponent:photoName isDirectory:NO];
    if (![fm fileExistsAtPath:filePath.path]) {
        NSLog(@"File %@ does not exist at %@",photoName,filePath.path);
        return nil;
    }
    else
        NSLog(@"File %@ exists at %@",photoName,filePath.path);

    NSData* cachedImage = [[NSData alloc] initWithData:[fm contentsAtPath:filePath.path]];

    return cachedImage;
}


@end
