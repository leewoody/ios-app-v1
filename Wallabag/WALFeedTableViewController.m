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
#import "WALArticleTableViewCell.h"
#import "WALAppDelegate.h"
#import "WALStorageHelper.h"
#import "WALUpdateHelper.h"

#import "WALThemeOrganizer.h"
#import "WALTheme.h"
#import "WALIcons.h"

#import "WALArticle.h"
#import "WALSettings.h"

@interface WALFeedTableViewController ()

@property (strong) WALSettings* settings;
- (IBAction)actionsButtonPushed:(id)sender;

@property (strong) UIActionSheet* actionSheet;

@property (weak) IBOutlet UISegmentedControl *headerSegmentedControl;
- (IBAction)headerSegmentedControlValueDidChange:(id)sender;
@end

@implementation WALFeedTableViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.managedObjectContext = [RKManagedObjectStore defaultStore].mainQueueManagedObjectContext;
	
	WALThemeOrganizer *themeOrganizer = [WALThemeOrganizer sharedThemeOrganizer];
	[self updateWithTheme:[themeOrganizer getCurrentTheme]];
	[themeOrganizer subscribeToThemeChanges:self];
	
	self.refreshControl = [[UIRefreshControl alloc] init];
	[self.refreshControl addTarget:self action:@selector(triggeredRefreshControl) forControlEvents:UIControlEventValueChanged];
	[super awakeFromNib];
	
	self.settings = [WALSettings settingsFromSavedSettings];
	
//	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad && [self.articleList getNumberOfUnreadArticles] > 0)
//	{
//		NSIndexPath *firstCellIndex = [NSIndexPath indexPathForRow:0 inSection:0];
//		[self performSegueWithIdentifier:@"PushToArticle" sender:[self.tableView cellForRowAtIndexPath:firstCellIndex]];
//		[self.tableView selectRowAtIndexPath:firstCellIndex animated:NO scrollPosition:UITableViewScrollPositionNone];
//	}
}

- (void) viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[self.navigationController setToolbarHidden:YES];
	
	if (!self.settings || !self.settings.isValid)
		[self performSegueWithIdentifier:@"ModalToSettings" sender:self];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.navigationController setToolbarHidden:animated];
}

- (void)triggeredRefreshControl {
	[self updateFeedFromServer];
}

#pragma mark -

- (IBAction)headerSegmentedControlValueDidChange:(id)sender {
	UISegmentedControl *control = (UISegmentedControl*) sender;
	[self updateFetchRequestWithFeedNumber:control.selectedSegmentIndex];
}

- (void)updateFeedFromServer {
	if (!self.refreshControl.isRefreshing) {
		[self.refreshControl beginRefreshing];
	}
	
	[[RKObjectManager sharedManager] getObjectsAtPathForRouteNamed:@"articles" object:nil parameters:[WALUpdateHelper parametersForGetArticlesWithSettings:self.settings] success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
		NSError *error;
		if (![[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext saveToPersistentStore:&error]) {
			NSLog(@"Error storing: %@", error);
		}
		[self.refreshControl endRefreshing];
	} failure:^(RKObjectRequestOperation *operation, NSError *error) {
		[self informUserConnectionError:error];
		[self.refreshControl endRefreshing];
	}];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
	return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WALArticleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ArticleCell" forIndexPath:indexPath];
	[self configureCell:cell atIndexPath:indexPath];
	return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	WALArticle *article = [self.fetchedResultsController objectAtIndexPath:indexPath];
	static NSDateFormatter *formatter;
	if (!formatter) {
		formatter = [[NSDateFormatter alloc] init];
		formatter.dateStyle = NSDateFormatterShortStyle;
		formatter.timeStyle = NSDateFormatterShortStyle;
		formatter.doesRelativeDateFormatting = YES;
	}
	
	NSString *relativeDate = @"";
	if (article.createdAt) {
		relativeDate = [formatter stringFromDate:article.createdAt];
	}
	
	WALArticleTableViewCell *articleCell = (WALArticleTableViewCell*)cell;
	articleCell.titleLabel.text = article.title;
	articleCell.detailLabel.text = article.url.host;
	articleCell.dateLabel.text = relativeDate;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	WALArticle *article = [self.fetchedResultsController objectAtIndexPath:indexPath];

	CGFloat constantHeight = 15.0f + 8.0f;
	NSString *cellTitle = article.title;
	CGFloat tableWidth = floor(tableView.bounds.size.width);
	CGSize maximumLabelSize = CGSizeMake(tableWidth - (15.0f + 12.0f + 33.0f), FLT_MAX);
	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
		maximumLabelSize = CGSizeMake(tableWidth - (15.0f + 15.0f), FLT_MAX);
	}

	CGRect expectedLabelSize = [cellTitle boundingRectWithSize:maximumLabelSize
													   options:NSStringDrawingUsesLineFragmentOrigin
													attributes:@{NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleBody]}
													   context:nil];

	return constantHeight + ceil(expectedLabelSize.size.height);
}

