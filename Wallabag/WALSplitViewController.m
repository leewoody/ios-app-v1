//
//  WALSplitViewController.m
//  Wallabag
//
//  Created by Kevin Meyer on 26.07.14.
//  Copyright (c) 2014 Wallabag. All rights reserved.
//

#import "WALSplitViewController.h"
#import "WALTheme.h"
#import "WALThemeNight.h"
#import "WALThemeOrganizer.h"

@interface WALSplitViewController ()

@end

@implementation WALSplitViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	WALThemeOrganizer *organizer = [WALThemeOrganizer sharedThemeOrganizer];
	[organizer subscribeToThemeChanges:self];
	[self setNeedsStatusBarAppearanceUpdate];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
	WALTheme *currentTheme = [[WALThemeOrganizer sharedThemeOrganizer] getCurrentTheme];
	return [currentTheme getPreferredStatusBarStyle];
}

- (void)themeOrganizer:(WALThemeOrganizer *)organizer setNewTheme:(WALTheme *)theme
{
	[self setNeedsStatusBarAppearanceUpdate];
}

@end
