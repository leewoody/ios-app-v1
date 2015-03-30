//
//  WALSettings.h
//  Wallabag
//
//  Created by Kevin Meyer on 20.02.14.
//  Copyright (c) 2014 Wallabag. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WALUser.h"

@interface WALSettings : NSObject
@property NSInteger userID;
@property (strong) NSString *apiToken;
@property (nonatomic, strong, getter=getWallabagURL) NSURL *wallabagURL;
@property (strong) WALUser *user;

+ (WALSettings*) settingsFromSavedSettings;
- (void) saveSettings;

- (void) setVersionV2:(BOOL) isV2;
- (BOOL) isVersionV2;

- (BOOL) isValid;

@end
