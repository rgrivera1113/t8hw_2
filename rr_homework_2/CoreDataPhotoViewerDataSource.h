//
//  CoreDataPhotoViewerDataSource.h
//  rr_homework_2
//
//  Created by Robert Rivera on 6/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Photo+Create.h"

@protocol CoreDataPhotoViewerDataSource <NSObject>

- (Photo*) displayedPhoto;

@end
