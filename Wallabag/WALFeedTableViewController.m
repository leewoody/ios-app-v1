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

#import "WALServerConnection.h"

#import "WALArticle.h"
#import "WALArticleList.h"
#import "WALSettings.h"

#import <AFNetworking/AFHTTPRequestOperationManager.h>

@interface WALFeedTableViewController ()

@property (strong) WALArticleList* articleList;
@property (strong) WALSettings* settings;

@end

@implementation WALFeedTableViewController

- (void)awakeFromNib
{
	[self.navigationController setToolbarHidden:true];
	self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NavigationBarItem"]];
	
	self.refreshControl = [[UIRefreshControl alloc] init];
	[self.refreshControl addTarget:self action:@selector(triggeredRefreshControl) forControlEvents:UIControlEventValueChanged];
	[super awakeFromNib];
	
	self.articleList = [[WALArticleList alloc] init];
	[self.articleList loadArticlesFromDisk];
	self.settings = [WALSettings settingsFromSavedSettings];
	
	if (self.settings) {
		[self updateArticleList];
	}
}

- (void) viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	if (!self.settings)
	{
		[self performSegueWithIdentifier:@"ModalToSettings" sender:self];
	}

}

- (void)triggeredRefreshControl
{
	[self updateArticleList];
}

#pragma mark -

- (void)updateArticleList
{
	WALServerConnection *server = [[WALServerConnection alloc] init];
	[server loadArticlesWithSettings:self.settings OldArticleList:self.articleList delegate:self];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	[self.refreshControl beginRefreshing];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.articleList getNumberOfUnreadArticles];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	WALArticle *currentArticle = [self.articleList getUnreadArticleAtIntex:indexPath.row];
	
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



#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"PushToArticle"])
	{
		NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
		[((WALArticleViewController*)segue.destinationViewController) setDetailArticle:[self.articleList getUnreadArticleAtIntex:indexPath.row]];
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

- (void)serverConnection:(WALServerConnection *)connection didFinishWithArticleList:(WALArticleList *)articleList
{
	[self.articleList deleteCachedArticles];
	self.articleList = articleList;
	[self.articleList saveArticlesFromDisk];
	[self.articleList updateUnreadArticles];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[self.refreshControl endRefreshing];
	
	[self.tableView reloadData];
}

- (void)serverConnection:(WALServerConnection *)connection didFinishWithError:(NSError *)error
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[self.refreshControl endRefreshing];
	
	[self informUserConnectionError:error];
}

- (void)callbackFromSettingsController:(WALSettingsTableViewController *)settingsTableViewController withSettings:(WALSettings*)settings
{
	if (settings)
	{
		self.settings = settings;
		[settings saveSettings];
		assert(false);
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

#pragma mark - Save Articles

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
