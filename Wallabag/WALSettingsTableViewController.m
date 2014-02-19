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
@end

@implementation WALSettingsTableViewController


- (IBAction)cancelButtonPushed:(id)sender
{
	[self.delegate callbackFromSettingsController:self withSettings:nil];
}
@end
