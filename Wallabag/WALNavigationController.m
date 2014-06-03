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
	[self updateWithTheme];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
	WALTheme *currentTheme = [[WALThemeOrganizer sharedThemeOrganizer] getCurrentTheme];
	return [currentTheme getPreferredStatusBarStyle];
}

- (void) updateWithTheme
{
	WALTheme *currentTheme = [[WALThemeOrganizer sharedThemeOrganizer] getCurrentTheme];
	
	[self.navigationBar setBarTintColor:[currentTheme getBarColor]];
	[self.navigationBar setTintColor:[currentTheme getTintColor]];
	[self.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [currentTheme getTextColor]}];
	
	[self.toolbar setBarTintColor:[currentTheme getBarColor]];
	[self.toolbar setTintColor:[currentTheme getTintColor]];
	[self setNeedsStatusBarAppearanceUpdate];
}

@end
