//
//  WALSettings.m
//  Wallabag
//
//  Created by Kevin Meyer on 20.02.14.
//  Copyright (c) 2014 Wallabag. All rights reserved.
//

#import "WALSettings.h"
#define kWallabagAppGroupId @"group.de.Kevin-Meyer.Wallabag"

@interface WALSettings ()
@property (nonatomic, strong) NSURL *baseURL;
@end

@implementation WALSettings

+ (WALSettings*) settingsFromSavedSettings {
	return [self settingsFromSavedSettingsOnFallback:NO];
}

+ (WALSettings*) settingsFromSavedSettingsOnFallback:(BOOL) fallback {
	
	WALSettings* settings = [[WALSettings alloc] init];
	
	NSUserDefaults *defaults;
	if (!fallback) {
		defaults = [[NSUserDefaults alloc] initWithSuiteName:kWallabagAppGroupId];
	} else {
		defaults = [NSUserDefaults standardUserDefaults];
	}
	
	settings.wallabagURL = [defaults URLForKey:@"wallabagURL"];
	
	if ((settings.baseURL == nil) && fallback)
		return nil;
	else if (settings.baseURL == nil) {
		settings = [self settingsFromSavedSettingsOnFallback:YES];
		if (settings) {
			[settings saveSettings];
		}
	}
	
	return settings;
}

- (void) saveSettings
{
	NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:kWallabagAppGroupId];
	
	[defaults setURL:self.baseURL forKey:@"wallabagURL"];
	[defaults synchronize];
}

#pragma mark - URL Handling

- (void)setWallabagURL:(NSURL *)url {
	if (!url)
		return;
	
	if (![url.absoluteString hasSuffix:@"/"])
		url = [NSURL URLWithString:[url.absoluteString stringByAppendingString:@"/"]];
	
	self.baseURL = url;
}

- (NSURL *)getWallabagURL {
	if (!self.baseURL) {
		return nil;
	}
	return self.baseURL.absoluteURL;
}

@end
