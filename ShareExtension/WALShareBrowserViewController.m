//
//  ShareViewController.m
//  ShareExtension
//
//  Created by Kevin Meyer on 24/09/14.
//  Copyright (c) 2014 Wallabag. All rights reserved.
//

#import "WALShareBrowserViewController.h"
#import "WALSettings.h"
#import "WALWebViewHelper.h"

@interface WALShareBrowserViewController () <UIWebViewDelegate>
@end

@implementation WALShareBrowserViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.title = @"Please Log In";
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelPushed:)];
	
	self.view = self.webView;
	self.view.hidden = NO;
}

- (void)cancelPushed:(id)sender {
	[self.helper cancel];
}

@end
