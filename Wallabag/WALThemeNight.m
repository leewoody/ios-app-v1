//
//  WALThemeNight.m
//  Wallabag
//
//  Created by Kevin Meyer on 03.06.14.
//  Copyright (c) 2014 Wallabag. All rights reserved.
//

#import "WALThemeNight.h"

@implementation WALThemeNight

- (UIColor*) getBarColor
{
	return [UIColor darkGrayColor];
}

- (UIColor*) getBackgroundColor
{
	return [UIColor colorWithRed:136.0/255.0 green:136.0/255.0 blue:136.0/255.0 alpha:1.0f];
}

- (UIColor*) getTextColor
{
	return [UIColor whiteColor];
}

- (UIColor*) getTintColor
{
	return [UIColor whiteColor];
}

- (NSURL*) getPathToMainCSSFile
{
	return [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"main-night" ofType:@"css"]];
}

- (NSURL*) getPathtoExtraCSSFile
{
	return [super getPathtoExtraCSSFile];
}

- (UIStatusBarStyle) getPreferredStatusBarStyle
{
	return UIStatusBarStyleBlackOpaque;
}

@end
