//
//  WALWebViewHelper.m
//  Wallabag
//
//  Created by Kevin Meyer on 18/01/15.
//  Copyright (c) 2015 Wallabag. All rights reserved.
//

#import "WALWebViewHelper.h"
#import "WALSettings.h"

@interface WALWebViewHelper	() <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property unsigned int numberOfTries;
@property BOOL succeeded;
@property BOOL authenticated;

@property (strong) NSURLRequest *currentRequest;

@end

@implementation WALWebViewHelper

- (void)startWithWebView:(UIWebView*) webView {
	self.numberOfTries = 0;
	self.succeeded = NO;
	self.authenticated = NO;
	self.webView = webView;
	self.webView.delegate = self;
	
	NSURLRequest *nextTryRequest = [NSURLRequest requestWithURL:[self.settings getURLToAddArticle:self.addUrl]];
	[self.webView loadRequest:nextTryRequest];
	
	if ([[self.settings getWallabagURL].scheme isEqualToString:@"http"]) {
		self.authenticated = YES;
	}
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
	
	if (!self.authenticated) {
		self.currentRequest = request;
		[[NSURLConnection connectionWithRequest:request delegate:self] start];
		
		return NO;
	}
	
	if ([url.query containsString:@"view=home"]) {
		NSLog(@"Success!");
		self.succeeded = YES;
		
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
	
	if (self.delegate && !self.succeeded) {
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

#pragma mark - NSURLConnection

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
	
	if (challenge.previousFailureCount < 1) {
		self.authenticated = YES;
		NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
		[challenge.sender useCredential:credential forAuthenticationChallenge:challenge];
	} else {
		[challenge.sender cancelAuthenticationChallenge:challenge];
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	self.authenticated = YES;
	[self.webView loadRequest:self.currentRequest];
	[connection cancel];
}

@end
