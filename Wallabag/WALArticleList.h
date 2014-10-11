//
//  WALArticleList.h
//  Wallabag
//
//  Created by Kevin Meyer on 30.05.14.
//  Copyright (c) 2014 Wallabag. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
	WALArticleListTypeUnread,
	WALArticleListTypeFavorites,
	WALArticleListTypeArchive,
} WALArticleListType;

@class WALArticle;

@interface WALArticleList : NSObject

- (id) initAsType:(WALArticleListType) type;
- (WALArticleListType) getListType;

- (void) loadArticlesFromDisk;
- (void) saveArticlesFromDisk;

- (NSUInteger) getNumberOfAllArticles;
- (NSUInteger) getNumberOfUnreadArticles;

- (WALArticle*) getArticleAtIndex:(NSUInteger) index;
- (WALArticle*) getUnreadArticleAtIndex:(NSUInteger) index;
- (WALArticle*) getArticleWithLink:(NSURL*) link;

- (void) addArticle:(WALArticle*) article;
- (void) updateUnreadArticles;
- (void) setAllArticlesAsUnread;
- (void) deleteCachedArticles;

@end
