//
//  WALArticleList.m
//  Wallabag
//
//  Created by Kevin Meyer on 30.05.14.
//  Copyright (c) 2014 Wallabag. All rights reserved.
//

#import "WALArticleList.h"
#import "WALArticle.h"

@interface WALArticleList ()
@property (strong) NSMutableArray* articles;
@property (strong) NSMutableArray* unreadArticles;
@end

@implementation WALArticleList

- (id)init
{
	if (self = [super init])
	{
		self.articles = [NSMutableArray array];
	}
	
	return self;
}

- (void)loadArticlesFromDisk
{
	self.articles = [NSKeyedUnarchiver unarchiveObjectWithFile:[self pathToSavedArticles]];
	[self updateUnreadArticles];
}

- (void)saveArticlesFromDisk
{
	[NSKeyedArchiver archiveRootObject:self.articles toFile:[self pathToSavedArticles]];
}

- (NSUInteger)getNumberOfAllArticles
{
	if (self.articles)
		return self.articles.count;

	return 0;
}

- (NSUInteger)getNumberOfUnreadArticles
{
	if (self.unreadArticles)
		return self.unreadArticles.count;

	return 0;
}

- (WALArticle*) getArticleAtIndex:(NSUInteger) index
{
	if (index < self.articles.count)
		return self.articles[index];
	
	return nil;
}

- (WALArticle *) getUnreadArticleAtIntex:(NSUInteger) index
{
	if (index < self.unreadArticles.count)
		return self.unreadArticles[index];

	return nil;
}

- (WALArticle*) getArticleWithLink:(NSURL*) link
{
	for (WALArticle *article in self.articles)
	{
		if ([article.link.absoluteString isEqualToString:link.absoluteString])
			return article;
	}
	
	return nil;
}

- (void) addArticle:(WALArticle*) article
{
	if (article)
		[self.articles addObject:article];
}

- (void)updateUnreadArticles
{
	self.unreadArticles = [NSMutableArray array];
	
	for (WALArticle *article in self.articles)
	{
		if (!article.archive) {
			[self.unreadArticles addObject:article];
		}
	}
}

- (void)setAllArticlesAsUnread
{
	for (WALArticle *article in self.articles)
		article.archive = NO;
	
	[self updateUnreadArticles];
}

- (void)deleteCachedArticles
{
	for (WALArticle *article in self.articles) {
		[article removeArticleFromCache];
	}
	
	self.articles = nil;
	self.unreadArticles = nil;
}

#pragma mark - 

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

- (NSString*) pathToSavedArticles
{
	NSURL *applicationSupportURL = [self applicationDataDirectory];
    
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
    NSString *path = [[applicationSupportURL path] stringByAppendingPathComponent:@"savedArticles.plist"];
    
    return path;
}

@end
