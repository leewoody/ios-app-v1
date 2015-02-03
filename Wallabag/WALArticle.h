//
//  Wallabag.h
//  Wallabag
//
//  Created by Kevin Meyer on 31/01/15.
//  Copyright (c) 2015 Wallabag. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <RestKit/RestKit.h>

@interface WALArticle : NSManagedObject

@property (nonatomic, retain) NSNumber * articleID;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSNumber * isFavorite;
@property (nonatomic, retain) NSNumber * isRead;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, strong) NSURL * url;

+ (RKEntityMapping *)responseEntityMappingInManagedObjectStore:(RKManagedObjectStore *) managedObjectStore;
+ (RKObjectMapping *)requestMappingForPOST;
+ (RKObjectMapping *)requestMappingForPATCH;

+ (RKEntityMapping *)responseEntityMappingForXMLFeedInManagedObjectStore:(RKManagedObjectStore *) managedObjectStore;

@end
