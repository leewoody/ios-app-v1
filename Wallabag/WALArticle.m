//
//  Wallabag.m
//  Wallabag
//
//  Created by Kevin Meyer on 31/01/15.
//  Copyright (c) 2015 Wallabag. All rights reserved.
//

#import "WALArticle.h"
#import "NSString+HTML.h"

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

+ (RKEntityMapping *)responseEntityMappingForXMLFeedInManagedObjectStore:(RKManagedObjectStore *)managedObjectStore {
	RKEntityMapping *entityMapping = [RKEntityMapping mappingForEntityForName:@"Article" inManagedObjectStore:managedObjectStore];
	[entityMapping addAttributeMappingsFromDictionary:@{@"link": @"url",
														//@"@metadata.mapping.collectionIndex": @"articleID"
														}];

	RKValueTransformer *unescapeStringTransformer = [RKBlockValueTransformer valueTransformerWithValidationBlock:^BOOL(__unsafe_unretained Class inputValueClass, __unsafe_unretained Class outputValueClass) {
		return ([inputValueClass isSubclassOfClass:[NSString class]] && [outputValueClass isSubclassOfClass:[NSString class]]);
	} transformationBlock:^BOOL(id inputValue, __autoreleasing id *outputValue, __unsafe_unretained Class outputClass, NSError *__autoreleasing *error) {
		RKValueTransformerTestInputValueIsKindOfClass(inputValue, [NSString class], error);
		RKValueTransformerTestOutputValueClassIsSubclassOfClass(outputClass, [NSString class], error);

		*outputValue = [(NSString *)inputValue stringByHtmlUnescapingString];
		return YES;
	}];
	
	RKValueTransformer *extractIDFromURL = [RKBlockValueTransformer valueTransformerWithValidationBlock:^BOOL(__unsafe_unretained Class inputValueClass, __unsafe_unretained Class outputValueClass) {
		return ([inputValueClass isSubclassOfClass:[NSString class]] && [outputValueClass isSubclassOfClass:[NSNumber class]]);
	} transformationBlock:^BOOL(id inputValue, __autoreleasing id *outputValue, __unsafe_unretained Class outputClass, NSError *__autoreleasing *error) {
		RKValueTransformerTestInputValueIsKindOfClass(inputValue, [NSString class], error);
		RKValueTransformerTestOutputValueClassIsSubclassOfClass(outputClass, [NSNumber class], error);
		
		NSString *urlString = [inputValue stringByHtmlUnescapingString];
		NSArray *components = [urlString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"?&="]];
		NSUInteger index = [components indexOfObject:@"id"];
		if (index != NSNotFound && components.count > index + 1) {
			NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
			formatter.numberStyle = NSNumberFormatterDecimalStyle;
			*outputValue = [formatter numberFromString:components[index + 1]];
			if (outputValue) {
				return YES;
			}
		}

		return NO;
	}];

	
	RKAttributeMapping *titleMapping = [RKAttributeMapping attributeMappingFromKeyPath:@"title" toKeyPath:@"title"];
	titleMapping.valueTransformer = unescapeStringTransformer;

	RKAttributeMapping *contentMapping = [RKAttributeMapping attributeMappingFromKeyPath:@"description" toKeyPath:@"content"];
	contentMapping.valueTransformer = unescapeStringTransformer;
	
	RKAttributeMapping *articleIDMapping = [RKAttributeMapping attributeMappingFromKeyPath:@"source.url" toKeyPath:@"articleID"];
	articleIDMapping.valueTransformer = extractIDFromURL;
	
	[entityMapping addAttributeMappingsFromArray:@[titleMapping, contentMapping, articleIDMapping]];
	entityMapping.identificationAttributes = @[@"url"];
	return entityMapping;
}

@end
