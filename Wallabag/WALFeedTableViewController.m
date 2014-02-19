//
//  WALMasterViewController.m
//  Wallabag
//
//  Created by Kevin Meyer on 19.02.14.
//  Copyright (c) 2014 Wallabag. All rights reserved.
//

#import "WALFeedTableViewController.h"
#import "WALArticleViewController.h"
#import "WALArticle.h"

@interface WALFeedTableViewController ()
@property (strong) NSMutableArray* articles;
@property (strong) NSString* parser_currentString;
@property (strong) WALArticle* parser_currentArticle;
@end

@implementation WALFeedTableViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.articles = [[NSMutableArray alloc] init];
	[self updateArticles];
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.articles count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	WALArticle *currentArticle = [self.articles objectAtIndex:indexPath.row];
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ArticleCell" forIndexPath:indexPath];
	cell.textLabel.text = currentArticle.title;
	cell.detailTextLabel.text = [currentArticle getDateString];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 60.0f;
}

#pragma mark - DataParser

- (void) updateArticles
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	NSString *urlString = [NSString stringWithFormat:@"http://wallabag.scheissimweb.de/?feed&type=home&user_id=2&token=i11FbSBeC34bwTM"];
	
	NSURL *url = [NSURL URLWithString:urlString];
	NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLCacheStorageAllowed timeoutInterval:20.0];
	
	[NSURLConnection sendAsynchronousRequest:urlRequest
									   queue:[NSOperationQueue mainQueue]
						   completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
	{
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		
		NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:data];
		xmlParser.delegate = self;
		[xmlParser parse];
	}];
}

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
		[self.articles addObject:self.parser_currentArticle];
		self.parser_currentArticle = nil;
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
	
	self.parser_currentString = nil;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	if (self.parser_currentString != nil)
		self.parser_currentString = [self.parser_currentString stringByAppendingString:string];
	else
		self.parser_currentString = string;
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
	[self.tableView reloadData];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"pushToArticle"])
	{
		NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
		[((WALArticleViewController*)segue.destinationViewController) setDetailArticle:self.articles[indexPath.row]];
		[[self.tableView cellForRowAtIndexPath:indexPath] setSelected:false animated:TRUE];
	}
}

@end
