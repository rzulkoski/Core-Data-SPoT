//
//  Thumbnail.h
//  Core Data SPoT
//
//  Created by Ryan Zulkoski on 3/13/13.
//  Copyright (c) 2013 RZGamer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photo;

@interface Thumbnail : NSManagedObject

@property (nonatomic, retain) NSData * imageData;
@property (nonatomic, retain) Photo *photo;

@end
