//
//  PhotoViewerVC.m
//  rr_homework_2
//
//  Created by Robert Rivera on 6/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotoViewerVC.h"
#import "FlickrFetcher.h"
#import "FlickrCacher.h"
#import "PhotoListVC.h"
#import "PhotoViewerDataSource.h"

@interface PhotoViewerVC ()

@property (nonatomic,weak) IBOutlet UIScrollView* photoScroll;
@property (nonatomic,weak) IBOutlet UIImageView* photoView;
@property (nonatomic,weak) IBOutlet UIToolbar* rotationBar;
@property (nonatomic,weak) IBOutlet UIBarButtonItem* photoTitle;
@property (nonatomic,weak) IBOutlet UIActivityIndicatorView* loadingIndicator;

@end

@implementation PhotoViewerVC

@synthesize photo = _photo;
@synthesize photoScroll = _photoScroll;
@synthesize photoView = _photoView;
@synthesize rotationBar = _rotationBar;
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;
@synthesize photoTitle = _photoTitle;
@synthesize loadingIndicator = _loadingIndicator;
@synthesize photoDelegate = _photoDelegate;

# pragma mark <splitviewpresenter> implementation
- (void) handlePopoverBarButton: (UIBarButtonItem*) barButtonItem {
    
    // Remove the current items in the toolbar and replace them
    // with the new bar button item.
    NSMutableArray *toolbarItems = [[NSMutableArray alloc] initWithArray:self.rotationBar.items];
    
    if (_splitViewBarButtonItem) 
        [toolbarItems removeObject:_splitViewBarButtonItem];
    
    if (barButtonItem) 
        [toolbarItems insertObject:barButtonItem atIndex:0];
    
    self.rotationBar.items = [toolbarItems copy];
    
    _splitViewBarButtonItem = barButtonItem;
    
}

- (void)setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem
{
    if (splitViewBarButtonItem != _splitViewBarButtonItem)
        [self handlePopoverBarButton:splitViewBarButtonItem];
}

- (void) setPhoto:(NSDictionary *)photo {
    
    if (_photo != photo)
        _photo = photo;
}

- (UIActivityIndicatorView*) loadingIndicator {
    
    if (!_loadingIndicator)
        self.loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    return _loadingIndicator;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    // Grab the URL for the photo and kick off the image load.
    // When the load is finished, create an image view and add to the scrollview.
    NSURL* photoURL = [FlickrFetcher urlForPhoto:self.photo format:FlickrPhotoFormatOriginal];
    // Set all of the values for the toolbar.
    [self handlePopoverBarButton:self.splitViewBarButtonItem];
    NSString* photoTitle = [self.photo valueForKey:FLICKR_PHOTO_TITLE];
    NSString* photoDescription = [self.photo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
    if (photoTitle.length < 1) {
        if (photoDescription.length > 0)
            self.photoTitle.title = photoDescription;
        else 
            self.photoTitle.title = @"Unknown";
    } else {
        self.photoTitle.title = photoTitle;
    }
    self.navigationItem.title = photoTitle;

    // Start the activity indicator before kicking off the load block.
    self.loadingIndicator.color = [UIColor blackColor];
    self.loadingIndicator.hidesWhenStopped = YES;
    [self.loadingIndicator startAnimating];
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("flickr downloader", NULL);
    dispatch_async(downloadQueue, ^{

        NSString* fileName = [self.photo valueForKey:FLICKR_PHOTO_ID];
        NSData* requestedImage = [FlickrCacher grabPhotoFromCache:fileName];
        NSLog(@"Looking for image %@ in cache.",fileName);
        
        if (!requestedImage) {
            NSLog(@"Image not in cache.  Going to Flickr.");
            requestedImage = [NSData dataWithContentsOfURL:photoURL];
        } else
            NSLog(@"Image in cache.");

        if (![self.photoDelegate displayedPhoto]) {
        
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.loadingIndicator stopAnimating];            
            });
            
        }
        else if (self.photo == [self.photoDelegate displayedPhoto]) {
            
            // Only cache the image if it is still selected.
            dispatch_queue_t cacheWriter = dispatch_queue_create("cache writer", NULL);
            dispatch_async(cacheWriter, ^{
                
                NSLog(@"Sending %@ to cache.",fileName);
                [FlickrCacher sendPhotoToCache:requestedImage as:fileName];
                
            });
            
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage* image = [UIImage imageWithData:requestedImage];
                self.photoView.image = image;
                self.photoScroll.contentSize = self.photoView.image.size;
                [self.photoScroll zoomToRect:CGRectMake(0, 0, 
                                                        self.photoScroll.contentSize.width, 
                                                        self.photoScroll.contentSize.height) 
                                    animated:NO];
                [self.loadingIndicator stopAnimating];            
            });
        } 
    });
    dispatch_release(downloadQueue);
    
}

- (UIView*) viewForZoomingInScrollView:(UIScrollView *)scrollView {
    
    return self.photoView;
    
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    
    CGSize scaledSize = CGSizeMake(self.photoView.image.size.width * self.photoScroll.zoomScale, self.photoView.image.size.height * self.photoScroll.zoomScale);
    self.photoScroll.contentSize = scaledSize;
    
}

@end
