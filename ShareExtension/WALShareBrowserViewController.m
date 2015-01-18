//
//  ShareViewController.m
//  ShareExtension
//
//  Created by Kevin Meyer on 24/09/14.
//  Copyright (c) 2014 Wallabag. All rights reserved.
//

#import "WALShareBrowserViewController.h"
#import "WALSettings.h"

@interface WALShareBrowserViewController () <UIWebViewDelegate>
@property (weak) IBOutlet UIWebView *webView;
- (IBAction)cancelPushed:(id)sender;
@end

@implementation WALShareBrowserViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	self.view.hidden = YES;
	
	self.title = @"Please Log in";
	self.webView.delegate = self;
	
	if (self.addUrl && self.settings) {
		NSURLRequest *request = [NSURLRequest requestWithURL:[self.settings getURLToAddArticle:self.addUrl]];
		[self.webView loadRequest:request];
	}
}

- (IBAction)cancelPushed:(id)sender {
	if (self.delegate) {
		[self.delegate shareBrowserDidCancel:self];
	}
}


#pragma mark - WebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	//NSLog(@"URL Request:\n\tMethod: %@\n\tURL: %@\n\tBody: %@\n\tPathExtension: %@", request.HTTPMethod, request.URL.absoluteString, request.HTTPBody, request.URL.pathExtension);
	NSURL *url = request.URL;
	
	if ([url.query isEqualToString:@"view=home&closewin=true"]) {
		self.title = @"Success";
		NSLog(@"Success!");
		
		if (self.delegate) {
			[self.delegate shareBrowser:self didAddURL:self.addUrl];
		}
		
	} else if (![url.pathExtension isEqualToString:@"php"]) {
		NSLog(@"Didn't add link yet, retrying.");
		NSURLRequest *nextTryRequest = [NSURLRequest requestWithURL:[self.settings getURLToAddArticle:self.addUrl]];
		[self.webView loadRequest:nextTryRequest];
		return NO;
	}
	return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	NSURLRequest *request = webView.request;
	NSLog(@"URL Request:\n\tMethod: %@\n\tURL: %@\n\tBody: %@\n\tPathExtension: %@", request.HTTPMethod, request.URL.absoluteString, request.HTTPBody, request.URL.pathExtension);
	self.view.hidden = NO;
}

@end
