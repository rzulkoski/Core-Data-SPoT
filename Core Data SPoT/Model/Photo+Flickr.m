//
//  Photo+Flickr.m
//  Core Data SPoT
//
//  Created by Ryan Zulkoski on 3/13/13.
//  Copyright (c) 2013 RZGamer. All rights reserved.
//

#import "Photo+Flickr.h"
#import "Tag+Create.h"
#import "Thumbnail+Create.h"
#import "FlickrFetcher.h"

#define IGNORED_TAGS @[@"cs193pspot",@"portrait",@"landscape"]

@implementation Photo (Flickr)

+ (Photo *)photoWithFlickrInfo:(NSDictionary *)photoDictionary
        inManagedObjectContext:(NSManagedObjectContext *)context
{
    Photo *photo = nil;
    
    // Build a fetch request to see if we can find this Flickr photo in the database.
    // The "unique" attribute in Photo is Flickr's "id" which is guaranteed by Flickr to be unique.
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"unique = %@", [photoDictionary[FLICKR_PHOTO_ID] description]];
    
    // Execute the fetch
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    // Check what happened in the fetch
    
    if (!matches || ([matches count] > 1)) {  // nil means fetch failed; more than one impossible (unique!)
        // handle error
    } else if (![matches count]) { // none found, so let's create a Photo for that Flickr photo
        photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
        photo.unique = [photoDictionary[FLICKR_PHOTO_ID] description];
        photo.title = [photoDictionary[FLICKR_PHOTO_TITLE] description];
        photo.subtitle = [[photoDictionary valueForKeyPath:FLICKR_PHOTO_DESCRIPTION] description];
        photo.imageURL = [[FlickrFetcher urlForPhoto:photoDictionary format:FlickrPhotoFormatLarge] absoluteString];
        photo.thumbnailURL = [[FlickrFetcher urlForPhoto:photoDictionary format:FlickrPhotoFormatSquare] absoluteString];
        photo.originalFormat = [photoDictionary[FLICKR_PHOTO_ORIGINAL_FORMAT] description];
        photo.tags = [self parseTagsForPhotoWithFlickrInfo:photoDictionary inManagedObjectContext:context];
    } else { // found the Photo, just return it from the list of matches (which there will only be one of)
        photo = [matches lastObject];
    }

    return photo;
}

+ (NSSet *)parseTagsForPhotoWithFlickrInfo:(NSDictionary *)photoDictionary
                    inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSMutableSet *tags = [[NSMutableSet alloc] init];
    
    // Look at each Flickr tag for the photo
    for (NSString *flickrTag in [[photoDictionary[FLICKR_TAGS] description] componentsSeparatedByString:@" "]) {
        // If tag isn't one we are ignoring, add it to our set of tags for this photo
        if ([flickrTag length] && ![IGNORED_TAGS containsObject:flickrTag]) {
            Tag *tag = [Tag tagWithName:flickrTag inManagedObjectContext:context];
            [tags addObject:tag];
        }
    }
    
    return [tags copy];
}

// Designated method for retrieving thumbnail image rather than using photo.thumbnail since the latter is not guaranteed
// to be set. This is what allows for the on-demand thumbnails to function.
- (UIImage *)thumbnailImage
{
    // If thumbnail relationship hasn't been set yet (meaning thumbnail image isn't stored in database yet),
    // then retrieve the thumbnail image and associate it with this photo (handled in Thumbnail+Create.m)
    if (!self.thumbnail) [Thumbnail thumbnailForPhoto:self inManagedObjectContext:self.managedObjectContext];
    
    return [UIImage imageWithData:self.thumbnail.imageData];
}

@end
