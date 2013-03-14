//
//  RecentPhotosCDTVC.m
//  Core Data SPoT
//
//  Created by Ryan Zulkoski on 3/13/13.
//  Copyright (c) 2013 RZGamer. All rights reserved.
//

#import "RecentPhotosCDTVC.h"

#define CORE_DATA_MDOC_NAME @"Core Data Document"
#define MAX_RECENT_PHOTOS 10

@implementation RecentPhotosCDTVC

#pragma mark - View Controller Lifecycle

// Just sets the Refresh Control's target/action since it can't be set in Xcode (bug?).

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"lastViewed"
                                                        ascending:NO
                                                         selector:@selector(compare:)];
    self.fetchLimit = @(MAX_RECENT_PHOTOS);
}

// Whenever the table is about to appear, if we have not yet opened/created or demo document, do so.

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.managedObjectContext) {
        [self useCoreDataDocument];
    }
}

// Either creates, opens or just uses the core data document
//   (actually, it will never "just use" it since it just creates the UIManagedDocument instance here;
//    the "just uses" case is just shown that if someone hands you a UIManagedDocument, it might already
//    be open and so you can just use it if it's documentState is UIDocumentStateNormal).
//
// Creating and opening are asynchronous, so in the completion handler we set our Model (managedObjectContext).

- (void)useCoreDataDocument
{
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    url = [url URLByAppendingPathComponent:CORE_DATA_MDOC_NAME];
    UIManagedDocument *document = [[UIManagedDocument alloc] initWithFileURL:url];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[url path]]) {
        [document saveToURL:url
           forSaveOperation:UIDocumentSaveForCreating
          completionHandler:^(BOOL success) {
              if (success) {
                  self.managedObjectContext = document.managedObjectContext;
              }
          }];
    } else if (document.documentState == UIDocumentStateClosed) {
        [document openWithCompletionHandler:^(BOOL success) {
            if (success) {
                self.managedObjectContext = document.managedObjectContext;
            }
        }];
    } else {
        self.managedObjectContext = document.managedObjectContext;
    }
}


@end
