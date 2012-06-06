//
//  PhotoListVC.m
//  rr_homework_2
//
//  Created by Robert Rivera on 6/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GeoPhotoListVC.h"
#import "FlickrFetcher.h"
#import "PhotoViewerVC.h"
#import "SplitViewPresenter.h"

@interface GeoPhotoListVC ()

@property (nonatomic,weak) IBOutlet UITableView* tableView;


@end

@implementation GeoPhotoListVC

@synthesize refreshButton = _refreshButton;
@synthesize photoLocation = _photoLocation;
@synthesize tableView = _tableView;

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
    
    [super setPhotoList:photoList];
    if (self.tableView.window) 
        [self.tableView reloadData];
    
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
- (id<SplitViewPresenter>) splitViewPhotoDetail {
    
    id photoVC = [self.splitViewController.viewControllers lastObject];
    if (![photoVC conformsToProtocol:@protocol(SplitViewPresenter)]) {
        photoVC = nil;
    }
    return photoVC;
    
    
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
    
    // Rename the popover in the rotation toolbar.
    id detailView = [self splitViewPhotoDetail];
    if (detailView) {
        UIBarButtonItem* button = [detailView splitViewBarButtonItem];
        if (button) {
            button.title = self.navigationItem.title;
        }
    }
    
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (void)moveBarButtonItemTo:(id)destinationViewController
{
    UIBarButtonItem *splitViewBarButtonItem = [[self splitViewPhotoDetail] splitViewBarButtonItem];
    [[self splitViewPhotoDetail] setSplitViewBarButtonItem:nil];
    if (splitViewBarButtonItem) {
        [destinationViewController setSplitViewBarButtonItem:splitViewBarButtonItem];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"PresentGeoImage"]) {
        
        // Set the photo to be shown.
        NSIndexPath* selected = [self.tableView indexPathForSelectedRow];
        [(PhotoViewerVC*) segue.destinationViewController setPhoto:[self.photoList objectAtIndex:selected.row]];
        // Rename the popover in the rotation toolbar.
        id detailView = [self splitViewPhotoDetail];
        if (detailView) {
            UIBarButtonItem* button = [detailView splitViewBarButtonItem];
            if (button) {
                button.title = self.navigationItem.title;
            }
        }
        [self moveBarButtonItemTo:segue.destinationViewController];
        
    }
    
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Build the URL for the recently viewed photo log.
    dispatch_queue_t saveRecentQueue = dispatch_queue_create("save recent", NULL);
    dispatch_async(saveRecentQueue, ^{
        
        NSFileManager* fm = [NSFileManager defaultManager];
        NSArray* directory = [fm URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask];
        NSURL* filePath = [[directory objectAtIndex:0] URLByAppendingPathComponent:@"recent.plist" isDirectory:NO];
        
        NSMutableArray* recentCollection = [[[NSArray alloc] initWithContentsOfURL:filePath] mutableCopy];
        NSString* photoCandidate = [[self.photoList objectAtIndex:indexPath.row] objectForKey:FLICKR_PHOTO_ID];
        BOOL exists = NO;
        
        NSString* pid;
        for (NSDictionary* photo in recentCollection) {
            pid = [photo objectForKey:FLICKR_PHOTO_ID];
            if ([photoCandidate isEqualToString:pid]) {
                exists = YES;
                break;
            }
        }
        
        if (!exists) {
            if (recentCollection == nil) {
                recentCollection = [[NSMutableArray alloc] initWithCapacity:20];
                [recentCollection insertObject:[self.photoList objectAtIndex:indexPath.row] atIndex:0];
            } else if (recentCollection.count < 20) {
                [recentCollection insertObject:[self.photoList objectAtIndex:indexPath.row] atIndex:0];
            } else {
                [recentCollection removeLastObject];
                [recentCollection insertObject:[self.photoList objectAtIndex:indexPath.row] atIndex:0];
            }
            
            // Save the array back to the file.
            [[recentCollection copy] writeToURL:filePath atomically:YES];
        }
        
    });
    dispatch_release(saveRecentQueue);
}

@end
