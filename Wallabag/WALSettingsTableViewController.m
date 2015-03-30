//
//  WALSettingsTableViewController.m
//  Wallabag
//
//  Created by Kevin Meyer on 19.02.14.
//  Copyright (c) 2014 Wallabag. All rights reserved.
//

#define APP_ID 828331015
#define APP_STORE_URI @"itms-apps://itunes.apple.com/us/app/wallabag/id828331015"
#define APP_STORE_URL @"https://itunes.apple.com/us/app/wallabag/id828331015"

#define DOC_INSTALLATION @"http://tiny.cc/wbg-ios-install"
#define DOC_FAQ @"http://tiny.cc/wbg-ios-faq"
#define DOC_IOS_HELP @"http://tiny.cc/wbg-ios-conf"

#import "WALSupportHelper.h"
#import <StoreKit/StoreKit.h>
#import "WALSettingsTableViewController.h"
#import "WALSettings.h"

#import "WALStorageHelper.h"
#import "WALLoginSalt.h"
#import "WALUser.h"

@interface WALSettingsTableViewController ()

@property (strong) WALSettings* currentSettings;

- (IBAction)cancelButtonPushed:(id)sender;
- (IBAction)doneButtonPushed:(id)sender;
- (IBAction)userInputValueChanged:(id)sender;

@property (weak, nonatomic) IBOutlet UISegmentedControl *versionControl;
@property (weak, nonatomic) IBOutlet UITextField *urlTextField;
@property (weak, nonatomic) IBOutlet UITextField *userIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *apiTokenTextField;

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@property (weak, nonatomic) IBOutlet UILabel *loginStatusLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loginActivityIndicator;
@end

@implementation WALSettingsTableViewController

- (void) setSettings:(WALSettings*) settings
{
	self.currentSettings = settings;
	
	if (!self.currentSettings)
	{
		self.currentSettings = [[WALSettings alloc] init];
		self.navigationItem.leftBarButtonItem = nil;
		return;
	}
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	if ([self.currentSettings getWallabagURL])
	{
		self.urlTextField.text = self.currentSettings.wallabagURL.absoluteString;
		self.apiTokenTextField.text = self.currentSettings.apiToken;
		self.userIDTextField.text = [NSString stringWithFormat:@"%ld", (long) self.currentSettings.userID];
		self.versionControl.selectedSegmentIndex = self.currentSettings.isVersionV2 ? 1 : 0;

		if (self.currentSettings.user) {
			self.usernameTextField.text = self.currentSettings.user.username;
			self.passwordTextField.text = @"some stars";
		}
	}
	[self updateView];
}

#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section != 0) {
		return [super tableView:tableView numberOfRowsInSection:section];
	}

	return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section != 0 || indexPath.row < 2 || self.versionControl.selectedSegmentIndex != 1) {
		return [super tableView:tableView cellForRowAtIndexPath:indexPath];
	}
	
	return [super tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:(indexPath.row + 3) inSection:0]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString* identifier = [[tableView cellForRowAtIndexPath:indexPath] reuseIdentifier];
	
	if ([identifier isEqualToString:@"LoginCell"]) {
		[self.loginActivityIndicator startAnimating];
		[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]].accessoryType = UITableViewCellAccessoryNone;
		[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]].accessoryType = UITableViewCellAccessoryNone;


		NSURL *url = [NSURL URLWithString:self.urlTextField.text];
		NSString *username = self.usernameTextField.text;
		NSString *password = self.passwordTextField.text;
		
		NSString *path = [NSString stringWithFormat:@"api/salts/%@.json", username];
		
		RKObjectManager *objectManager = [WALStorageHelper loginObjectManagerWithBaseURL:url];
		[objectManager getObject:nil path:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
			NSString *salt = ((WALLoginSalt *)mappingResult.array.firstObject).salt;
			NSLog(@"User: %@ has salt: %@", username, salt);

			WALUser *user = [[WALUser alloc] initWithUsername:username clearPassword:password andSalt:salt];
			NSLog(@"User: %@ hashedPassword: %@", user.username, user.passwordHashed);

			self.currentSettings.user = user;

			[self.loginActivityIndicator stopAnimating];
			[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]].accessoryType = UITableViewCellAccessoryCheckmark;
			[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]].accessoryType = UITableViewCellAccessoryCheckmark;
		} failure:^(RKObjectRequestOperation *operation, NSError *error) {
			[self.loginActivityIndicator stopAnimating];
			NSLog(@"Couldn't get salt!");
		}];
		
	}
	else if ([identifier isEqualToString:@"FindData"])
	{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Help", @"Alert view title: Where can I find user data")
															message:NSLocalizedString(@"Login to your Wallabag and browse to the configuration.\nFind the \"Feeds\" section together with your user-ID and token.\nYou may have to click \"generate token\" first, if the token is missing.", @"Alert view Info text: where can i find user data")
														   delegate:self
												  cancelButtonTitle:NSLocalizedString(@"OK", @"OK-Button tilte alert view: where can i find user data")
												  otherButtonTitles:NSLocalizedString(@"Open Manual", @"Open Website for detailed user guide where to find user data"), nil];
		[alertView show];
	}
	else if ([identifier isEqualToString:@"Framabag"])
	{
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://framabag.org"]];
	}
	else if ([identifier isEqualToString:@"InstallationGuide"])
	{
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:DOC_INSTALLATION]];
	}
	else if ([identifier isEqualToString:@"WallabagFAQ"])
	{
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:DOC_FAQ]];
	}
	else if ([identifier isEqualToString:@"SupportMail"])
	{
		[self openFeedbackMailView];
	}
	else if ([identifier isEqualToString:@"WallabagTwitter"])
	{
		NSURL *twitterIRL = [NSURL URLWithString:@"twitter://user?screen_name=wallabagapp"];
		NSURL *tweetbotIRL = [NSURL URLWithString:@"tweetbot:///user_profile/wallabagapp"];
		NSURL *twitterrifficIRL = [NSURL URLWithString:@"twitterrific:///profile?screen_name=Iconfactory"];
		
		if ([[UIApplication sharedApplication] canOpenURL:tweetbotIRL])
			[[UIApplication sharedApplication] openURL:tweetbotIRL];
		
		else if ([[UIApplication sharedApplication] canOpenURL:twitterrifficIRL])
			[[UIApplication sharedApplication] openURL:twitterrifficIRL];
		
		else if ([[UIApplication sharedApplication] canOpenURL:twitterIRL])
			[[UIApplication sharedApplication] openURL:twitterIRL];
		
		else
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://twitter.com/wallabagapp"]];
	}
	else if ([identifier isEqualToString:@"WallabagFacebook"])
	{
		NSURL *facebookIRL = [NSURL URLWithString:@"fb://profile/369698693171294"];
		
		if ([[UIApplication sharedApplication] canOpenURL:facebookIRL])
			[[UIApplication sharedApplication] openURL:facebookIRL];

		else
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.facebook.com/wallabag"]];
	}
	else if ([identifier isEqualToString:@"RateApp"])
	{
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:APP_STORE_URI]];
	}
	else if ([identifier isEqualToString:@"TellYourFriends"])
	{
		NSArray* dataToShare = @[NSLocalizedString(@"Hey there!\nI'm using the read-it-later app wallabag. You should check it out!", nil), [NSURL URLWithString:APP_STORE_URL]];
				
		UIActivityViewController* activityViewController =
		[[UIActivityViewController alloc] initWithActivityItems:dataToShare applicationActivities:nil];
		[self presentViewController:activityViewController animated:YES completion:^{}];
	}
	else if ([identifier isEqualToString:@"License"])
	{
		[self performSegueWithIdentifier:@"PushToLicense" sender:self];
	}
	else if ([identifier isEqualToString:@"IssueOnGitHub"])
	{
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/wallabag/ios-app/issues?state=open"]];
	}
	[[tableView cellForRowAtIndexPath:indexPath] setSelected:false animated:true];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	if (section == 3)
	{
		NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
		NSString *appBuildVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
		
		NSString *appInfo = [NSString stringWithFormat:@"Version: %@ (build: %@)\nDeveloped by: Kevin Meyer", appVersion, appBuildVersion];
		
		return appInfo;
	}
	
	return [super tableView:tableView titleForFooterInSection:section];
}

