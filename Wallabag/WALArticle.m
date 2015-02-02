//
//  Wallabag.m
//  Wallabag
//
//  Created by Kevin Meyer on 31/01/15.
//  Copyright (c) 2015 Wallabag. All rights reserved.
//

#import "WALArticle.h"


@implementation WALArticle

@dynamic articleID;
@dynamic content;
@dynamic isFavorite;
@dynamic isRead;
@dynamic title;
@dynamic url;

#pragma mark - RestKit Mappings

+ (RKEntityMapping *)responseEntityMappingInManagedObjectStore:(RKManagedObjectStore *)managedObjectStore {
	RKEntityMapping *entityMapping = [RKEntityMapping mappingForEntityForName:@"Article" inManagedObjectStore:managedObjectStore];
	[entityMapping addAttributeMappingsFromDictionary:@{@"id":		@"articleID",
														@"title":	@"title",
														@"url":		@"url",
														@"is_read": @"isRead",
														@"is_fav":	@"isFavorite",
														@"content": @"content"}];
	entityMapping.identificationAttributes = @[@"articleID"];
	return entityMapping;
}

+ (RKObjectMapping *)requestMappingForPOST {
	RKObjectMapping *entityMapping = [RKObjectMapping requestMapping];
	[entityMapping addAttributeMappingsFromArray:@[@"url", @"title"]];
	return entityMapping;
}

+ (RKObjectMapping *)requestMappingForPATCH {
	RKObjectMapping *entityMapping = [RKObjectMapping requestMapping];
	[entityMapping addAttributeMappingsFromDictionary:@{@"isRead": @"is_read", @"isFavorite": @"is_fav"}];
	return entityMapping;
}

@end
