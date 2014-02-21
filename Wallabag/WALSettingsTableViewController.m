//
//  WALSettingsTableViewController.m
//  Wallabag
//
//  Created by Kevin Meyer on 19.02.14.
//  Copyright (c) 2014 Wallabag. All rights reserved.
//

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
	
	if ([identifier isEqualToString:@"Framabag"])
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
		//! @todo 
	}
	else if ([identifier isEqualToString:@"WallabagTwitter"])
	{
		NSURL *twitterIRL = [NSURL URLWithString:@"twitter://user?screen_name=wallabagapp"];
		NSURL *tweetbotIRL = [NSURL URLWithString:@"tweetbot:///user_profile/wallabagapp"];
		
		if ([[UIApplication sharedApplication] canOpenURL:tweetbotIRL])
			[[UIApplication sharedApplication] openURL:tweetbotIRL];
		
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

@end
