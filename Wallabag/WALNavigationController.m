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
#import "WALThemeOrganizer.h"

@interface WALNavigationController ()
@end

@implementation WALNavigationController

- (void)awakeFromNib
{
	[super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	WALThemeOrganizer *organizer = [WALThemeOrganizer sharedThemeOrganizer];
	[organizer subscribeToThemeChanges:self];
	[self updateWithTheme:[organizer getCurrentTheme]];

}

- (UIStatusBarStyle)preferredStatusBarStyle
{
	WALTheme *currentTheme = [[WALThemeOrganizer sharedThemeOrganizer] getCurrentTheme];
	return [currentTheme getPreferredStatusBarStyle];
}

- (void) updateWithTheme:(WALTheme*) theme
{		
	[self.navigationBar setBarTintColor:[theme getBarColor]];
	[self.navigationBar setTintColor:[theme getTintColor]];
	[self.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [theme getTextColor]}];
	
	[self.toolbar setBarTintColor:[theme getBarColor]];
	[self.toolbar setTintColor:[theme getTintColor]];
	[self setNeedsStatusBarAppearanceUpdate];
}

- (void)themeOrganizer:(WALThemeOrganizer *)organizer setNewTheme:(WALTheme *)theme
{
	[self updateWithTheme:theme];
}

@end
