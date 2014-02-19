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
	NSURL *mainCSSFile = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"main" ofType:@"css"]];
	NSURL *ratatatouilleCSSFile = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"ratatouille" ofType:@"css"]];
	
	NSString *preHTML = [NSString stringWithFormat:@"<html lang=\"\"><head><meta name=\"viewport\" content=\"initial-scale=1.0\"><meta charset=\"utf-8\"><link rel=\"stylesheet\" href=\"%@\" media=\"all\"><link rel=\"stylesheet\" href=\"%@\" media=\"all\"><div id=\"main\"><body><div id=\"content\" class=\"w600p center\"><div id=\"article\"><header class=\"mbm\"><h1>%@</h1><p>%@</p></header><article>", ratatatouilleCSSFile, mainCSSFile, article.title, article.link];
	
	NSString *postHTML = @"</article></div></div></div></body></html>";
	
	self.article = article;
	self.title = article.title;
	self.article.content = [NSString stringWithFormat:@"%@%@%@",preHTML, article.content, postHTML];
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
