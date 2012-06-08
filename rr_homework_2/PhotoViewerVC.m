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

@end

@implementation PhotoViewerVC

@synthesize photoScroll = _photoScroll;
@synthesize photoView = _photoView;

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
    // Set all of the values for the toolbar.
    self.navigationItem.title = [self refreshSplitView];
    // Start the activity indicator before kicking off the load block.
    [self animateLoadingIndicator:YES];

    dispatch_queue_t downloadQueue = dispatch_queue_create("flickr downloader", NULL);
    dispatch_async(downloadQueue, ^{

        NSString* fileName = [self.photo valueForKey:FLICKR_PHOTO_ID];
        NSData* requestedImage = [FlickrCacher grabPhotoFromCache:fileName];

        if (!requestedImage)
            requestedImage = [NSData dataWithContentsOfURL:[FlickrFetcher urlForPhoto:self.photo format:FlickrPhotoFormatOriginal]];

        if (![self.photoDelegate displayedPhoto]) {
        
            dispatch_async(dispatch_get_main_queue(), ^{
                [self animateLoadingIndicator:NO];
            });
            
        }
        else if (self.photo == [self.photoDelegate displayedPhoto]) {
            
            // Only cache the image if it is still selected.
            dispatch_queue_t cacheWriter = dispatch_queue_create("cache writer", NULL);
            dispatch_async(cacheWriter, ^{
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
                [self animateLoadingIndicator:NO];
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
