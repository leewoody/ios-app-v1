//
//  WALServerConnectionDelegate.h
//  Wallabag
//
//  Created by Kevin Meyer on 30.05.14.
//  Copyright (c) 2014 Wallabag. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WALArticleList;
@class WALServerConnection;
@class NSError;

@protocol WALServerConnectionDelegate <NSObject>

- (void) serverConnection:(WALServerConnection*) connection didFinishWithArticleList:(WALArticleList*) articleList;
- (void) serverConnection:(WALServerConnection*) connection didFinishWithError:(NSError*) error;

@end
