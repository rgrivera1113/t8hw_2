//
//  PhotoViewerVC.m
//  rr_homework_2
//
//  Created by Robert Rivera on 6/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotoViewerVC.h"
#import "FlickrFetcher.h"

@interface PhotoViewerVC ()

@property (nonatomic,weak) IBOutlet UIScrollView* photoScroll;
@property (nonatomic,weak) IBOutlet UIImageView* photoView;
@property (nonatomic,weak) IBOutlet UIToolbar* rotationBar;
@property (nonatomic,weak) IBOutlet UIBarButtonItem* photoTitle;

@end

@implementation PhotoViewerVC

@synthesize photo = _photo;
@synthesize photoScroll = _photoScroll;
@synthesize photoView = _photoView;
@synthesize rotationBar = _rotationBar;
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;
@synthesize photoTitle = _photoTitle;

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
    
    //self.rotationBar. = [[self.photoList objectAtIndex:selected.row] valueForKey:FLICKR_PHOTO_TITLE]];
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("flickr downloader", NULL);
    dispatch_async(downloadQueue, ^{
        NSData* requestedImage = [NSData dataWithContentsOfURL:photoURL];
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage* image = [UIImage imageWithData:requestedImage];
            self.photoView.image = image;
            self.photoScroll.contentSize = self.photoView.image.size;
            [self.photoScroll zoomToRect:CGRectMake(0, 0, 
                                                    self.photoScroll.contentSize.width, 
                                                    self.photoScroll.contentSize.height) 
                                animated:NO];
        });
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
