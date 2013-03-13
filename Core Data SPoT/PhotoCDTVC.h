//
//  PhotoCDTVC.h
//  Core Data SPoT
//
//  Created by Ryan Zulkoski on 3/13/13.
//  Copyright (c) 2013 RZGamer. All rights reserved.
//

#import "CoreDataTableViewController.h"

@interface PhotoCDTVC : CoreDataTableViewController

// The Model for this class.
// Essentially specifies the database to look in to find all Photos to display in this table.
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSSortDescriptor *sortDescriptor;
@property (nonatomic, strong) NSPredicate *predicate;
@property (nonatomic, strong) NSNumber *fetchLimit;

@end
