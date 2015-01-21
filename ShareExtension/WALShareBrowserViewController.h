//
//  ShareViewController.h
//  ShareExtension
//
//  Created by Kevin Meyer on 24/09/14.
//  Copyright (c) 2014 Wallabag. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>

@class WALWebViewHelper;
@class WALSettings;

@interface WALShareBrowserViewController : UIViewController

@property (weak) UIWebView *webView;
@property (strong) WALWebViewHelper *helper;

@end
