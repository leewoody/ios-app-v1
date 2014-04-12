//
//  WALArticle.m
//  Wallabag
//
//  Created by Kevin Meyer on 19.02.14.
//  Copyright (c) 2014 Wallabag. All rights reserved.
//

#import "WALArticle.h"

@interface WALArticle ()
@property NSString *fileUid;
@end

@implementation WALArticle

- (void) setDateWithString:(NSString*) string
{
	NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
	NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
	
	[dateformatter setLocale:usLocale];
	[dateformatter setDateFormat:@"EEE, dd LLL yyyy HH:mm:ss Z"];

	self.date = [dateformatter dateFromString: string];
}

- (NSString*) getDateString
{
	return [NSDateFormatter localizedStringFromDate:self.date
										  dateStyle:NSDateFormatterShortStyle
										  timeStyle:NSDateFormatterShortStyle];
}

#pragma mark - ContentStringCaching

- (void) setContent:(NSString *)content
{
	if (!content)
		return;
	
	if (!self.fileUid)
		self.fileUid = [[NSUUID new] UUIDString];

	[NSKeyedArchiver archiveRootObject:content toFile:[self pathForContentWithUID:self.fileUid]];
}

- (NSString *)getContent
{
	return [NSKeyedUnarchiver unarchiveObjectWithFile:[self pathForContentWithUID:self.fileUid]];
}

- (void)removeArticleFromCache
{
	[[NSFileManager defaultManager] removeItemAtPath:[self pathForContentWithUID:self.fileUid] error:nil];
}

#pragma mark - Coder

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:self.title forKey:@"title"];
	[aCoder encodeObject:self.link forKey:@"link"];
	[aCoder encodeObject:self.date forKey:@"date"];
	[aCoder encodeObject:self.fileUid forKey:@"fileUid"];
	[aCoder encodeBool:self.archive forKey:@"archive"];
	[aCoder encodeObject:self.source forKey:@"source"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if (self = [super init])
	{
		self.title = [aDecoder decodeObjectForKey:@"title"];
		self.link = [aDecoder decodeObjectForKey:@"link"];
		self.date = [aDecoder decodeObjectForKey:@"date"];
		self.archive = [aDecoder decodeBoolForKey:@"archive"];
		self.fileUid = [aDecoder decodeObjectForKey:@"fileUid"];
		self.content = [aDecoder decodeObjectForKey:@"content"];
		self.source = [aDecoder decodeObjectForKey:@"source"];
	}
	
	return self;
}

- (NSString*) pathForContentWithUID:(NSString*) uid
{
	NSURL *applicationSupportURL = [self applicationDataDirectory];
	applicationSupportURL = [applicationSupportURL URLByAppendingPathComponent:@"content" isDirectory:YES];
    
    if (! [[NSFileManager defaultManager] fileExistsAtPath:[applicationSupportURL path]]){
		
        NSError *error = nil;
        
        [[NSFileManager defaultManager] createDirectoryAtPath:[applicationSupportURL path]
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&error];
        
        if (error){
            NSLog(@"error creating app support dir: %@", error);
        }
        
    }
    NSString *path = [[applicationSupportURL path] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", uid]];
    
    return path;
}


- (NSURL*)applicationDataDirectory {
    NSFileManager* sharedFM = [NSFileManager defaultManager];
    NSArray* possibleURLs = [sharedFM URLsForDirectory:NSApplicationSupportDirectory
                                             inDomains:NSUserDomainMask];
    NSURL* appSupportDir = nil;
    NSURL* appDirectory = nil;
    
    if ([possibleURLs count] >= 1) {
        // Use the first directory (if multiple are returned)
        appSupportDir = [possibleURLs objectAtIndex:0];
    }
    
    // If a valid app support directory exists, add the
    // app's bundle ID to it to specify the final directory.
    if (appSupportDir) {
        NSString* appBundleID = [[NSBundle mainBundle] bundleIdentifier];
        appDirectory = [appSupportDir URLByAppendingPathComponent:appBundleID];
    }
    
    return appDirectory;
}


@end
