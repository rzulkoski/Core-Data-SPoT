//
//  Thumbnail+Create.h
//  Core Data SPoT
//
//  Created by Ryan Zulkoski on 3/13/13.
//  Copyright (c) 2013 RZGamer. All rights reserved.
//

#import "Thumbnail.h"

@interface Thumbnail (Create)

+ (Thumbnail *)    thumbnailForPhoto:(Photo *)photo
  inManagedObjectContext:(NSManagedObjectContext *)context;

@end
