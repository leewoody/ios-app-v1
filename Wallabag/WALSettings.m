//
//  WALSettings.m
//  Wallabag
//
//  Created by Kevin Meyer on 20.02.14.
//  Copyright (c) 2014 Wallabag. All rights reserved.
//

#import "WALSettings.h"

@implementation WALSettings

+ (WALSettings*) settingsFromSavedSettings
{
	WALSettings* settings = [[WALSettings alloc] init];

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	settings.wallabagURL = [defaults URLForKey:@"wallabagURL"];
	settings.userID = [defaults integerForKey:@"userID"];
	settings.apiToken = [defaults stringForKey:@"apiToken"];

	if (settings.wallabagURL == nil || settings.apiToken == nil)
		return nil;
	
	return settings;
}

- (void) saveSettings
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	[defaults setURL:self.wallabagURL forKey:@"wallabagURL"];
	[defaults setInteger:self.userID forKey:@"userID"];
	[defaults setObject:self.apiToken forKey:@"apiToken"];
	[defaults synchronize];
}

@end
