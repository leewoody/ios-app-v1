//
//  WALMasterViewController.h
//  Wallabag
//
//  Created by Kevin Meyer on 19.02.14.
//  Copyright (c) 2014 Wallabag. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "WALFeedCallbackDelegate.h"
#import "WALThemeOrganizerDelegate.h"

@interface WALFeedTableViewController : UITableViewController <WALFeedCallbackDelegate, WALThemeOrganizerDelegate, UIActionSheetDelegate, NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
