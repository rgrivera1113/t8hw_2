//
//  ViewController.m
//  rr_homework_2
//
//  Created by Robert Rivera on 5/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlacesVC.h"
#import "FlickrFetcher.h"
#import "GeoPhotoListVC.h"
#import "SplitViewPresenter.h"
#import "LocationAnnotation.h"

@interface PlacesVC ()

@property (nonatomic,weak) IBOutlet UITableView* tableView;
@property (nonatomic,weak) IBOutlet MKMapView* mapView;
@property (nonatomic,weak) IBOutlet UIView* rootView;

@end

@implementation PlacesVC

@synthesize tableView = _tableView;
@synthesize mapView = _mapView;
@synthesize rootView = _rootView;

- (IBAction)refresh:(id)sender
{
    
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [spinner startAnimating];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    }
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("flickr downloader", NULL);
    dispatch_async(downloadQueue, ^{
        NSArray *photos = [FlickrFetcher topPlaces];
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
        [annotations addObject:[LocationAnnotation annotationForLocation:photo]];
    }
    
    if (self.mapView.annotations) 
        [self.mapView removeAnnotations:self.mapView.annotations];
    
    if (annotations) 
        [self.mapView addAnnotations:annotations];

    
}

- (void) setPhotoList:(NSArray *)photoList {
    
    if (self.photoList != photoList) {
        [super setPhotoList:photoList];
        [self.tableView reloadData];
        [self updateMapData];
    }
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
- (void) viewDidLoad {
    [super viewDidLoad];
    self.mapView.delegate = self;
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
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (IBAction)presentSubView:(id)sender {
    
    if (self.chooser.selectedSegmentIndex == 0) {
        
        [self.view bringSubviewToFront:self.tableView];
        
    } else if (self.chooser.selectedSegmentIndex == 1) {
        
        [self.view bringSubviewToFront:self.mapView];
        
    }
    
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"PresentGeoPhotoList"]) {
        
        NSDictionary* location;
        if ([sender isKindOfClass:[LocationAnnotation class]]) {
            
            location = [(LocationAnnotation*) sender location];
            
        } else {
            
            NSIndexPath* selected = [self.tableView indexPathForSelectedRow];
            location = [self.photoList objectAtIndex:selected.row];
        }
        
        [(GeoPhotoListVC*) segue.destinationViewController setPhotoLocation:location];
        
    }
    
    
}

#pragma mark - Table Datasource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"PlaceCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    NSDictionary *location = [self.photoList objectAtIndex:indexPath.row];
    NSString* fullLocation = [location objectForKey:FLICKR_PLACE_NAME];
    NSArray* splitLocation = [fullLocation componentsSeparatedByString:@", "];
    cell.textLabel.text = [splitLocation objectAtIndex:0];
    NSRange detailIndex = [fullLocation rangeOfString:[splitLocation objectAtIndex:0]];
    NSUInteger index = detailIndex.length;
    
    cell.detailTextLabel.text = [fullLocation substringFromIndex:index+2];
    
    return cell;
    
}

#pragma mark - Map View Delegate
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKAnnotationView *aView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"MapVC"];
    if (!aView) {
        aView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"MapVC"];
        aView.canShowCallout = YES;
        aView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    }
    
    aView.annotation = annotation;
    
    return aView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    
    [self performSegueWithIdentifier:@"PresentGeoPhotoList" sender:view.annotation];
    
}




@end
