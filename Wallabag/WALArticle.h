//
//  WALArticle.h
//  Wallabag
//
//  Created by Kevin Meyer on 19.02.14.
//  Copyright (c) 2014 Wallabag. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WALArticle : NSObject <NSCoding>

- (void) setDateWithString:(NSString*) string;
- (NSString*) getDateString;

- (void) setContent:(NSString*) content;
- (NSString*) getContent;

- (void) removeArticleFromCache;

@property (strong) NSString* title;
@property (strong) NSURL* link;
@property (strong) NSDate* date;
@property BOOL archive;

@end
