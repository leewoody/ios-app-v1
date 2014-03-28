//
//  WALMasterViewController.m
//  Wallabag
//
//  Created by Kevin Meyer on 19.02.14.
//  Copyright (c) 2014 Wallabag. All rights reserved.
//

#import "WALFeedTableViewController.h"
#import "WALArticleViewController.h"
#import "WALSettingsTableViewController.h"
#import "WALAddArticleTableViewController.h"
#import "WALArticle.h"
#import "WALSettings.h"
#import <AFNetworking/AFHTTPRequestOperationManager.h>

@interface WALFeedTableViewController ()
@property (strong) NSMutableArray* articles;
@property (strong) WALSettings* settings;

@property (strong) NSXMLParser* parser;
@property (strong) NSMutableArray* parser_articles;
@property (strong) NSString* parser_currentString;
@property (strong) WALArticle* parser_currentArticle;
@end

@implementation WALFeedTableViewController

- (void)awakeFromNib
{
	[self.navigationController setToolbarHidden:true];
	self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NavigationBarItem"]];
	
	self.refreshControl = [[UIRefreshControl alloc] init];
	[self.refreshControl addTarget:self action:@selector(triggeredRefreshControl) forControlEvents:UIControlEventValueChanged];
	[super awakeFromNib];
	
	[self loadArticles];
	if (!self.articles)
	{
		self.articles = [NSMutableArray array];
	}
	
	self.settings = [WALSettings settingsFromSavedSettings];
	
	if (self.settings)
		[self updateArticlesInformingUser:NO];
}

- (void) viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	if (!self.settings)
	{
		[self performSegueWithIdentifier:@"ModalToSettings" sender:self];
	}

}

- (void) didReceiveMemoryWarning
{
	[self.parser abortParsing];
	[self afterParsingComplete];
}

- (void)triggeredRefreshControl
{
	[self updateArticlesInformingUser:YES];
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
	cell.detailTextLabel.text = @"";
	
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 60.0f;
}

#pragma mark - DataParser

- (void) updateArticlesInformingUser:(BOOL) userGetsErrors
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	[self.refreshControl beginRefreshing];
	
	NSString *urlString = [NSString stringWithFormat:@"%@/?feed&type=home&user_id=%ld&token=%@", [self.settings.wallabagURL absoluteString], (long) self.settings.userID, self.settings.apiToken];
	
	AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
	
	[manager setResponseSerializer:[AFXMLParserResponseSerializer new]];
	manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/rss+xml"];
	
	manager.securityPolicy.allowInvalidCertificates = YES;

	[manager GET:urlString
	  parameters:nil
		 success:^(AFHTTPRequestOperation *operation, id responseObject)
	{
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		[self.refreshControl endRefreshing];
		self.parser_articles = [NSMutableArray array];
		self.parser = responseObject;
		self.parser.delegate = self;
		
		[self.parser parse];
	
	}
		 failure:^(AFHTTPRequestOperation *operation, NSError *error)
	{
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		[self.refreshControl endRefreshing];
		if (userGetsErrors)
			[self informUserConnectionError:error];
	}
	];
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
		[self addObjectToParserArray:self.parser_currentArticle];
		self.parser_currentArticle = nil;
		
		
		///! Quick Fix for Memory Errors when parsing too large feeds.
		if ([self.parser_articles count] > 50)
		{
			[parser abortParsing];
			[self afterParsingComplete];
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
	[self afterParsingComplete];
}

- (void) afterParsingComplete
{
	if (self.parser_articles)
		self.articles = self.parser_articles;
	
	self.parser_articles = nil;
	self.parser_currentArticle = nil;
	self.parser_currentString = nil;
	self.parser = nil;

	[self saveArticles];
	[self.tableView reloadData];
	
	if ([self.articles count] == 0)
	{
		[self informUserNoArticlesInFeed];
	}
}

- (void)addObjectToParserArray:(WALArticle*) newArticle
{
	for (WALArticle *correspondingArticle in self.articles)
	{
		if ([[correspondingArticle.link absoluteString] isEqualToString:[newArticle.link absoluteString]])
		{
			newArticle.archive = correspondingArticle.archive;
			break;
		}
	}
	
	[self.parser_articles addObject:newArticle];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"PushToArticle"])
	{
		NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
		[((WALArticleViewController*)segue.destinationViewController) setDetailArticle:self.articles[indexPath.row]];
		[[self.tableView cellForRowAtIndexPath:indexPath] setSelected:false animated:TRUE];
	}
	else if ([[segue identifier] isEqualToString:@"ModalToSettings"])
	{
		WALSettingsTableViewController *targetViewController = ((WALSettingsTableViewController*)[segue.destinationViewController viewControllers][0]);
		targetViewController.delegate = self;
		[targetViewController setSettings:self.settings];
	}
	else if ([[segue identifier] isEqualToString:@"ModalToAddArticle"])
	{
		WALAddArticleTableViewController *targetViewController = ((WALAddArticleTableViewController*)[segue.destinationViewController viewControllers][0]);
		targetViewController.delegate = self;
	}
}

