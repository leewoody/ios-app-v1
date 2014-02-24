//
//  WALSettingsTableViewController.m
//  Wallabag
//
//  Created by Kevin Meyer on 19.02.14.
//  Copyright (c) 2014 Wallabag. All rights reserved.
//

#import <sys/utsname.h>
#import "WALSettingsTableViewController.h"
#import "WALSettings.h"

@interface WALSettingsTableViewController ()

@property (strong) WALSettings* currentSettings;

- (IBAction)cancelButtonPushed:(id)sender;
- (IBAction)doneButtonPushed:(id)sender;
- (IBAction)textFieldValueChanged:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *urlTextField;
@property (weak, nonatomic) IBOutlet UITextField *userIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *apiTokenTextField;
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
	
	if (self.currentSettings.wallabagURL && self.currentSettings.apiToken)
	{
		self.urlTextField.text = [self.currentSettings.wallabagURL absoluteString];
		self.userIDTextField.text = [NSString stringWithFormat:@"%ld", (long)self.currentSettings.userID];
		self.apiTokenTextField.text = self.currentSettings.apiToken;
	}
	[self updateDoneButton];
}

#pragma mark - TableView

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString* identifier = [[tableView cellForRowAtIndexPath:indexPath] reuseIdentifier];
	
	if ([identifier isEqualToString:@"FindData"])
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
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://doc.wallabag.org/doku.php?id=users:begin:install"]];
	}
	else if ([identifier isEqualToString:@"WallabagFAQ"])
	{
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.wallabag.org/frequently-asked-questions/"]];
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
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://doc.wallabag.org/doku.php?id=users:android_application"]];
	}
	
}

#pragma mark - Button Actions

- (void) updateDoneButton
{
	BOOL disabled = [self.urlTextField.text isEqualToString:@""] || [self.apiTokenTextField.text isEqualToString:@""] || [self.urlTextField.text isEqualToString:@""];
	
	[self.navigationItem.rightBarButtonItem setEnabled:!disabled];
}

- (IBAction)cancelButtonPushed:(id)sender
{
	[self.delegate callbackFromSettingsController:self withSettings:nil];
}

- (IBAction)doneButtonPushed:(id)sender
{
	self.currentSettings.wallabagURL = [NSURL URLWithString:self.urlTextField.text];
	self.currentSettings.apiToken = self.apiTokenTextField.text;
	self.currentSettings.userID = [self.userIDTextField.text integerValue];
	
	[self.delegate callbackFromSettingsController:self withSettings:self.currentSettings];
}

- (IBAction)textFieldValueChanged:(id)sender
{
	[self updateDoneButton];
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
		
		struct utsname systemInfo;
		uname(&systemInfo);
		
		NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
		NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
		NSString *appBuildVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
		NSString *deviceModel = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
		NSString *selectedURL = [self.currentSettings.wallabagURL absoluteString];
		NSString *seperator = @"--------------------------------";
		
		NSString *message = [NSString stringWithFormat:
							 @"\n\n%@\nApp: %@\nVersion: %@ (Build: %@)\nDevice Model: %@\niOS: %@\nSelected URL: %@\n%@\n",
							 seperator, appName, appVersion, appBuildVersion, deviceModel, [[UIDevice currentDevice] systemVersion], selectedURL, seperator];
		
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
