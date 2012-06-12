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
@property (nonatomic,weak) IBOutlet MKMapView* mapView;


@end

@implementation GeoPhotoListVC

@synthesize photoLocation = _photoLocation;
@synthesize tableView = _tableView;
@synthesize mapView = _mapView;

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

- (NSDictionary*) displayedPhoto {
    
    if (self.tableView.indexPathForSelectedRow)
        return [self displayedPhoto:self.tableView.indexPathForSelectedRow];
    else if ([self.mapView selectedAnnotations])
        return [[[self.mapView selectedAnnotations] objectAtIndex:0] photo];
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

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // Set up map coordinates.
    double latitude = [[self.photoLocation valueForKey:FLICKR_LATITUDE]doubleValue];
    double longitude = [[self.photoLocation valueForKey:FLICKR_LONGITUDE]doubleValue];
    
    CLLocationCoordinate2D startCoord = CLLocationCoordinate2DMake(latitude, longitude);
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:MKCoordinateRegionMakeWithDistance(startCoord, 10000, 10000)];
    [self.mapView setRegion:adjustedRegion animated:YES];
    
    
    
    [self presentSubView:self];
    [self refresh:self.refreshButton];
    
    
    // Rename the popover in the rotation toolbar.
    id detailView = [self splitViewPhotoDetail];
    if (detailView) {
        UIBarButtonItem* button = [detailView splitViewBarButtonItem];
        if (button) {
            button.title = self.navigationItem.title;
        }
    }

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

- (IBAction)presentSubView:(id)sender {
    
    if (self.chooser.selectedSegmentIndex == 0) {
        
        [self.view bringSubviewToFront:self.tableView];
        
    } else if (self.chooser.selectedSegmentIndex == 1) {
        
        [self.view bringSubviewToFront:self.mapView];
        
    }
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"PresentGeoImage"]) {
        
        if ([sender isKindOfClass:[ImageAnnotations class]]) {
            
            [(PhotoViewerVC*) segue.destinationViewController setPhotoDelegate:self];
            [(PhotoViewerVC*) segue.destinationViewController setPhoto:[(ImageAnnotations*) sender photo]];
            
        } else {
            
            // Set the photo to be shown.
            NSIndexPath* selected = [self.tableView indexPathForSelectedRow];
            [(PhotoViewerVC*) segue.destinationViewController setPhotoDelegate:self];
            [(PhotoViewerVC*) segue.destinationViewController setPhoto:[self.photoList objectAtIndex:selected.row]];
            
        }
        
            
            
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
        // Once the work is done, move on with the segue.
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:@"PresentGeoImage" sender:self];
        });

    });
    dispatch_release(saveRecentQueue);
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
    
    [self performSegueWithIdentifier:@"PresentGeoImage" sender:view.annotation];
    
}


@end
