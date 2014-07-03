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
#import "WALNavigationController.h"

#import "WALServerConnection.h"
#import "WALThemeOrganizer.h"
#import "WALTheme.h"

#import "WALArticle.h"
#import "WALArticleList.h"
#import "WALSettings.h"

#import <AFNetworking/AFHTTPRequestOperationManager.h>

@interface WALFeedTableViewController ()

@property (strong) WALArticleList* articleList;
@property (strong) WALSettings* settings;
@property BOOL showAllArticles;
- (IBAction)actionsButtonPushed:(id)sender;

@end

@implementation WALFeedTableViewController

- (void)awakeFromNib
{
	self.showAllArticles = NO;
	
	[self.navigationController setToolbarHidden:true];
	
	WALThemeOrganizer *themeOrganizer = [WALThemeOrganizer sharedThemeOrganizer];
	[self updateWithTheme:[themeOrganizer getCurrentTheme]];
	[themeOrganizer subscribeToThemeChanges:self];
	
	UIColor *titleImageColor = SYSTEM_VERSION_LESS_THAN(@"7.0") ? [UIColor whiteColor] : [UIColor blackColor];
	UIImageView *titleImageView = [[UIImageView alloc] initWithImage:[self getWallabagTitleImageWithColor:titleImageColor]];
	titleImageView.bounds = CGRectInset(titleImageView.frame, 0.0f, 1.0f);
	titleImageView.contentMode = UIViewContentModeScaleAspectFit;
	self.navigationItem.titleView = titleImageView;
	
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
	if (self.showAllArticles)
		return [self.articleList getNumberOfAllArticles];
	
	return [self.articleList getNumberOfUnreadArticles];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	WALArticle *currentArticle;
	if (self.showAllArticles)
		currentArticle = [self.articleList getArticleAtIndex:indexPath.row];
	else
		currentArticle = [self.articleList getUnreadArticleAtIndex:indexPath.row];
	
	WALTheme *currentTheme = [[WALThemeOrganizer sharedThemeOrganizer] getCurrentTheme];
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ArticleCell" forIndexPath:indexPath];
	cell.textLabel.text = currentArticle.title;
	cell.textLabel.textColor = [currentTheme getTextColor];
	cell.detailTextLabel.text = @"";
	
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 60.0f;
}

#pragma mark - Theming

- (void)themeOrganizer:(WALThemeOrganizer *)organizer setNewTheme:(WALTheme *)theme
{
	[self updateWithTheme:theme];
	[self.tableView reloadData];
}

- (void) updateWithTheme:(WALTheme*) theme
{
	self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[self getWallabagTitleImageWithColor:[theme getTextColor]]];
	self.tableView.backgroundColor = [theme getBackgroundColor];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"PushToArticle"])
	{
		NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
		
		WALArticle *articleToSet;
		if (self.showAllArticles)
			articleToSet = [self.articleList getArticleAtIndex:indexPath.row];
		else
			articleToSet = [self.articleList getUnreadArticleAtIndex:indexPath.row];
		
		[((WALArticleViewController*)segue.destinationViewController) setDetailArticle:articleToSet];
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

- (IBAction)actionsButtonPushed:(id)sender
{
	UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
	[actionSheet setTitle:@"Actions"];
	
	[actionSheet addButtonWithTitle:@"Add Article"];
	[actionSheet addButtonWithTitle:@"Change to Night Theme"];
	[actionSheet addButtonWithTitle:@"Show all Articles"];
	
	[actionSheet addButtonWithTitle:@"cancel"];
	
	[actionSheet setCancelButtonIndex:3];
	[actionSheet setTag:1];
	[actionSheet setDelegate:self];
	[actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (actionSheet.tag == 1)
	{
		if (buttonIndex == 0)
		{
			[self performSegueWithIdentifier:@"ModalToAddArticle" sender:self];
		}
		else if (buttonIndex == 1)
		{
			WALThemeOrganizer *themeOrganizer = [WALThemeOrganizer sharedThemeOrganizer];
			[themeOrganizer changeTheme];
		}
		else if (buttonIndex == 2)
		{
			self.showAllArticles = self.showAllArticles ? NO : YES;
			[self.tableView reloadData];
		}
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

- (void)settingsController:(WALSettingsTableViewController *)settingsTableViewController didFinishWithSettings:(WALSettings*)settings
{
	if (settings)
	{
		self.settings = settings;
		[settings saveSettings];
		[self updateArticleList];
	}
	[self.navigationController dismissViewControllerAnimated:true completion:nil];
}

- (void)addArticleController:(WALAddArticleTableViewController *)addArticleController didFinishWithURL:(NSURL *)url
{
	[self.navigationController dismissViewControllerAnimated:true completion:nil];
	
	if (url)
	{
		NSURL *myUrl = [self.settings getURLToAddArticle:url];
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

#pragma mark - Miscellaneous

- (UIImage *)getWallabagTitleImageWithColor:(UIColor*) color
{
	if (SYSTEM_VERSION_LESS_THAN(@"7.0"))
		return [self ipMaskedImageNamed:@"NavigationBarItem" color:[UIColor whiteColor]];
	
	return [self ipMaskedImageNamed:@"NavigationBarItem" color:color];
}

- (UIImage *)ipMaskedImageNamed:(NSString *)name color:(UIColor *)color
{
    UIImage *image = [UIImage imageNamed:name];
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, image.scale);
    CGContextRef c = UIGraphicsGetCurrentContext();
    [image drawInRect:rect];
    CGContextSetFillColorWithColor(c, [color CGColor]);
    CGContextSetBlendMode(c, kCGBlendModeSourceAtop);
    CGContextFillRect(c, rect);
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

@end
