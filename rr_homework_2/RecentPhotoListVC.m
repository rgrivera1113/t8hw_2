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

@interface RecentPhotoListVC ()

@property (nonatomic,weak) IBOutlet UITableView* tableView;

@end

@implementation RecentPhotoListVC

@synthesize refreshButton = _refreshButton;
@synthesize tableView = _tableView;

- (void) setPhotoList:(NSArray *)photoList {
    
    [super setPhotoList:photoList];
    if (self.tableView.window) 
        [self.tableView reloadData];
    
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
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (id<SplitViewPresenter>) splitViewPhotoDetail {
    
    id photoVC = [self.splitViewController.viewControllers lastObject];
    if (![photoVC conformsToProtocol:@protocol(SplitViewPresenter)]) {
        photoVC = nil;
    }
    return photoVC;

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
    
    if ([segue.identifier isEqualToString:@"PresentRecentImage"]) {
        
        // Set the photo to be shown.
        NSIndexPath* selected = [self.tableView indexPathForSelectedRow];
        [(PhotoViewerVC*) segue.destinationViewController setPhoto:[self.photoList objectAtIndex:selected.row]];
        [(PhotoViewerVC*) segue.destinationViewController setTitle:[[self.photoList objectAtIndex:selected.row] valueForKey:FLICKR_PHOTO_TITLE]];
        // Move the popover bar button item to new view.
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
@end
