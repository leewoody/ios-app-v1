//
//  WALFeedCallbackProtocol.h
//  Wallabag
//
//  Created by Kevin Meyer on 19.02.14.
//  Copyright (c) 2014 Wallabag. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WALSettingsTableViewController;
@class WALAddArticleTableViewController;
@class WALSettings;

@protocol WALFeedCallbackDelegate <NSObject>

- (void) callbackFromSettingsController:(WALSettingsTableViewController*) settingsTableViewController withSettings:(WALSettings*) settings;
- (void) callbackFromAddArticleController:(WALAddArticleTableViewController*) addArticleController withURL:(NSURL*) url;

@end
