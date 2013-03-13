//
//  Tag+Create.h
//  Core Data SPoT
//
//  Created by Ryan Zulkoski on 3/13/13.
//  Copyright (c) 2013 RZGamer. All rights reserved.
//

#import "Tag.h"

@interface Tag (Create)

+ (Tag *)    tagWithName:(NSString *)name
  inManagedObjectContext:(NSManagedObjectContext *)context;

@end
