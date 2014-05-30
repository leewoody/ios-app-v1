//
//  WALServerConnection.m
//  Wallabag
//
//  Created by Kevin Meyer on 30.05.14.
//  Copyright (c) 2014 Wallabag. All rights reserved.
//

#import "WALServerConnection.h"
#import "WALArticle.h"
#import "WALSettings.h"
#import "WALArticleList.h"
#import <AFNetworking/AFHTTPRequestOperationManager.h>

@interface WALServerConnection ()
@property (strong) WALSettings* settings;

@property (strong) NSXMLParser* parser;
@property (strong) WALArticleList* parser_articleList;
@property (strong) NSString* parser_currentString;
@property (strong) WALArticle* parser_currentArticle;

@property (strong) WALArticleList* oldArticleList;
@property (weak) id<WALServerConnectionDelegate> delegate;

@end

@implementation WALServerConnection

- (void) loadArticlesWithSettings:(WALSettings*) settings OldArticleList:(WALArticleList*) articleList delegate:(id<WALServerConnectionDelegate>) delegate
{
	self.oldArticleList = articleList;
	self.delegate = delegate;
	self.settings = settings;
	
	[self downloadAndStartParsing];
}

- (void) downloadAndStartParsing
{
	NSString *urlString = [NSString stringWithFormat:@"%@/?feed&type=home&user_id=%ld&token=%@", [self.settings.wallabagURL absoluteString], (long) self.settings.userID, self.settings.apiToken];
	
	AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
	
	[manager setResponseSerializer:[AFXMLParserResponseSerializer new]];
	manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/rss+xml", @"application/xml", @"text/xml", nil];
	
	manager.securityPolicy.allowInvalidCertificates = YES;
	
	[manager GET:urlString
	  parameters:nil
		 success:^(AFHTTPRequestOperation *operation, id responseObject)
	 {
		 self.parser_articleList = [[WALArticleList alloc] init];
		 self.parser = responseObject;
		 self.parser.delegate = self;
		 
		 [self.parser parse];
		 
	 }
		 failure:^(AFHTTPRequestOperation *operation, NSError *error)
	 {
		 NSLog(@"Loading Error: %@", error.description);
	 }
	 ];

}

#pragma mark - XML Parser

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
	if ([elementName isEqualToString:@"item"])
	{
		self.parser_currentArticle = [[WALArticle alloc] init];
	}
	
	self.parser_currentString = nil;
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	if ([elementName isEqualToString:@"item"])
	{
		[self mergeArticleWithOldArticles:self.parser_currentArticle];
		[self.parser_articleList addArticle:self.parser_currentArticle];
		self.parser_currentArticle = nil;
		
		
		///! Quick Fix for Memory Errors when parsing too large feeds.
		if ([self.parser_articleList getNumberOfUnreadArticles] > 50)
		{
			[parser abortParsing];
			[self parsingDone];
		}
	}
	else if ([elementName isEqualToString:@"title"])
	{
		self.parser_currentArticle.title = [self.parser_currentString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];;
	}
	else if ([elementName isEqualToString:@"link"])
	{
		self.parser_currentArticle.link = [NSURL URLWithString:self.parser_currentString];
	}
	else if ([elementName isEqualToString:@"pubDate"])
	{
		[self.parser_currentArticle setDateWithString:self.parser_currentString];
	}
	else if ([elementName isEqualToString:@"description"])
	{
		self.parser_currentArticle.content = self.parser_currentString;
	}
	else if ([elementName isEqualToString:@"source"])
	{
		self.parser_currentArticle.source = [NSURL URLWithString:self.parser_currentString];
	}
	
	self.parser_currentString = nil;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	if (self.parser_currentString != nil)
		self.parser_currentString = [self.parser_currentString stringByAppendingString:string];
	else
		self.parser_currentString = string;
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
	NSLog(@"Parsing Error: %@", parseError.description);
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
	[self parsingDone];
}


#pragma mark -

- (void)parsingDone
{
	[self.delegate serverConnection:self didFinishWithArticleList:self.parser_articleList];
	
	self.oldArticleList = nil;
	self.delegate = nil;
}

- (void) mergeArticleWithOldArticles:(WALArticle*) article
{
	WALArticle *oldArticle = [self.oldArticleList getArticleWithLink:article.link];
	
	if (oldArticle)
	{
		article.archive = oldArticle.archive;
	}
}

@end
