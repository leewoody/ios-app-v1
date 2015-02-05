//
//  WALUpdateHelper.m
//  Wallabag
//
//  Created by Kevin Meyer on 05/02/15.
//  Copyright (c) 2015 Wallabag. All rights reserved.
//

#import "WALUpdateHelper.h"

@implementation WALUpdateHelper

+ (NSDictionary *)parametersForGetArticlesWithSettings:(WALSettings *)settings {
	if (settings.isVersionV2) {
		return nil;
	}
	
	return @{@"feed"	: [NSNull null],
			 @"type"	: @"home",
			 @"user_id"	: [NSNumber numberWithInteger:settings.userID],
			 @"token"	: settings.apiToken};
}

@end
