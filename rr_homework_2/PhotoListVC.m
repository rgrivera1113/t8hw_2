//
//  PhotoListVCViewController.m
//  rr_homework_2
//
//  Created by Robert Rivera on 6/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotoListVC.h"
#import "SplitViewPresenter.h"
#import "FlickrFetcher.h"
@interface PhotoListVC ()

@end

@implementation PhotoListVC

@synthesize photoList = _photoList;


- (void) setPhotoList:(NSArray *)photoList {
    
    if (photoList != _photoList)
        _photoList = photoList;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.photoList.count; 
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PhotoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary* photo = [self.photoList objectAtIndex:indexPath.row];
    NSString* photoTitle = [photo valueForKey:FLICKR_PHOTO_TITLE];
    NSString* photoDescription = [photo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
    
    if (photoTitle.length < 1) {
        if (photoDescription.length > 0)
            cell.textLabel.text = photoDescription;
        else 
            cell.textLabel.text = @"Unknown";
        cell.detailTextLabel.text = @"";
    } else {
        cell.textLabel.text = photoTitle;
        if (photoDescription.length > 0)
            cell.detailTextLabel.text = photoDescription;
        else
            cell.detailTextLabel.text = @"";
    }
    
    return cell;
}

@end
