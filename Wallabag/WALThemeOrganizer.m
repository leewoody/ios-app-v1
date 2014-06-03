//
//  WALThemeOrganizer.m
//  Wallabag
//
//  Created by Kevin Meyer on 03.06.14.
//  Copyright (c) 2014 Wallabag. All rights reserved.
//

#import "WALThemeOrganizer.h"
#import "WALTheme.h"
#import "WALThemeNight.h"

@interface WALThemeOrganizer ()
@property (strong)  WALTheme *currentTheme;
@end

@implementation WALThemeOrganizer

- (id)init
{
	if (self = [super init])
	{
		self.currentTheme = [[WALTheme alloc] init];
	}
	return self;
}

+ (WALThemeOrganizer*) sharedThemeOrganizer
{
	static WALThemeOrganizer *sharedInstance;
	if (!sharedInstance)
	{
		sharedInstance = [[[self class] alloc] init];
	}
	
	return sharedInstance;
}

- (WALTheme*) getCurrentTheme
{
	return self.currentTheme;
}

- (void) changeTheme
{
	if ([self.currentTheme isMemberOfClass:[WALTheme class]])
		self.currentTheme = [[WALThemeNight alloc] init];
	else
		self.currentTheme = [[WALTheme alloc] init];
}

@end
