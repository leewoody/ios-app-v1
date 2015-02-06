//
//  WALWebViewHelper.m
//  Wallabag
//
//  Created by Kevin Meyer on 18/01/15.
//  Copyright (c) 2015 Wallabag. All rights reserved.
//

#import "WALWebViewHelper.h"
#import "WALSettings.h"

@interface WALWebViewHelper	()

@property unsigned int numberOfTries;

@end

@implementation WALWebViewHelper

- (void)startWithWebView:(UIWebView*) webView {
	self.numberOfTries = 0;
	self.webView = webView;
	self.webView.delegate = self;
	
	NSURLRequest *nextTryRequest = [NSURLRequest requestWithURL:[self.settings getURLToAddArticle:self.addUrl]];
	[self.webView loadRequest:nextTryRequest];	
}

- (void)cancelWithError:(NSError*) error {
	if (self.delegate) {
		[self.delegate shareBrowser:nil didCancelWithError:error];
	}
}

- (void)cancel {
	[self cancelWithError:nil];
}

#pragma mark - WebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	//NSLog(@"URL Request:\n\tMethod: %@\n\tURL: %@\n\tBody: %@\n\tPathExtension: %@", request.HTTPMethod, request.URL.absoluteString, request.HTTPBody, request.URL.pathExtension);
	NSURL *url = request.URL;
	
	if ([url.query containsString:@"view=home"]) {
		NSLog(@"Success!");
		
		if (self.delegate) {
			[self.delegate shareBrowser:nil didAddURL:self.addUrl];
		}
		
	} else if (![url.pathExtension isEqualToString:@"php"]) {
		if (self.numberOfTries++ < 5) {
			NSLog(@"Didn't add link yet, retrying.");
			NSURLRequest *nextTryRequest = [NSURLRequest requestWithURL:[self.settings getURLToAddArticle:self.addUrl]];
			[self.webView loadRequest:nextTryRequest];
		} else {
			NSLog(@"Too many retrys");
			[self cancel];
		}
	}
	return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	NSURLRequest *request = webView.request;
	NSLog(@"URL Request:\n\tMethod: %@\n\tURL: %@\n\tBody: %@\n\tPathExtension: %@", request.HTTPMethod, request.URL.absoluteString, request.HTTPBody, request.URL.pathExtension);
	
	if (self.delegate) {
		[self.delegate shareBrowserNeedsFurtherActions:nil];
	}
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	NSLog(@"WebView Error: %@", error.description);
	
	/// Ignore often occuring NSURLError -999
	if (error.code == NSURLErrorCancelled)
		return;
	
	[self cancelWithError:error];
}

@end
