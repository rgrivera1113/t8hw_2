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
#import "ImageAnnotations.h"

@interface RecentPhotoListVC ()

@property (nonatomic,weak) IBOutlet UITableView* tableView;
@property (nonatomic,weak) IBOutlet MKMapView* mapView;

@end

@implementation RecentPhotoListVC

@synthesize refreshButton = _refreshButton;
@synthesize tableView = _tableView;
@synthesize mapView = _mapView;

- (void) updateMapData {
    
    // use the photolist to update the mapview annotations.
    NSMutableArray *annotations = [NSMutableArray arrayWithCapacity:[self.photoList count]];
    for (NSDictionary *photo in self.photoList) {
        [annotations addObject:[ImageAnnotations annotationForPhoto:photo]];
    }
    
    if (self.mapView.annotations) 
        [self.mapView removeAnnotations:self.mapView.annotations];
    
    if (annotations) 
        [self.mapView addAnnotations:annotations];
    
    
}

- (void) setPhotoList:(NSArray *)photoList {
    
    [super setPhotoList:photoList];
    if (self.tableView.window) 
        [self.tableView reloadData];
    
    [self updateMapData];
    
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
    
    [self presentSubView:nil];
    
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

- (NSDictionary*) displayedPhoto {
    
    if (self.tableView.indexPathForSelectedRow)
        return [self displayedPhoto:self.tableView.indexPathForSelectedRow];
    else if ([self.mapView selectedAnnotations])
        return [[[self.mapView selectedAnnotations] objectAtIndex:0] photo];
    else
        return nil;
    
}


- (void)moveBarButtonItemTo:(id)destinationViewController
{
    UIBarButtonItem *splitViewBarButtonItem = [[self splitViewPhotoDetail] splitViewBarButtonItem];
    [[self splitViewPhotoDetail] setSplitViewBarButtonItem:nil];
    if (splitViewBarButtonItem) {
        [destinationViewController setSplitViewBarButtonItem:splitViewBarButtonItem];
    }
}

- (IBAction)presentSubView:(id)sender {
    
    if (self.chooser.selectedSegmentIndex == 0) {
        
        [self.view bringSubviewToFront:self.tableView];
        
    } else if (self.chooser.selectedSegmentIndex == 1) {
        
        [self.view bringSubviewToFront:self.mapView];
        
    }
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"PresentRecentImage"]) {
        
        // Set the photo to be shown.
        if ([sender isKindOfClass:[ImageAnnotations class]]) {
            
            [(PhotoViewerVC*) segue.destinationViewController setPhotoDelegate:self];
            [(PhotoViewerVC*) segue.destinationViewController setPhoto:[(ImageAnnotations*) sender photo]];
        }   else {
            NSIndexPath* selected = [self.tableView indexPathForSelectedRow];
            [(PhotoViewerVC*) segue.destinationViewController setPhotoDelegate:self];
            [(PhotoViewerVC*) segue.destinationViewController setPhoto:[self.photoList objectAtIndex:selected.row]];
        }
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

#pragma mark - Map View Delegate
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    
    MKAnnotationView *aView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"MapVC"];
    if (!aView) {
        aView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"MapVC"];
        aView.canShowCallout = YES;
        aView.leftCalloutAccessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        aView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    }
    
    aView.annotation = annotation;
    [(UIImageView *)aView.leftCalloutAccessoryView setImage:nil];
    
    return aView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)aView
{
    
    dispatch_queue_t thumbnailFetch = dispatch_queue_create("get thumbnail", NULL);
    
    dispatch_async(thumbnailFetch, ^{
        ImageAnnotations *ia = (ImageAnnotations*)aView.annotation;
        NSURL *url = [FlickrFetcher urlForPhoto:ia.photo format:FlickrPhotoFormatSquare];
        NSData *data = [NSData dataWithContentsOfURL:url];
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *image = [UIImage imageWithData:data];
            [(UIImageView *)aView.leftCalloutAccessoryView setImage:image];
        });
    });
    dispatch_release(thumbnailFetch);
    
    
}


- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    
    [self performSegueWithIdentifier:@"PresentRecentImage" sender:view.annotation];
    
}

@end
