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
}

#pragma mark - Managing the detail item

- (void) setDetailArticle:(WALArticle*) article
{
	self.article = article;
	self.title = article.title;
}

- (void) configureView
{
	[self.webView loadHTMLString:self.article.content baseURL:nil];
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

@end
