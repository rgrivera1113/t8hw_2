//
//  LocationAnnotation.m
//  rr_homework_2
//
//  Created by Robert Rivera on 6/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LocationAnnotation.h"
#import "FlickrFetcher.h"

@implementation LocationAnnotation

@synthesize location;

+ (LocationAnnotation*) annotationForLocation:(NSDictionary *)location {
    
    LocationAnnotation* annotation = [[LocationAnnotation alloc] init];
    annotation.location = location;
    return annotation;
    
}

- (NSString*) title {
    
    NSString* fullLocation = [location objectForKey:FLICKR_PLACE_NAME];
    NSArray* splitLocation = [fullLocation componentsSeparatedByString:@", "];
    return [splitLocation objectAtIndex:0];
}

- (NSString*) subtitle {
    
    NSString* fullLocation = [location objectForKey:FLICKR_PLACE_NAME];
    NSArray* splitLocation = [fullLocation componentsSeparatedByString:@", "];
    NSRange detailIndex = [fullLocation rangeOfString:[splitLocation objectAtIndex:0]];
    NSUInteger index = detailIndex.length;    

    return [fullLocation substringFromIndex:index+2];
    
}

- (CLLocationCoordinate2D) coordinate {
    
    CLLocationCoordinate2D position;
    position.latitude = [[self.location valueForKey:FLICKR_LATITUDE] doubleValue];
    position.longitude = [[self.location valueForKey:FLICKR_LONGITUDE] doubleValue];
    
    return position;
}



@end
