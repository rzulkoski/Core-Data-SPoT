//
//  TagsCDTVC.h
//  Core Data SPoT
//
//  Created by Ryan Zulkoski on 3/13/13.
//  Copyright (c) 2013 RZGamer. All rights reserved.
//

#import "CoreDataTableViewController.h"

@interface TagsCDTVC : CoreDataTableViewController

// The Model for this class.
// Essentially specifies the database to look in to find all Tags to display in this table.
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
