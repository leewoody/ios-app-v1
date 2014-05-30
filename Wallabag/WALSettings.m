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

#pragma mark - Generate URLs

- (NSURL*) getFeedURLWithFeedName:(NSString*) feedName
{
	if (!self.baseURL)
		return nil;
	
	NSURL *resultURL = [NSURL URLWithString:[NSString stringWithFormat:@"index.php?feed&type=%@&user_id=%ld&token=%@", feedName, (long) self.userID, self.apiToken]
							  relativeToURL:self.baseURL];
	
	return resultURL;
}

- (NSURL *)getHomeFeedURL
{
	return [self getFeedURLWithFeedName:@"home"];
}

- (NSURL*) getFavoriteFeedURL
{
	return [self getFeedURLWithFeedName:@"fav"];
}

- (NSURL *)getArchiveFeedURL
{
	return [self getFeedURLWithFeedName:@"archive"];
}

- (NSURL *)getURLToAddArticle:(NSURL *)articleURL
{
	if (!self.baseURL)
		return nil;
	
	NSString *base64String = [self base64String:[articleURL absoluteString]];
	NSURL *resultURL = [NSURL URLWithString:[NSString stringWithFormat:@"index.php?action=add&url=%@", base64String]
							  relativeToURL:self.baseURL];
	
	return resultURL;
}

#pragma mark -

- (NSString *)base64String:(NSString *)str
{
    NSData *theData = [str dataUsingEncoding: NSASCIIStringEncoding];
    const uint8_t* input = (const uint8_t*)[theData bytes];
    NSInteger length = [theData length];
	
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
	
    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;
	
    NSInteger i;
    for (i=0; i < length; i += 3) {
        NSInteger value = 0;
        NSInteger j;
        for (j = i; j < (i + 3); j++) {
            value <<= 8;
			
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
		
        NSInteger theIndex = (i / 3) * 4;
        output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
        output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
	
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}

@end
