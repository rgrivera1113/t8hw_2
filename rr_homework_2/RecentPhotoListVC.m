//
//  RecentPhotoListVC.m
//  rr_homework_2
//
//  Created by Robert Rivera on 6/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RecentPhotoListVC.h"
#import "FlickrFetcher.h"
#import "PhotoViewerVC.h"

@implementation RecentPhotoListVC

@synthesize photoList = _photoList;
@synthesize refreshButton = _refreshButton;

- (void) setPhotoList:(NSArray *)photoList {
    
    if (_photoList != photoList) {
        
        _photoList = photoList;
        
        if (self.tableView.window) 
            [self.tableView reloadData];
    }
    
}


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Get the recent photo log from the filesystem.
    // Build the URL for the recently viewed photo log.
    NSFileManager* fm = [NSFileManager defaultManager];
    NSArray* directory = [fm URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask];
    NSURL* filePath = [[directory objectAtIndex:0] URLByAppendingPathComponent:@"recent.plist" isDirectory:NO];
    
    NSMutableArray* recentCollection = [[[NSArray alloc] initWithContentsOfURL:filePath] mutableCopy];
    if (recentCollection == nil) {
        recentCollection = [[NSMutableArray alloc] initWithCapacity:20];
    }
    self.photoList = recentCollection;
    [self.tableView reloadData];
    

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    NSFileManager* fm = [NSFileManager defaultManager];
    NSArray* directory = [fm URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask];
    NSURL* filePath = [[directory objectAtIndex:0] URLByAppendingPathComponent:@"recent.plist" isDirectory:NO];
    
    NSMutableArray* recentCollection = [[[NSArray alloc] initWithContentsOfURL:filePath] mutableCopy];
    if (recentCollection == nil) {
        recentCollection = [[NSMutableArray alloc] initWithCapacity:20];
    }
    self.photoList = [recentCollection copy];
    [self.tableView reloadData];
    
    
    
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"PresentRecentImage"]) {
        
        // Set the photo to be shown.
        NSIndexPath* selected = [self.tableView indexPathForSelectedRow];
        [(PhotoViewerVC*) segue.destinationViewController setPhoto:[self.photoList objectAtIndex:selected.row]];
        [(PhotoViewerVC*) segue.destinationViewController setTitle:[[self.photoList objectAtIndex:selected.row] valueForKey:FLICKR_PHOTO_TITLE]];
        
    }
    
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
    static NSString *CellIdentifier = @"RecentCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    // Configure the cell...
    
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
