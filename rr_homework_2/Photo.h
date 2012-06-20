//
//  Photo.h
//  rr_homework_2
//
//  Created by Robert Rivera on 6/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Place, Tag;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSNumber * latitidue;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * photo_id;
@property (nonatomic, retain) NSString * subtitle;
@property (nonatomic, retain) NSString * photo_title;
@property (nonatomic, retain) NSString * photo_url;
@property (nonatomic, retain) Place *photo_place;
@property (nonatomic, retain) NSSet *photo_tags;
@end

@interface Photo (CoreDataGeneratedAccessors)

- (void)addPhoto_tagsObject:(Tag *)value;
- (void)removePhoto_tagsObject:(Tag *)value;
- (void)addPhoto_tags:(NSSet *)values;
- (void)removePhoto_tags:(NSSet *)values;

@end