#pragma mark - Callback Delegates

- (void)callbackFromSettingsController:(WALSettingsTableViewController *)settingsTableViewController withSettings:(WALSettings*)settings
{
	if (settings)
	{
		self.settings = settings;
		[settings saveSettings];
		[self updateArticlesInformingUser:YES];
	}
	[self.navigationController dismissViewControllerAnimated:true completion:nil];
}

- (void)callbackFromAddArticleController:(WALAddArticleTableViewController *)addArticleController withURL:(NSURL *)url
{
	[self.navigationController dismissViewControllerAnimated:true completion:nil];
	
	if (url)
	{
		NSString *base64String = [self base64String:[url absoluteString]];
		NSURL *myUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/?action=add&url=%@", self.settings.wallabagURL, base64String]];
		
		[[UIApplication sharedApplication] openURL:myUrl];
	}
}

#pragma mark - Error Handling

- (void) informUserConnectionError:(NSError*) error
{
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
														message:error.localizedDescription
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles: nil];
	[alertView show];
}

- (void) informUserWrongServerAddress
{
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
														message:NSLocalizedString(@"Could not connect to server. Maybe wrong URL?", @"error description: HTTP Status Code not 2xx")
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles: nil];
	[alertView show];
}

- (void) informUserWrongAuthentication
{
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
														message:NSLocalizedString(@"Could load feed. Maybe wrong user credentials?", @"error description: response is not a rss feed")
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles: nil];
	[alertView show];
}

- (void) informUserNoArticlesInFeed
{
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
														message:NSLocalizedString(@"No unread article in Feed. Get started by adding links to your wallabag.", @"error description: No article in home-feed")
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles: nil];
	[alertView show];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
	NSLog(@"Parsing Error: %@", parseError.description);
	[self afterParsingComplete];
}

#pragma mark - Save Articles

- (void) saveArticles
{
	[NSKeyedArchiver archiveRootObject:self.articles toFile:[self pathToSavedArticles]];
}

- (void) loadArticles
{
	self.articles = [NSKeyedUnarchiver unarchiveObjectWithFile:[self pathToSavedArticles]];
}

- (NSURL*)applicationDataDirectory {
    NSFileManager* sharedFM = [NSFileManager defaultManager];
    NSArray* possibleURLs = [sharedFM URLsForDirectory:NSApplicationSupportDirectory
                                             inDomains:NSUserDomainMask];
    NSURL* appSupportDir = nil;
    NSURL* appDirectory = nil;
    
    if ([possibleURLs count] >= 1) {
        // Use the first directory (if multiple are returned)
        appSupportDir = [possibleURLs objectAtIndex:0];
    }
    
    // If a valid app support directory exists, add the
    // app's bundle ID to it to specify the final directory.
    if (appSupportDir) {
        NSString* appBundleID = [[NSBundle mainBundle] bundleIdentifier];
        appDirectory = [appSupportDir URLByAppendingPathComponent:appBundleID];
    }
    
    return appDirectory;
}

- (NSString*) pathToSavedArticles
{
	NSURL *applicationSupportURL = [self applicationDataDirectory];
    
    if (! [[NSFileManager defaultManager] fileExistsAtPath:[applicationSupportURL path]]){
		
        NSError *error = nil;
        
        [[NSFileManager defaultManager] createDirectoryAtPath:[applicationSupportURL path]
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&error];
        
        if (error){
            NSLog(@"error creating app support dir: %@", error);
        }
        
    }
    NSString *path = [[applicationSupportURL path] stringByAppendingPathComponent:@"savedArticles.plist"];
    
    return path;
}

- (NSString *)base64String:(NSString *)str
{
    NSData *theData = [str dataUsingEncoding: NSASCIIStringEncoding];
    const uint8_t* input = (const uint8_t*)[theData bytes];
    NSInteger length = [theData length];
	
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
	
    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;
	
    NSInteger i;
    for (i=0; i < length; i += 3) {
        NSInteger value = 0;
        NSInteger j;
        for (j = i; j < (i + 3); j++) {
            value <<= 8;
			
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
		
        NSInteger theIndex = (i / 3) * 4;
        output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
        output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
	
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}

@end
