//
//  WALSettings.m
//  Wallabag
//
//  Created by Kevin Meyer on 20.02.14.
//  Copyright (c) 2014 Wallabag. All rights reserved.
//

#import "WALSettings.h"

@interface WALSettings ()
@property (nonatomic, strong) NSURL *baseURL;
@end

@implementation WALSettings

+ (WALSettings*) settingsFromSavedSettings
{
	WALSettings* settings = [[WALSettings alloc] init];

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	settings.wallabagURL = [defaults URLForKey:@"wallabagURL"];
	settings.userID = [defaults integerForKey:@"userID"];
	settings.apiToken = [defaults stringForKey:@"apiToken"];

	if (settings.baseURL == nil || settings.apiToken == nil)
		return nil;
	
	return settings;
}

- (void) saveSettings
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	[defaults setURL:self.baseURL forKey:@"wallabagURL"];
	[defaults setInteger:self.userID forKey:@"userID"];
	[defaults setObject:self.apiToken forKey:@"apiToken"];
	[defaults synchronize];
}

#pragma mark - URL Handling

- (void)setWallabagURL:(NSURL *)url
{
	if (!url)
		return;
	
	if (![url.absoluteString hasSuffix:@"/"])
		url = [NSURL URLWithString:[url.absoluteString stringByAppendingString:@"/"]];
	
	self.baseURL = url;
}

- (NSURL *)getWallabagURL
{
	if (!self.baseURL) {
		return nil;
	}
	return [NSURL URLWithString:self.baseURL.absoluteString];
}

- (NSURL *)getHomeFeedURL
{
	if (!self.baseURL) {
		return nil;
	}
	
	NSURL *resultURL = [NSURL URLWithString:[NSString stringWithFormat:@"index.php?feed&type=home&user_id=%ld&token=%@", (long) self.userID, self.apiToken] relativeToURL:self.baseURL];
	
	return resultURL;
}

@end
