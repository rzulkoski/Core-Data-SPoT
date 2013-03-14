//
//  Thumbnail+Create.m
//  Core Data SPoT
//
//  Created by Ryan Zulkoski on 3/13/13.
//  Copyright (c) 2013 RZGamer. All rights reserved.
//

#import "Thumbnail+Create.h"
#import "Photo.h"
#include "RZTools.h"

@implementation Thumbnail (Create)

+ (Thumbnail *)thumbnailForPhoto:(Photo *)photo
          inManagedObjectContext:(NSManagedObjectContext *)context
{
    Thumbnail *thumbnail = nil;
    
    // This is just like Photo(Flickr)'s method.  Look there for commentary.
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Thumbnail"];
    request.predicate = [NSPredicate predicateWithFormat:@"photo.thumbnailURL = %@", photo.thumbnailURL];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || ([matches count] > 1)) {
        // handle error
    } else if (![matches count]) {
        NSLog(@"No thumbnail exists, create a new one");
        thumbnail = [NSEntityDescription insertNewObjectForEntityForName:@"Thumbnail" inManagedObjectContext:context];
        dispatch_queue_t imageFetchQ = dispatch_queue_create("image fetcher", NULL);
        dispatch_async(imageFetchQ, ^{
            [RZTools enableNetworkActivityIndicator];
            NSData *imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:photo.thumbnailURL]];
            [RZTools disableNetworkActivityIndicator];
            [context performBlock:^{
                thumbnail.imageData = imageData;
                thumbnail.photo = photo;
            }];
        });
    } else {
        NSLog(@"Thumbnail already exists, return current one");
        thumbnail = [matches lastObject];
    }
    
    return thumbnail;
}

@end
