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
	return [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0f];
}

- (UIColor*) getTextColor
{
	return [UIColor blackColor];
}

- (UIColor*) getTintColor
{
	return [UIColor colorWithRed:0 green:122.0/255.0 blue:1.0 alpha:1.0];
//	return [[[UIApplication sharedApplication] keyWindow] tintColor];
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