#pragma mark - Core Data: FetchedResultsController

- (NSFetchedResultsController *)fetchedResultsController
{
	if (_fetchedResultsController != nil) {
		return _fetchedResultsController;
	}
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	// Edit the entity name as appropriate.
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Article" inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	
	// Set the batch size to a suitable number.
	[fetchRequest setFetchBatchSize:20];
	
	// Set Predicate
	fetchRequest.predicate = [self getPredicateForFeedWithNumber:0];
	
	// Edit the sort key as appropriate.
	NSSortDescriptor *sortByDate = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:NO];
	NSSortDescriptor *sortById = [[NSSortDescriptor alloc] initWithKey:@"articleID" ascending:NO];
	NSArray *sortDescriptors = @[sortByDate, sortById];
	
	[fetchRequest setSortDescriptors:sortDescriptors];
	
	// Edit the section name key path and cache name if appropriate.
	// nil for section name key path means "no sections".
	NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
	aFetchedResultsController.delegate = self;
	self.fetchedResultsController = aFetchedResultsController;
	
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
		// Replace this implementation with code to handle the error appropriately.
		// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
	return _fetchedResultsController;
}

- (void)updateFetchRequestWithFeedNumber:(NSInteger) feedNumber {
	[NSFetchedResultsController deleteCacheWithName:self.fetchedResultsController.cacheName];
	self.fetchedResultsController.fetchRequest.predicate = [self getPredicateForFeedWithNumber:feedNumber];

	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
		// Replace this implementation with code to handle the error appropriately.
		// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
	[self.tableView reloadData];
}

