//
//  FlickrCacher.m
//  rr_homework_2
//
//  Created by Robert Rivera on 6/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FlickrCacher.h"

@implementation FlickrCacher

+ (NSURL*) cachedImageDirectory {
    
    NSFileManager* fm = [[NSFileManager alloc] init];
    NSArray* directory = [fm URLsForDirectory: NSCachesDirectory 
                                    inDomains: NSUserDomainMask];
    
    return [[directory objectAtIndex:0] URLByAppendingPathComponent:@"images" 
                                                        isDirectory:YES];
    
}

+ (void) makeRoomForImage: (NSNumber*) photoSize {

    NSURL* filePath = [self cachedImageDirectory];
    NSFileManager* fm = [[NSFileManager alloc] init];
    NSArray* files = [fm subpathsOfDirectoryAtPath:filePath.path error:nil];

    if (photoSize.longLongValue > MAX_CACHE_SIZE) {
        
        for (NSString* file in files) {
            [fm removeItemAtURL:[filePath URLByAppendingPathComponent:file isDirectory:NO] error:nil];
        }
        
    } else {
        
        NSMutableArray* directoryContents = [files mutableCopy];
        [directoryContents sortUsingComparator:^(id a, id b) {
            
            NSDictionary* left = [fm attributesOfItemAtPath:
                                  [[filePath URLByAppendingPathComponent:a 
                                                             isDirectory:NO] path] 
                                                      error:nil];
            
            NSDictionary* right = [fm attributesOfItemAtPath:
                                   [[filePath URLByAppendingPathComponent:b
                                                              isDirectory:NO] path] 
                                                       error:nil];
            
            return [[left fileCreationDate] compare:[right fileCreationDate]];    
            
        }];
               
        for (NSString* files in directoryContents) {
            
            [fm removeItemAtURL:[filePath URLByAppendingPathComponent:files isDirectory:NO] error:nil];
            
            if ([[self cacheDirectorySize] longLongValue] + [photoSize longLongValue] < MAX_CACHE_SIZE)
                break;
        }
    }
}

+ (NSNumber*) cacheDirectorySize {
    
    unsigned long long int result = 0;
    
    NSURL* filePath = [self cachedImageDirectory];
    NSFileManager* fm = [[NSFileManager alloc] init];
    
    NSArray* files = [fm subpathsOfDirectoryAtPath:filePath.path error:nil];
    
    for (NSString* file in files) {
        [[filePath URLByAppendingPathComponent:file isDirectory:NO] path];
        NSDictionary* fileAttributes = [fm attributesOfItemAtPath: 
                                        [[filePath URLByAppendingPathComponent:file 
                                                                   isDirectory:NO] path] 
                                                            error:nil];
        result += [fileAttributes fileSize];       
    }

    return [[NSNumber alloc] initWithUnsignedLongLong: result];
    
}

+ (void) sendPhotoToCache: (NSData*) photo as: (NSString*) photoName {
    
    NSURL* filePath = [self cachedImageDirectory];
    NSFileManager* fm = [[NSFileManager alloc] init];

    // Create the images directory in the cache directory if it doesn't exist.
    NSError* error;
    if (![fm fileExistsAtPath:filePath.path])
        [fm createDirectoryAtURL:filePath withIntermediateDirectories:NO attributes:NULL error:&error];

    filePath = [filePath URLByAppendingPathComponent:photoName isDirectory:NO];
    
    // Find out if this photo will put the cache folder over
    // its limit.
    if ([[self cacheDirectorySize] longLongValue] + photo.length > MAX_CACHE_SIZE) {
        
        [self makeRoomForImage:[[NSNumber alloc] initWithLongLong:photo.length]];
        
    }

    // Write the new file to the cache.
    if (![fm fileExistsAtPath:filePath.path])
        [fm createFileAtPath:filePath.path contents:photo attributes:NULL];
    
}

+ (NSData*) grabPhotoFromCache: (NSString*) photoName {

    if (!photoName || photoName.length < 1)
        return nil;
    
    NSURL* filePath = [self urlForCachedImage:photoName];

    NSFileManager* fm = [[NSFileManager alloc] init];
    if (![fm fileExistsAtPath:filePath.path])
        return nil;

    NSData* cachedImage = [[NSData alloc] initWithData:[fm contentsAtPath:filePath.path]];

    return cachedImage;
}

+ (NSURL*) urlForCachedImage: (NSString*) photoName {
    
    NSURL* filePath = [[self cachedImageDirectory] URLByAppendingPathComponent:photoName isDirectory:NO];
    NSFileManager* fm = [[NSFileManager alloc] init];
    
    if (![fm fileExistsAtPath:filePath.path])
        return nil;
        
    return filePath;
    
}


@end
