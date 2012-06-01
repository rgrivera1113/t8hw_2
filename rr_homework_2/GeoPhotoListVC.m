//
//  PhotoListVC.m
//  rr_homework_2
//
//  Created by Robert Rivera on 6/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GeoPhotoListVC.h"
#import "FlickrFetcher.h"

@implementation GeoPhotoListVC

@synthesize photoList = _photoList;
@synthesize refreshButton = _refreshButton;
@synthesize photoLocation = _photoLocation;

#pragma mark - View lifecycle

- (IBAction)refresh:(id)sender
{
    
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [spinner startAnimating];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    }
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("flickr downloader", NULL);
    dispatch_async(downloadQueue, ^{
        NSArray *photos = [FlickrFetcher photosInPlace:self.photoLocation maxResults:50];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.navigationItem.rightBarButtonItem = sender;
            self.photoList = photos;
        });
    });
    dispatch_release(downloadQueue);
}


- (void) setPhotoList:(NSArray *)photoList {
    
    if (_photoList != photoList) {
        
        _photoList = photoList;
        
        if (self.tableView.window) 
            [self.tableView reloadData];
    }
    
}

- (void) setRefreshButton: (UIBarButtonItem*) button{
    
    if (_refreshButton != button) {
    
        _refreshButton = button;
        
        if (!_refreshButton)
            self.refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh 
                                                                               target:self 
                                                                               action:@selector(refresh:)];
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
     self.refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh 
                                                                       target:self 
                                                                       action:@selector(refresh:)];
    self.navigationItem.rightBarButtonItem = self.refreshButton;
    self.navigationItem.title = [self.photoLocation objectForKey:FLICKR_PLACE_NAME];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refresh:self.refreshButton];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

#pragma mark - Table view data source

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
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary* photo = [self.photoList objectAtIndex:indexPath.row];
    NSString* photoTitle = [photo valueForKey:FLICKR_PHOTO_TITLE];
    NSString* photoDescription = [photo valueForKey:FLICKR_PHOTO_DESCRIPTION];
    
    if (photoTitle.length < 1) {
        if (photoDescription.length > 0)
            cell.textLabel.text = photoDescription;
        else 
            cell.textLabel.text = @"Unknown";
    } else {
        cell.textLabel.text = photoTitle;
        if (photoDescription.length > 0)
            cell.detailTextLabel.text = photoDescription;
    }
        
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
