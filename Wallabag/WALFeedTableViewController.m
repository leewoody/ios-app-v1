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
#import "WALIcons.h"

#import "WALArticle.h"
#import "WALArticleList.h"
#import "WALSettings.h"

#import <AFNetworking/AFHTTPRequestOperationManager.h>

@interface WALFeedTableViewController ()

@property (strong) WALArticleList* articleList;
@property (strong) WALSettings* settings;
@property BOOL showAllArticles;
- (IBAction)actionsButtonPushed:(id)sender;

@property (strong) UIActionSheet* actionSheet;
@end

@implementation WALFeedTableViewController

- (void)awakeFromNib
{
	self.showAllArticles = NO;
		
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
	[self updateArticleList];
	
	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad && [self.articleList getNumberOfUnreadArticles] > 0)
	{
		NSIndexPath *firstCellIndex = [NSIndexPath indexPathForRow:0 inSection:0];
		[self performSegueWithIdentifier:@"PushToArticle" sender:[self.tableView cellForRowAtIndexPath:firstCellIndex]];
		[self.tableView selectRowAtIndexPath:firstCellIndex animated:NO scrollPosition:UITableViewScrollPositionNone];
	}
}

- (void) viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[self.navigationController setToolbarHidden:YES];
	
	if (!self.settings)
		[self performSegueWithIdentifier:@"ModalToSettings" sender:self];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.navigationController setToolbarHidden:animated];
}

- (void)triggeredRefreshControl
{
	[self updateArticleList];
}

#pragma mark -

- (void)updateArticleList
{
	if (!self.settings)
	{
		[self.refreshControl endRefreshing];
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		[self performSegueWithIdentifier:@"ModalToSettings" sender:self];
		return;
	}
	
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
	cell.backgroundColor = [currentTheme getBackgroundColor];
	
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
	self.refreshControl.tintColor = [theme getTextColor];
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
		
		WALArticleViewController *articleVC;
		
		if ([segue.destinationViewController isKindOfClass:[UINavigationController class]])
		{
			UINavigationController *navigationVC = (UINavigationController*) segue.destinationViewController;
			articleVC = (WALArticleViewController*) navigationVC.viewControllers[0];
		}
		else
			articleVC = (WALArticleViewController*) segue.destinationViewController;
			
		[articleVC setDetailArticle:articleToSet];
		
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
	if (self.actionSheet)
	{
		[self.actionSheet dismissWithClickedButtonIndex:-1 animated:YES];
		self.actionSheet = nil;
		return;
	}
	
	self.actionSheet = [[UIActionSheet alloc] init];
	self.actionSheet.title = NSLocalizedString(@"Actions", nil);
	
	[self.actionSheet addButtonWithTitle:NSLocalizedString(@"Add Article", nil)];
	[self.actionSheet addButtonWithTitle:NSLocalizedString(@"Change Theme", nil)];

	if (self.showAllArticles)
		[self.actionSheet addButtonWithTitle:NSLocalizedString(@"Show unread Articles", nil)];
	else
		[self.actionSheet addButtonWithTitle:NSLocalizedString(@"Show all Articles", nil)];
	
	[self.actionSheet addButtonWithTitle:NSLocalizedString(@"cancel", nil)];
	
	[self.actionSheet setCancelButtonIndex:3];
	[self.actionSheet setTag:1];
	[self.actionSheet setDelegate:self];
	[self.actionSheet showFromBarButtonItem:sender animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (actionSheet.tag == 1)
	{
		if (buttonIndex == 0)
		{
			[self performSelector:@selector(showAddArticleViewController) withObject:nil afterDelay:0];
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
	self.actionSheet = nil;
}

- (void) showAddArticleViewController {
	[self performSegueWithIdentifier:@"ModalToAddArticle" sender:self];
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
		if ([[UIApplication sharedApplication] canOpenURL:myUrl])
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
