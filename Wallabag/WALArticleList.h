//
//  WALArticleList.h
//  Wallabag
//
//  Created by Kevin Meyer on 30.05.14.
//  Copyright (c) 2014 Wallabag. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WALArticle;

@interface WALArticleList : NSObject

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
