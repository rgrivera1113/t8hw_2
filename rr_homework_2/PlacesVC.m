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

@interface PlacesVC ()

@property (nonatomic,weak) IBOutlet UITableView* tableView;

@end

@implementation PlacesVC

@synthesize photoList = _photoList;
@synthesize refreshButton = _refreshButton;
@synthesize tableView = _tableView;

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


- (void) setPhotoList:(NSArray *)photoList {
    
    if (_photoList != photoList) {
        
        _photoList = photoList;
        
        if (self.tableView.window) 
            [self.tableView reloadData];
    }
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
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
    // Rename the popover in the rotation toolbar.
    id detailView = [self splitViewPhotoDetail];
    if (detailView) {
        UIBarButtonItem* button = [detailView splitViewBarButtonItem];
        if (button) {
            button.title = self.navigationItem.title;
        }
    }
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

- (id<SplitViewPresenter>) splitViewPhotoDetail {
    
    id photoVC = [self.splitViewController.viewControllers lastObject];
    if (![photoVC conformsToProtocol:@protocol(SplitViewPresenter)]) {
        photoVC = nil;
    }
    return photoVC;
    
    
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"PresentGeoPhotoList"]) {
        
        NSIndexPath* selected = [self.tableView indexPathForSelectedRow];
        [(GeoPhotoListVC*) segue.destinationViewController 
         setPhotoLocation:[self.photoList objectAtIndex:selected.row]];
    }
    
    
}

#pragma mark - Table Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.photoList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"PlaceCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    NSDictionary *photo = [self.photoList objectAtIndex:indexPath.row];
    NSString* fullLocation = [photo objectForKey:FLICKR_PLACE_NAME];
    NSArray* splitLocation = [fullLocation componentsSeparatedByString:@", "];
    cell.textLabel.text = [splitLocation objectAtIndex:0];
    NSRange detailIndex = [fullLocation rangeOfString:[splitLocation objectAtIndex:0]];
    NSUInteger index = detailIndex.length;
    
    cell.detailTextLabel.text = [fullLocation substringFromIndex:index+2];
    
    return cell;
    
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // Nothing happens here for this view.
    
}
@end
