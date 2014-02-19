//
//  WALArticle.m
//  Wallabag
//
//  Created by Kevin Meyer on 19.02.14.
//  Copyright (c) 2014 Wallabag. All rights reserved.
//

#import "WALArticle.h"

@implementation WALArticle

- (id) init
{
	self = [super init];
	
	return self;
}

- (void) setDateWithString:(NSString*) string
{
	NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
	NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
	
	[dateformatter setLocale:usLocale];
	[dateformatter setDateFormat:@"EEE, dd LLL yyyy HH:mm:ss Z"];

	self.date = [dateformatter dateFromString: string];
}

- (NSString*) getDateString
{
	return [NSDateFormatter localizedStringFromDate:self.date
										  dateStyle:NSDateFormatterShortStyle
										  timeStyle:NSDateFormatterShortStyle];
}

@end
