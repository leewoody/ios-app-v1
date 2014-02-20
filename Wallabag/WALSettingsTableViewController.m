//
//  WALSettingsTableViewController.m
//  Wallabag
//
//  Created by Kevin Meyer on 19.02.14.
//  Copyright (c) 2014 Wallabag. All rights reserved.
//

#import "WALSettingsTableViewController.h"

@interface WALSettingsTableViewController ()
- (IBAction)cancelButtonPushed:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *urlTextField;
@property (weak, nonatomic) IBOutlet UITextField *userIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *apiTokenTextFIeld;
@end

@implementation WALSettingsTableViewController

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[self.urlTextField becomeFirstResponder];
}

- (IBAction)cancelButtonPushed:(id)sender
{
	[self.delegate callbackFromSettingsController:self withSettings:nil];
}
@end
