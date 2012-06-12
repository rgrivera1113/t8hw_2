//
//  ImageAnnotations.m
//  rr_homework_2
//
//  Created by Robert Rivera on 6/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ImageAnnotations.h"
#import "FlickrFetcher.h"

@implementation ImageAnnotations

@synthesize photo = _photo;

+ (ImageAnnotations*) annotationForPhoto: (NSDictionary*) photo {
    
    ImageAnnotations* annotation = [[ImageAnnotations alloc] init];
    annotation.photo = photo;
    return annotation;

}

- (NSString*) title {
    
    return [self.photo valueForKey:FLICKR_PHOTO_TITLE];
    
}

- (NSString*) subtitle {

    return [self.photo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];

}

- (CLLocationCoordinate2D) coordinate {

    CLLocationCoordinate2D position;
    position.latitude = [[self.photo valueForKey:FLICKR_LATITUDE] doubleValue];
    position.longitude = [[self.photo valueForKey:FLICKR_LONGITUDE] doubleValue];
    
    return position;
}


@end