- (NSPredicate *)getPredicateForFeedWithNumber:(NSInteger) feedNumber {
	NSPredicate *feedPredicate = nil;
	if (feedNumber == 1) {
		// Feed: Faved
		feedPredicate = [NSPredicate predicateWithFormat:@"(starred = YES)"];
	} else if (feedNumber == 2) {
		// Feed: Archive
		feedPredicate = [NSPredicate predicateWithFormat:@"(read = YES)"];
	} else {
		// Feed: Unread
		feedPredicate = [NSPredicate predicateWithFormat:@"(read = NO)"];
	}
	return feedPredicate;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
	[self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
		   atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
	switch(type) {
		case NSFetchedResultsChangeInsert:
			[self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		default:
			return;
	}
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
	   atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(NSIndexPath *)newIndexPath
{
	UITableView *tableView = self.tableView;
	
	switch(type) {
		case NSFetchedResultsChangeInsert:
			[tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeUpdate:
			[self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
			break;
			
		case NSFetchedResultsChangeMove:
			[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
			[tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
	[self.tableView endUpdates];
}

#pragma mark - Theming

- (void)themeOrganizer:(WALThemeOrganizer *)organizer setNewTheme:(WALTheme *)theme
{
	[self updateWithTheme:theme];
	[self.tableView reloadData];
}

- (void) updateWithTheme:(WALTheme*) theme
{
//	self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[self getWallabagTitleImageWithColor:[theme getTextColor]]];
	self.tableView.backgroundColor = [theme getBackgroundColor];
	self.refreshControl.tintColor = [theme getTextColor];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"PushToArticle"])
	{
		NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];

		WALArticle *article = [self.fetchedResultsController objectAtIndexPath:indexPath];
		WALArticleViewController *articleVC;
		
		if ([segue.destinationViewController isKindOfClass:[UINavigationController class]])
		{
			UINavigationController *navigationVC = (UINavigationController*) segue.destinationViewController;
			articleVC = (WALArticleViewController*) navigationVC.viewControllers[0];
		}
		else
			articleVC = (WALArticleViewController*) segue.destinationViewController;
			
		[articleVC setDetailArticle:article];
		
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
	if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
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
		[self.actionSheet addButtonWithTitle:NSLocalizedString(@"cancel", nil)];
		
		[self.actionSheet setCancelButtonIndex:3];
		[self.actionSheet setTag:1];
		[self.actionSheet setDelegate:self];
		[self.actionSheet showFromBarButtonItem:sender animated:YES];
	} else {
		UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Actions", nil) message:nil preferredStyle:UIAlertControllerStyleActionSheet];
		
		[alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Add Article", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
			[self actionsAddArticlePushed];
		}]];
		[alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Change Theme", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
			[self actionsChangeThemePushed];
		}]];
		
		[alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
		
		UIPopoverPresentationController *popoverController = alertController.popoverPresentationController;
		popoverController.barButtonItem = self.navigationItem.rightBarButtonItem;
		popoverController.permittedArrowDirections = UIPopoverArrowDirectionAny;
		
		[self presentViewController:alertController animated:YES completion:nil];
	}
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (actionSheet.tag == 1) {
		if (buttonIndex == 0) {
			[self actionsAddArticlePushed];
		}
		else if (buttonIndex == 1) {
			[self actionsChangeThemePushed];
		}
	}
	self.actionSheet = nil;
}

- (void) actionsAddArticlePushed {
	[self performSelector:@selector(showAddArticleViewController) withObject:nil afterDelay:0];
}

- (void) actionsChangeThemePushed {
	WALThemeOrganizer *themeOrganizer = [WALThemeOrganizer sharedThemeOrganizer];
	[themeOrganizer changeTheme];
}

- (void) showAddArticleViewController {
	[self performSegueWithIdentifier:@"ModalToAddArticle" sender:self];
}

#pragma mark - Callback Delegates

- (void)settingsController:(WALSettingsTableViewController *)settingsTableViewController didFinishWithSettings:(WALSettings*)settings
{
	if (settings) {
		self.settings = settings;
		[settings saveSettings];
		[WALStorageHelper updateRestKitWithNewSettings];
		[self updateFeedFromServer];
	}
	[self.navigationController dismissViewControllerAnimated:true completion:nil];
}

- (void)addArticleController:(WALAddArticleTableViewController *)addArticleController didFinishWithURL:(NSURL *)url
{
	[self.navigationController dismissViewControllerAnimated:true completion:nil];
	if (url){
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"Article" inManagedObjectContext:self.managedObjectContext];
		WALArticle *newArticle = [[WALArticle alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];
		newArticle.url = url;
		newArticle.title = @"Adding Article";
		newArticle.createdAt = [NSDate date];

		[[RKObjectManager sharedManager] postObject:newArticle path:nil parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
			NSLog(@"Added Article");
		} failure:^(RKObjectRequestOperation *operation, NSError *error) {
			NSLog(@"Error adding Article: %@", error);
			[self informUserConnectionError:error];
		}];
	}
}

#pragma mark - Error Handling

- (void) informUserConnectionError:(NSError*) error {
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
														message:error.localizedDescription
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles: nil];
	[alertView show];
}

@end
