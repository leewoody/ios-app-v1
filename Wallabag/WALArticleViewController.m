//
//  WALDetailViewController.m
//  Wallabag
//
//  Created by Kevin Meyer on 19.02.14.
//  Copyright (c) 2014 Wallabag. All rights reserved.
//

#import "WALArticleViewController.h"
#import "WALArticle.h"

@interface WALArticleViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;
- (IBAction)browserRefreshButton:(id)sender;
- (IBAction)starButton:(id)sender;
- (IBAction)shareButton:(id)sender;
@property (strong) WALArticle* article;
@end

@implementation WALArticleViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.webView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self configureView];
//	[self.navigationController setToolbarHidden:false];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	[self.navigationController setToolbarHidden:true];
}

#pragma mark - Managing the detail item

- (void) setDetailArticle:(WALArticle*) article
{
	self.article = article;
	self.title = article.title;
}

- (void) configureView
{
	NSURL *mainCSSFile = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"main" ofType:@"css"]];
	NSURL *ratatatouilleCSSFile = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"ratatouille" ofType:@"css"]];
	
	NSString *htmlToDisplay = [NSString stringWithFormat:@"<html lang=\"\"><head><meta name=\"viewport\" content=\"initial-scale=1.0\"><meta charset=\"utf-8\"><link rel=\"stylesheet\" href=\"%@\" media=\"all\"><link rel=\"stylesheet\" href=\"%@\" media=\"all\"><div id=\"main\"><body><div id=\"content\" class=\"w600p center\"><div id=\"article\"><header class=\"mbm\"><h1>%@</h1><p>%@</p></header><article>%@</article></div></div></div></body></html>", ratatatouilleCSSFile, mainCSSFile, self.article.title, self.article.link, self.article.content];
	
	[self.webView loadHTMLString:htmlToDisplay baseURL:nil];
}

#pragma mark - WebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	NSLog(@"WebView Error: %@\nWebView Error: %@", error.description, error.localizedFailureReason);
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{	
	if ([[[request URL] absoluteString] isEqualToString:@"about:blank"] && (navigationType != UIWebViewNavigationTypeOther))
	{
		[self configureView];
	}
	
	return true;
}

#pragma mark - ToolbarButton Actions

- (IBAction)browserRefreshButton:(id)sender
{
	[self.webView stopLoading];
	[self.webView reload];
}

- (IBAction)starButton:(id)sender
{
}

- (IBAction)shareButton:(id)sender
{
	NSString *message = [NSString stringWithFormat:@"I just read this article from my Wallabag: %@", self.article.title];
	NSArray *dataToShare = @[message, self.article.link];
	
	UIActivityViewController* activityViewController =
	[[UIActivityViewController alloc] initWithActivityItems:dataToShare
									  applicationActivities:nil];
	[self presentViewController:activityViewController animated:YES completion:^{}];
}
@end
