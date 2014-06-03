//
//  WALNavigationController.m
//  Wallabag
//
//  Created by Kevin Meyer on 01.06.14.
//  Copyright (c) 2014 Wallabag. All rights reserved.
//

#import "WALNavigationController.h"

@interface WALNavigationController ()
@property WALTheme theme;
@end

@implementation WALNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.theme = WALThemeNight;
	[self updateWithTheme];
}

- (WALTheme)getCurrentTheme
{
	return self.theme;
}

- (void)changeTheme
{
	self.theme = self.theme == WALThemeDay ? WALThemeNight : WALThemeDay;
	[self updateWithTheme];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
	if (self.theme == WALThemeNight)
		return UIStatusBarStyleBlackOpaque;
	
	else if (self.theme == WALThemeDay)
		return UIStatusBarStyleDefault;
	
	return UIStatusBarStyleDefault;
}

- (void) updateWithTheme
{
	if (self.theme == WALThemeNight)
	{
		[self.navigationBar setBarTintColor:[UIColor darkGrayColor]];
		[self.navigationBar setTintColor:[UIColor whiteColor]];
		[self.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
		
		[self.toolbar setBarTintColor:[UIColor darkGrayColor]];
		[self.toolbar setTintColor:[UIColor whiteColor]];
	}
	else if (self.theme == WALThemeDay)
	{
		[self.navigationBar setBarTintColor:[UIColor whiteColor]];
		[self.navigationBar setTintColor:[UIColor blueColor]];
		[self.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}];
		
		[self.toolbar setBarTintColor:[UIColor whiteColor]];
		[self.toolbar setTintColor:[UIColor blackColor]];
	}
	[self setNeedsStatusBarAppearanceUpdate];
}

@end
