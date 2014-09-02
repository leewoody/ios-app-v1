//
//  WALServerConnection.h
//  Wallabag
//
//  Created by Kevin Meyer on 30.05.14.
//  Copyright (c) 2014 Wallabag. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WALServerConnectionDelegate.h"

@class WALArticle;
@class WALArticleList;
@class WALSettings;

@interface WALServerConnection : NSObject

- (void) loadArticlesWithSettings:(WALSettings*) settings OldArticleList:(WALArticleList*) articleList delegate:(id<WALServerConnectionDelegate>) delegate;

@end
