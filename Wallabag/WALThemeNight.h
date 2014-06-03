//
//  WALThemeNight.h
//  Wallabag
//
//  Created by Kevin Meyer on 03.06.14.
//  Copyright (c) 2014 Wallabag. All rights reserved.
//

#import "WALTheme.h"

//! Night Theme
@interface WALThemeNight : WALTheme

- (UIColor*) getBarColor;
- (UIColor*) getBackgroundColor;
- (UIColor*) getTextColor;
- (UIColor*) getTintColor;

- (NSURL*) getPathToMainCSSFile;
- (NSURL*) getPathtoExtraCSSFile;

- (UIStatusBarStyle) getPreferredStatusBarStyle;

@end
