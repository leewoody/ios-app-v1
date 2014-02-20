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
	if (self.currentSettings.wallabagURL && self.currentSettings.apiToken)
	{
		self.urlTextField.text = [self.currentSettings.wallabagURL absoluteString];
		self.userIDTextField.text = [NSString stringWithFormat:@"%ld", (long)self.currentSettings.userID];
		self.apiTokenTextField.text = self.currentSettings.apiToken;
	}
	[self updateDoneButton];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[self.urlTextField becomeFirstResponder];
}

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
