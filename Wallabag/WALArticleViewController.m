//
//  WALDetailViewController.m
//  Wallabag
//
//  Created by Kevin Meyer on 19.02.14.
//  Copyright (c) 2014 Wallabag. All rights reserved.
//

#import "WALArticleViewController.h"
#import "WALArticle.h"
#import "WALBrowserViewController.h"

@interface WALArticleViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong) WALArticle *article;
@property (strong) NSURL *externalURL;
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
	NSString *htmlToDisplay = [NSString stringWithFormat:htmlFormat, ratatatouilleCSSFile, mainCSSFile, self.article.title, self.article.link, self.article.link,  [self.article getContent]];
	
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
		//[[UIApplication sharedApplication] openURL:request.URL];
		self.externalURL = request.URL;
		[self performSegueWithIdentifier:@"PushToBrowser" sender:nil];
		return FALSE;
	}
	
	return true;
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"PushToBrowser"])
	{
		[((WALBrowserViewController*)segue.destinationViewController) setStartURL:self.externalURL];
	}
}

@end
