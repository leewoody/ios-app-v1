//
//  WALBrowserViewController.m
//  Wallabag
//
//  Created by Kevin Meyer on 24.02.14.
//  Copyright (c) 2014 Wallabag. All rights reserved.
//

#import "WALBrowserViewController.h"

@interface WALBrowserViewController ()
@property (strong) NSURL *initialUrl;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
- (IBAction)refreshToolbarButtonPushed:(id)sender;
- (IBAction)shareToolbarButtonPushed:(id)sender;
@end

@implementation WALBrowserViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.webView.delegate = self;
	
	[self.webView loadRequest:[NSURLRequest requestWithURL:self.initialUrl]];
}

- (void)setStartURL:(NSURL*) startURL
{
	self.initialUrl = startURL;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.navigationController setToolbarHidden:FALSE];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[self.navigationController setToolbarHidden:true];
}

- (IBAction)refreshToolbarButtonPushed:(id)sender
{
	[self.webView reload];
}

- (IBAction)shareToolbarButtonPushed:(id)sender
{
	//! @todo implement and extend functions
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:@"cancel" destructiveButtonTitle:nil otherButtonTitles:@"Open in Safari", nil];
	
	[actionSheet showFromToolbar:self.navigationController.toolbar];
}

#pragma mark - WebView Delegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	if (navigationType != UIWebViewNavigationTypeOther)
	{
		self.title = [request.URL absoluteString];
	}
	
	return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}
@end
