//
//  PhotoViewerDataSource.h
//  rr_homework_2
//
//  Created by Robert Rivera on 6/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PhotoViewerDataSource <NSObject>

- (NSDictionary*) displayedPhoto;

@end
