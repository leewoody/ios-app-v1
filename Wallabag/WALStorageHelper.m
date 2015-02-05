//
//  WALStorageHelper.m
//  Wallabag
//
//  Created by Kevin Meyer on 05/02/15.
//  Copyright (c) 2015 Wallabag. All rights reserved.
//

#import "WALStorageHelper.h"

#import <CoreData/CoreData.h>
#import <Restkit/RestKit.h>
#import <RKTBXMLSerialization/RKTBXMLSerialization.h>

#import "WALSettings.h"
#import "WALArticle.h"

@implementation WALStorageHelper


+ (void)initializeCoreDataAndRestKit {
	// Override point for customization after application launch.
	NSError *error = nil;
	
	// NOTE: Due to an iOS 5 bug, the managed object model returned is immutable.
	NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] mutableCopy];
	RKManagedObjectStore *managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
	
	// Initialize the Core Data stack
	[managedObjectStore createPersistentStoreCoordinator];
	
	NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"wallabag.sqlite"];
	
	NSPersistentStore __unused *persistentStore = [managedObjectStore addSQLitePersistentStoreAtPath:[storeURL path] fromSeedDatabaseAtPath:nil withConfiguration:nil options:nil error:&error];
	NSAssert(persistentStore, @"Failed to add persistent store: %@", error);
	
	[managedObjectStore createManagedObjectContexts];
	
	// Set the default store shared instance
	[RKManagedObjectStore setDefaultStore:managedObjectStore];
	
	// Register TBXML Support
	[RKMIMETypeSerialization registerClass:[RKTBXMLSerialization class] forMIMEType:@"application/xml"];
	[RKMIMETypeSerialization registerClass:[RKTBXMLSerialization class] forMIMEType:@"text/xml"];
}

+ (void)updateRestKitWithNewSettings {
	WALSettings *settings = [WALSettings settingsFromSavedSettings];
	if (settings && settings.isValid) {
		[self initializeSharedObjectManagerWithWallabagBaseURL:[settings getWallabagURL] andIsWallabagV2:settings.isVersionV2];
	} else {
		NSLog(@"Settings invalid! Incomplete RestKit setup!");
	}
}

+ (void)initializeSharedObjectManagerWithWallabagBaseURL:(NSURL*) wallabagURL andIsWallabagV2:(BOOL) isWallabagV2 {
	RKManagedObjectStore *managedObjectStore = [RKManagedObjectStore defaultStore];
	
	// Configure the object manager
	RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:wallabagURL];
	objectManager.managedObjectStore = managedObjectStore;
	objectManager.requestSerializationMIMEType = RKMIMETypeJSON;
	[RKObjectManager setSharedManager:objectManager];
	
	if (isWallabagV2) {
		[self setUpObjectManagerForV2:objectManager inManagedObjectStore:managedObjectStore];
	} else {
		[self setUpObjectManagerForV1:objectManager inManagedObjectStore:managedObjectStore];
	}
}

+ (void)setUpObjectManagerForV2:(RKObjectManager *) objectManager inManagedObjectStore:(RKManagedObjectStore *) managedObjectStore {

	// WALArticle Response Descriptors
	[objectManager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:[WALArticle responseEntityMappingInManagedObjectStore:managedObjectStore] method:RKRequestMethodGET | RKRequestMethodPOST pathPattern:@"api/entries" keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
	[objectManager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:[WALArticle responseEntityMappingInManagedObjectStore:managedObjectStore] method:RKRequestMethodGET | RKRequestMethodPATCH pathPattern:@"api/entries/:articleID" keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
	
	// WALArticle Request Descriptors
	[objectManager addRequestDescriptor:[RKRequestDescriptor requestDescriptorWithMapping:[WALArticle requestMappingForPOST] objectClass:[WALArticle class] rootKeyPath:nil method:RKRequestMethodPOST]];
	[objectManager addRequestDescriptor:[RKRequestDescriptor requestDescriptorWithMapping:[WALArticle requestMappingForPATCH] objectClass:[WALArticle class] rootKeyPath:nil method:RKRequestMethodPATCH]];
	
	[objectManager.router.routeSet addRoute:[RKRoute routeWithClass:[WALArticle class] pathPattern:@"api/entries/:articleID" method:RKRequestMethodGET]];
	[objectManager.router.routeSet addRoute:[RKRoute routeWithClass:[WALArticle class] pathPattern:@"api/entries" method:RKRequestMethodPOST]];
	[objectManager.router.routeSet addRoute:[RKRoute routeWithClass:[WALArticle class] pathPattern:@"api/entries/:articleID" method:RKRequestMethodPATCH]];
	[objectManager.router.routeSet addRoute:[RKRoute routeWithClass:[WALArticle class] pathPattern:@"api/entries/:articleID" method:RKRequestMethodDELETE]];
	
	[objectManager.router.routeSet addRoute:[RKRoute routeWithName:@"articles" pathPattern:@"api/entries" method:RKRequestMethodGET]];
	[objectManager addFetchRequestBlock:^NSFetchRequest *(NSURL *URL) {
		RKPathMatcher *pathMatcher = [RKPathMatcher pathMatcherWithPattern:@"api/entries"];
		NSDictionary *argsDict = nil;
		BOOL match = [pathMatcher matchesPath:[URL relativePath] tokenizeQueryStrings:NO parsedArguments:&argsDict];
		if (match) {
			// @todo use parsed Dict in predicate
			NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Article"];
			//fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(isRead = NO)"];
			fetchRequest.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"articleID" ascending:YES] ];
			return fetchRequest;
		}
		
		return nil;
	}];
}

+ (void)setUpObjectManagerForV1:(RKObjectManager *) objectManager inManagedObjectStore:(RKManagedObjectStore *) managedObjectStore {
	[objectManager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:[WALArticle responseEntityMappingForXMLFeedInManagedObjectStore:managedObjectStore] method:RKRequestMethodAny pathPattern:nil keyPath:@"rss.channel.item" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
	[objectManager.router.routeSet addRoute:[RKRoute routeWithName:@"articles" pathPattern:@"" method:RKRequestMethodGET]];
}

+ (NSURL *)applicationDocumentsDirectory {
	return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
