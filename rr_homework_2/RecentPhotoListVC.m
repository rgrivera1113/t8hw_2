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

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    dispatch_queue_t displayListQueue = dispatch_queue_create("recent display", NULL);
    dispatch_async(displayListQueue, ^{
        
        NSFileManager* fm = [NSFileManager defaultManager];
        NSArray* directory = [fm URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask];
        NSURL* filePath = [[directory objectAtIndex:0] URLByAppendingPathComponent:@"recent.plist" isDirectory:NO];
        
        NSMutableArray* recentCollection = [[[NSArray alloc] initWithContentsOfURL:filePath] mutableCopy];
        if (recentCollection == nil) {
            recentCollection = [[NSMutableArray alloc] initWithCapacity:20];
        }
        self.photoList = recentCollection;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
    dispatch_release(displayListQueue);
    
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

- (NSDictionary*) displayedPhoto {
    
    if (self.tableView.indexPathForSelectedRow)
        return [self displayedPhoto:self.tableView.indexPathForSelectedRow];
    else
        return nil;
    
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
        [(PhotoViewerVC*) segue.destinationViewController setPhotoDelegate:self];
        [(PhotoViewerVC*) segue.destinationViewController setPhoto:[self.photoList objectAtIndex:selected.row]];
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
