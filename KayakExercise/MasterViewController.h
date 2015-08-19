//
//  MasterViewController.h
//  KayakExercise
//
//  Created by Er Li on 8/16/15.
//  Copyright (c) 2015 elieric. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "DetailViewController.h"


@interface MasterViewController : UITableViewController<NSFetchedResultsControllerDelegate,FavoriteObjectDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

