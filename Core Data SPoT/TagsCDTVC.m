//
//  TagsCDTVC.m
//  Core Data SPoT
//
//  Created by Ryan Zulkoski on 3/13/13.
//  Copyright (c) 2013 RZGamer. All rights reserved.
//

#import "TagsCDTVC.h"
#import "Tag.h"

@implementation TagsCDTVC

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    if (managedObjectContext) {
        NSLog(@"About to fetch tags from database");
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tag"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
        request.predicate = nil; // all Photos
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Tag"];
    
    Tag *tag = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [tag.name capitalizedString];
    int numberOfPhotosWithTag = [tag.photos count];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d Photo%@", numberOfPhotosWithTag, numberOfPhotosWithTag == 1 ? @"" : @"s"];
    
    return cell;
}

#pragma mark - Segue

// Gets the NSIndexPath of the UITableViewCell which is sender.
// Then uses that NSIndexPath to find the Photo in question using NSFetchedResultsController.
// Prepares a destination view controller through the "setPhoto:" segue by sending that to it.

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = nil;
    
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        indexPath = [self.tableView indexPathForCell:sender];
    }
    
    if (indexPath) {
        if ([segue.identifier isEqualToString:@"setTag:"]) {
            Tag *tag = [self.fetchedResultsController objectAtIndexPath:indexPath];
            if ([segue.destinationViewController respondsToSelector:@selector(setTag:)]) {
                [segue.destinationViewController performSelector:@selector(setTag:) withObject:tag];
            }
            if ([segue.destinationViewController respondsToSelector:@selector(setManagedObjectContext:)]) {
                [segue.destinationViewController performSelector:@selector(setManagedObjectContext:) withObject:self.managedObjectContext];
            }
        }
    }
}

@end