#pragma mark - AlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1)
	{
		//! @todo use iPhone Docu Link!
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:DOC_IOS_HELP]];
	}
	
}

#pragma mark - Button Actions

- (void)updateCurrentSettingsFromUserInput {
	if (!self.currentSettings) {
		self.currentSettings = [[WALSettings alloc] init];
	}
	self.currentSettings.wallabagURL = [NSURL URLWithString:self.urlTextField.text];
	self.currentSettings.apiToken = self.apiTokenTextField.text;
	self.currentSettings.userID = [self.userIDTextField.text integerValue];
	[self.currentSettings setVersionV2:(self.versionControl.selectedSegmentIndex == 1)];
}

- (void) updateView
{
	[self.navigationItem.rightBarButtonItem setEnabled:self.currentSettings.isValid];
}

- (IBAction)cancelButtonPushed:(id)sender
{
	[self.delegate settingsController:self didFinishWithSettings:nil];
}

- (IBAction)doneButtonPushed:(id)sender
{
	[self updateCurrentSettingsFromUserInput];
	[self.delegate settingsController:self didFinishWithSettings:self.currentSettings];
}

- (IBAction)userInputValueChanged:(id)sender
{
	[self updateCurrentSettingsFromUserInput];
	[self updateView];
	if ([sender isKindOfClass:[UISegmentedControl class]]) {
		[self.tableView beginUpdates];
		
		NSArray *updatePaths = @[[NSIndexPath indexPathForRow:2 inSection:0], [NSIndexPath indexPathForRow:3 inSection:0], [NSIndexPath indexPathForRow:4 inSection:0]];
		if (self.versionControl.selectedSegmentIndex == 1) {
			[self.tableView reloadRowsAtIndexPaths:updatePaths withRowAnimation:UITableViewRowAnimationAutomatic];
		} else {
			[self.tableView reloadRowsAtIndexPaths:updatePaths withRowAnimation:UITableViewRowAnimationAutomatic];
		}
		
		[self.tableView endUpdates];
	}
}

#pragma mark - TextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	
	return YES;
}

#pragma mark - Mail Composer

- (void) openFeedbackMailView
{
	if ([MFMailComposeViewController canSendMail]) {
		
		NSString *message = [WALSupportHelper getBodyForSupportMail];
		
		MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
		mailViewController.mailComposeDelegate = self;
		[mailViewController setToRecipients:[NSArray arrayWithObject:@"wallabag@kevin-meyer.de"]];
		[mailViewController setSubject:@"Feedback wallabag iOS-App"];
		[mailViewController setMessageBody:message isHTML:NO];
		
		[self presentViewController:mailViewController animated:YES completion:nil];
	}
}


- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
