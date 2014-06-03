//
//  WALNavigationController.m
//  Wallabag
//
//  Created by Kevin Meyer on 01.06.14.
//  Copyright (c) 2014 Wallabag. All rights reserved.
//

#import "WALNavigationController.h"
#import "WALTheme.h"
#import "WALThemeNight.h"

@interface WALNavigationController ()
@property WALTheme *currentTheme;
@end

@implementation WALNavigationController

- (void)awakeFromNib
{
	[super awakeFromNib];
	self.currentTheme = [[WALTheme alloc] init];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self updateWithTheme];
}

- (WALTheme*)getCurrentTheme
{
	return self.currentTheme;
}

- (void)changeTheme
{
	if ([self.currentTheme isMemberOfClass:[WALTheme class]])
		self.currentTheme = [[WALThemeNight alloc] init];
	else
		self.currentTheme = [[WALTheme alloc] init];
	
	[self updateWithTheme];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
	return [self.currentTheme getPreferredStatusBarStyle];
}

- (void) updateWithTheme
{
	[self.navigationBar setBarTintColor:[self.currentTheme getBarColor]];
	[self.navigationBar setTintColor:[self.currentTheme getTintColor]];
	[self.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [self.currentTheme getTextColor]}];
	
	[self.toolbar setBarTintColor:[self.currentTheme getBarColor]];
	[self.toolbar setTintColor:[self.currentTheme getTintColor]];
	[self setNeedsStatusBarAppearanceUpdate];
}

@end
