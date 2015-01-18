//
//  ShareViewController.h
//  ShareExtension
//
//  Created by Kevin Meyer on 24/09/14.
//  Copyright (c) 2014 Wallabag. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>

@class  WALShareBrowserViewController;

@protocol WALShareBrowserDelegate <NSObject>

- (void) shareBrowser:(WALShareBrowserViewController*) browser didAddURL:(NSURL*) url;
- (void) shareBrowserNeedsFurtherActions:(WALShareBrowserViewController*) browser;
- (void) shareBrowser:(WALShareBrowserViewController*) browser didCancelWithError:(NSError *) error;

@end

@class WALSettings;

@interface WALShareBrowserViewController : UIViewController

@property (weak) id<WALShareBrowserDelegate> delegate;
@property (strong) WALSettings *settings;
@property (strong) NSURL *addUrl;

@end
