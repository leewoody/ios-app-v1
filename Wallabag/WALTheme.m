//
//  WALTheme.m
//  Wallabag
//
//  Created by Kevin Meyer on 03.06.14.
//  Copyright (c) 2014 Wallabag. All rights reserved.
//

#import "WALTheme.h"

@implementation WALTheme

- (UIColor*) getBarColor
{
	return [UIColor whiteColor];
}

- (UIColor*) getBackgroundColor
{
	return [UIColor whiteColor];
}

- (UIColor*) getTextColor
{
	return [UIColor blackColor];
}

- (UIColor*) getTintColor
{
	return [[[[UIApplication sharedApplication] delegate] window] tintColor];
}

- (NSURL*) getPathToMainCSSFile
{
	return [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"main" ofType:@"css"]];
}

- (NSURL*) getPathtoExtraCSSFile
{
	return [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"ratatouille" ofType:@"css"]];
}

- (UIStatusBarStyle) getPreferredStatusBarStyle
{
	return UIStatusBarStyleDefault;
}

@end
