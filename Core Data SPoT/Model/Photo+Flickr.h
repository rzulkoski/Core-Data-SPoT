//
//  Photo+Flickr.h
//  Core Data SPoT
//
//  Created by Ryan Zulkoski on 3/13/13.
//  Copyright (c) 2013 RZGamer. All rights reserved.
//

#import "Photo.h"

@interface Photo (Flickr)

+ (Photo *)photoWithFlickrInfo:(NSDictionary *)photoDictionary
        inManagedObjectContext:(NSManagedObjectContext *)context;

// Designated method for retrieving thumbnail image rather than using photo.thumbnail since the latter is not guaranteed
// to be set. This is what allows for the on-demand thumbnails to function.
- (UIImage *)thumbnailImage;

@end
