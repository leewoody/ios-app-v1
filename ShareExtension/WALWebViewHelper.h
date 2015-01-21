//
//  WALWebViewHelper.h
//  Wallabag
//
//  Created by Kevin Meyer on 18/01/15.
//  Copyright (c) 2015 Wallabag. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class  WALShareBrowserViewController;
@class WALSettings;

@protocol WALShareBrowserDelegate <NSObject>

- (void) shareBrowser:(WALShareBrowserViewController*) browser didAddURL:(NSURL*) url;
- (void) shareBrowserNeedsFurtherActions:(WALShareBrowserViewController*) browser;
- (void) shareBrowser:(WALShareBrowserViewController*) browser didCancelWithError:(NSError *) error;

@end

@interface WALWebViewHelper : NSObject <UIWebViewDelegate>

- (void)cancel;
- (void)startWithWebView:(UIWebView*) webView;
@property (weak) UIWebView *webView;

@property (weak) id<WALShareBrowserDelegate> delegate;
@property (strong) WALSettings *settings;
@property (strong) NSURL *addUrl;

@end
