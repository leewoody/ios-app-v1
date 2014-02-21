//
//  WALSettingsTableViewController.h
//  Wallabag
//
//  Created by Kevin Meyer on 19.02.14.
//  Copyright (c) 2014 Wallabag. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WALFeedCallbackDelegate.h"

@class WALSettings;

@interface WALSettingsTableViewController : UITableViewController <UITextFieldDelegate, UIAlertViewDelegate>

- (void) setSettings:(WALSettings*) settings;
@property (weak) id <WALFeedCallbackDelegate> delegate;

@end
