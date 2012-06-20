//
//  ImageViewerVC.m
//  rr_homework_2
//
//  Created by Robert Rivera on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ImageViewerVC.h"
#import "FlickrFetcher.h"
#import "VacationListPopoverVC.h"

@interface ImageViewerVC ()

@property (nonatomic,weak) IBOutlet UIToolbar* rotationBar;
@property (nonatomic,weak) IBOutlet UIBarButtonItem* photoTitle;
@property (nonatomic,weak) IBOutlet UIActivityIndicatorView* loadingIndicator;

@end

@implementation ImageViewerVC

@synthesize photo = _photo;
@synthesize photoDelegate = _photoDelegate;
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;
@synthesize rotationBar = _rotationBar;
@synthesize photoTitle = _photoTitle;
@synthesize loadingIndicator = _loadingIndicator;
@synthesize photoScroll = _photoScroll;
@synthesize photoView = _photoView;
@synthesize vcp = _vcp;

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

- (void) refreshSplitView: (NSString*) photoTitle {
    
    [self handlePopoverBarButton:self.splitViewBarButtonItem];
    self.photoTitle.title = photoTitle;
}

- (NSString*) updatePhotoTitle {
    
    NSString* photoTitle = [self.photo valueForKey:FLICKR_PHOTO_TITLE];
    NSString* photoDescription = [self.photo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
    if (photoTitle.length < 1) {
        if (photoDescription.length > 0)
            self.photoTitle.title = [photoDescription substringToIndex:25];
        else 
            self.photoTitle.title = @"Unknown";
    } else {
        self.photoTitle.title = photoTitle;
    }
    
    return photoTitle;
    
}


- (void) animateLoadingIndicator: (BOOL) setting {
    
    if (setting)
        [self.loadingIndicator startAnimating];
    else
        [self.loadingIndicator stopAnimating];
    
}


- (void) setPhoto:(NSDictionary *)photo {
    
    if (_photo != photo)
        _photo = photo;
}

- (UIActivityIndicatorView*) loadingIndicator {
    
    if (!_loadingIndicator) 
        self.loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    _loadingIndicator.color = [UIColor blackColor];
    _loadingIndicator.hidesWhenStopped = YES;
        
    
    return _loadingIndicator;
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

- (UIView*) viewForZoomingInScrollView:(UIScrollView *)scrollView {
    
    return self.photoView;
    
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    
    CGSize scaledSize = CGSizeMake(self.photoView.image.size.width * self.photoScroll.zoomScale, self.photoView.image.size.height * self.photoScroll.zoomScale);
    self.photoScroll.contentSize = scaledSize;
    
}

- (IBAction)presentVacationListPopover:(id)sender {
    
    // If a photo is not displayed, don't present the popover.
    if (self.photo) {
        if (self.vcp) {
            [self.vcp dismissPopoverAnimated:YES];
            self.vcp = nil;
        }
        else 
            [self performSegueWithIdentifier:@"VacationListPopover" sender:sender];
    }
    
}

- (void) popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    
    self.vcp = nil;
    
}

@end
