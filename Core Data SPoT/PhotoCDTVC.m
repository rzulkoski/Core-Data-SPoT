//
//  PhotoCDTVC.m
//  Core Data SPoT
//
//  Created by Ryan Zulkoski on 3/13/13.
//  Copyright (c) 2013 RZGamer. All rights reserved.
//

#import "PhotoCDTVC.h"
#import "Photo+Flickr.h"
#import "Thumbnail+Create.h"

@implementation PhotoCDTVC

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    if (managedObjectContext) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
        if (self.fetchLimit) request.fetchLimit = [self.fetchLimit intValue];
        request.sortDescriptors = @[self.sortDescriptor];
        request.predicate = self.predicate;
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    } else {
        self.fetchedResultsController = nil;
    }
}

#pragma mark - UITableViewDataSource

// Uses NSFetchedResultsController's objectAtIndexPath: to find the Photo for this row in the table.
// Then uses that Photo to set the cell up.

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Photo"];
    
    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = photo.title;
    cell.detailTextLabel.text = photo.subtitle;
    cell.imageView.image = [photo thumbnailImage];
    
    return cell;
}

#pragma mark - Segue

// Gets the NSIndexPath of the UITableViewCell which is sender.
// Then uses that NSIndexPath to find the Photo in question using NSFetchedResultsController.
// Prepares a destination view controller through the "setPhoto:" segue by sending that to it.

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = nil;
    
    NSLog(@"In prepare for segue");
    
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        indexPath = [self.tableView indexPathForCell:sender];
    }
    
    if (indexPath) {
        if ([segue.identifier isEqualToString:@"setPhoto:"]) {
            if ([segue.destinationViewController respondsToSelector:@selector(setPhoto:)]) {
                Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
                photo.lastViewed = [NSDate date];
                NSURL *imageURL = [NSURL URLWithString:photo.imageURL];
                NSDictionary *photoDictionary = @{ @"id" : photo.unique,
                                                   @"originalformat" : photo.originalFormat,
                                                   @"imageURL" : imageURL };
                [segue.destinationViewController performSelector:@selector(setPhoto:) withObject:photoDictionary];
                if ([segue.destinationViewController respondsToSelector:@selector(setTitle:)]) {
                    [segue.destinationViewController performSelector:@selector(setTitle:) withObject:photo.title];
                }
            }
        }
    }
}

@end
