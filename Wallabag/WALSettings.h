//
//  WALSettings.h
//  Wallabag
//
//  Created by Kevin Meyer on 20.02.14.
//  Copyright (c) 2014 Wallabag. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WALSettings : NSObject

+ (WALSettings*) settingsFromSavedSettings;
- (void) saveSettings;

- (NSURL*) getHomeFeedURL;

- (void) setWallabagURL:(NSURL*) url;
- (NSURL*) getWallabagURL;

@property NSInteger userID;
@property (strong) NSString *apiToken;

@end
