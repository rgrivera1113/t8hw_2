//
//  LocationAnnotation.h
//  rr_homework_2
//
//  Created by Robert Rivera on 6/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface LocationAnnotation : NSObject <MKAnnotation>

@property (nonatomic,strong) NSDictionary* location;

+ (LocationAnnotation*) annotationForLocation: (NSDictionary*) photo;

@end
