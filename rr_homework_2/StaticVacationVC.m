//
//  StaticVacationVC.m
//  rr_homework_2
//
//  Created by Robert Rivera on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StaticVacationVC.h"

@interface StaticVacationVC ()

@end

@implementation StaticVacationVC

@synthesize parentDelegate = _parentDelegate;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) viewWillAppear:(BOOL)animated {
    
    self.navigationItem.title = [[self.parentDelegate selectedURL] lastPathComponent];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    // Pass the selected URL from the delegate.
    if ([segue.identifier isEqualToString:@"TagSearchSegue"])
    {
        
    } else if ([segue.identifier isEqualToString:@"ItinerarySegue"]) {
        
    }
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    if (indexPath.row == 0)
        cell.textLabel.text = @"Itinerary";
    else if (indexPath.row == 1)
        cell.textLabel.text = @"Tag Search";
    
    return cell;
}

#pragma mark - Table view delegate

- (NSURL*) selectedURL {
    
    return [self.parentDelegate selectedURL];
    
}

@end
