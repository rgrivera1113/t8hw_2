//
//  VacationListVC.m
//  rr_homework_2
//
//  Created by Robert Rivera on 6/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VacationListVC.h"
#import "StaticVacationVC.h"

@interface VacationListVC () <UIAlertViewDelegate,SelectedURLDelegate>

@property (nonatomic,weak) IBOutlet UITableView* tableView;

@end

@implementation VacationListVC

@synthesize vacationList = _vacationList;
@synthesize tableView = _tableView;
@synthesize vacationButton = _vacationButton;

- (void) setVacationList:(NSArray *)vacationList {
    
    if (_vacationList != vacationList) {
        _vacationList = vacationList;
    }
    
    if (self.tableView.window)
        [self.tableView reloadData];
    
}

- (void) refreshVacationList {
    
    // Kick off a thread to get the contents of the Documents/Vacations directory.
    dispatch_queue_t loadVacationQueue = dispatch_queue_create("load vacations", NULL);
    dispatch_async(loadVacationQueue, ^{
        
        NSFileManager* fm = [[NSFileManager alloc] init];
        NSArray* directory = [fm URLsForDirectory: NSDocumentDirectory 
                                        inDomains: NSUserDomainMask];
        NSURL* filePath = [[directory objectAtIndex:0] URLByAppendingPathComponent:@"Vacations" isDirectory:YES];
        NSError* error;
        if ([fm createDirectoryAtURL:filePath withIntermediateDirectories:YES attributes:NULL error:&error])
            self.vacationList = [fm contentsOfDirectoryAtURL:filePath includingPropertiesForKeys:NULL options:NSDirectoryEnumerationSkipsHiddenFiles error:&error];
        
        // Once the work is done, move on with the segue.
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        
    });
    dispatch_release(loadVacationQueue);

    
}

- (void)viewDidLoad
{
    [super viewDidLoad];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) viewWillAppear:(BOOL)animated {
    
    [self refreshVacationList];
    
}

- (IBAction)presentVacationNameDialog:(id)sender {
    
    UIAlertView* uiav = [[UIAlertView alloc] initWithTitle:@"New Vacation" 
                                                   message:@"Enter new vacation name." 
                                                  delegate:self 
                                         cancelButtonTitle:@"Cancel" 
                                         otherButtonTitles:@"Save", nil];
    
    uiav.alertViewStyle = UIAlertViewStylePlainTextInput;
    [uiav show];
    
}

- (BOOL) vacationExists: (NSString*) vacationName {
    
    for (NSURL* url in self.vacationList) {
        
        if ([[url lastPathComponent] isEqualToString:vacationName])
            return YES;
    
    }
    
    return NO;
    
    
}

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    // Validate the contents of the text field and save.
    // If the filename is not valid (blank, already exists), present a new alert.
    if (buttonIndex != alertView.cancelButtonIndex) {
        if ([alertView textFieldAtIndex:0].text.length < 1) {
            
            UIAlertView* uiav = [[UIAlertView alloc] initWithTitle:@"Invalid Name" 
                                                           message:@"Enter new vacation name." 
                                                          delegate:self 
                                                 cancelButtonTitle:@"Cancel" 
                                                 otherButtonTitles:@"Save", nil];
            
            uiav.alertViewStyle = UIAlertViewStylePlainTextInput;
            [uiav show];
            
        } else if ([self vacationExists:[alertView textFieldAtIndex:0].text]){
            
            UIAlertView* uiav = [[UIAlertView alloc] initWithTitle:@"Duplicate Name" 
                                                           message:@"Enter new vacation name." 
                                                          delegate:self 
                                                 cancelButtonTitle:@"Cancel" 
                                                 otherButtonTitles:@"Save", nil];
            
            uiav.alertViewStyle = UIAlertViewStylePlainTextInput;
            [uiav show];
            
        } else {
            
            dispatch_queue_t vacationCreationQueue = dispatch_queue_create("create vacation", NULL);
            dispatch_async(vacationCreationQueue, ^{
                NSFileManager* fm = [[NSFileManager alloc] init];
                NSArray* directory = [fm URLsForDirectory: NSDocumentDirectory 
                                                inDomains: NSUserDomainMask];
                NSURL* filePath = [[directory objectAtIndex:0] URLByAppendingPathComponent:@"Vacations" 
                                                                               isDirectory:YES];
                NSString* fileName = [alertView textFieldAtIndex:0].text;
                filePath = [filePath URLByAppendingPathComponent:fileName 
                                                     isDirectory:NO];
                                
                dispatch_async(dispatch_get_main_queue(), ^{
                    // Create a new NSManagedObject with the filename and save to disk.
                    UIManagedDocument* doc = [[UIManagedDocument alloc] initWithFileURL:filePath];
                    [doc saveToURL:filePath forSaveOperation:UIDocumentSaveForCreating 
                 completionHandler:^(BOOL success) { [self refreshVacationList];}];
                });
            });
            dispatch_release(vacationCreationQueue);
            
        }
    }
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"StaticTableSegue"]) {
        
        if ([segue.destinationViewController isKindOfClass:[StaticVacationVC class]])
            [segue.destinationViewController setParentDelegate:self];
        
    }
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.vacationList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"VacationCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [[self.vacationList objectAtIndex:indexPath.row] lastPathComponent];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [self performSegueWithIdentifier:@"StaticTableSegue" sender:self];
    
}

- (NSURL*) selectedURL {
    
    return [self.vacationList objectAtIndex:[self.tableView indexPathForSelectedRow].row];
    
}

@end
