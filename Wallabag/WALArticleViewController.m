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
	[self configureView];
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
	
	NSString *htmlFormat = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"article" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil];
	NSString *htmlToDisplay = [NSString stringWithFormat:htmlFormat, ratatatouilleCSSFile, mainCSSFile, self.article.title, self.article.link, self.article.content];
	
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
	if (navigationType != UIWebViewNavigationTypeOther)
	{
		[[UIApplication sharedApplication] openURL:request.URL];
		return FALSE;
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
