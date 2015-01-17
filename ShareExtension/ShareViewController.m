//
//  ShareViewController.m
//  ShareExtension
//
//  Created by Kevin Meyer on 24/09/14.
//  Copyright (c) 2014 Wallabag. All rights reserved.
//

#import "ShareViewController.h"
#import "WALSettings.h"

@interface ShareViewController () <UIWebViewDelegate>
@property (weak) IBOutlet UIWebView *webView;
@property (strong) WALSettings *settings;
- (IBAction)cancelPushed:(id)sender;
@end

@implementation ShareViewController

- (BOOL)isContentValid {
    // Do validation of contentText and/or NSExtensionContext attachments here
    return YES;
}

- (void)viewDidLoad {
	self.webView.delegate = self;
	
	self.settings = [[WALSettings alloc] init];
	[self.settings setWallabagURL:[NSURL URLWithString:@"https://example.com/"]];
	
	NSExtensionItem *item = self.extensionContext.inputItems[0];
	NSItemProvider *provider = item.attachments[0];
	[provider loadItemForTypeIdentifier:@"public.url" options:nil completionHandler:^(id<NSSecureCoding> item, NSError *error) {
		NSURL *url = (NSURL*)item;
		NSURLRequest *request = [NSURLRequest requestWithURL:[self.settings getURLToAddArticle:url]];
		[self.webView loadRequest:request];
	}];
}

- (IBAction)cancelPushed:(id)sender {
	[self.extensionContext cancelRequestWithError:nil];
}


#pragma mark - WebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	NSLog(@"URL Request:\n\tMethod: %@\n\tURL: %@\n\tBody: %@\n\tPathExtension: %@", request.HTTPMethod, request.URL.absoluteString, request.HTTPBody, request.URL.pathExtension);
	NSURL *url = request.URL;
	
	if ([url.query isEqualToString:@"view=home&closewin=true"]) {
		self.title = @"Success";
		NSLog(@"Success!");
		[self.extensionContext completeRequestReturningItems:nil completionHandler:nil];
	} else if (![url.pathExtension isEqualToString:@"php"]) {
		NSError *error = [NSError errorWithDomain:@"wallabag-share" code:111 userInfo:@{NSLocalizedDescriptionKey: @"Error adding Link. Please try again"}];
		NSLog(@"Couldn't add Link");
		[self.extensionContext cancelRequestWithError:error];
	}
	return YES;
}


@end
