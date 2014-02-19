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

@protocol WALFeedCallbackDelegate <NSObject>

- (void) callbackFromSettingsController:(WALSettingsTableViewController*) settingsTableViewController withSettings:(id) settings;
- (void) callbackFromAddArticleController:(WALAddArticleTableViewController*) addArticleController withURL:(NSURL*) url;

@end
