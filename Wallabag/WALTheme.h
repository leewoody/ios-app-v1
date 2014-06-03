//
//  WALTheme.h
//  Wallabag
//
//  Created by Kevin Meyer on 03.06.14.
//  Copyright (c) 2014 Wallabag. All rights reserved.
//

#import <Foundation/Foundation.h>

//! Provides the default (Day) Theme and Parent Class for all other Themes
@interface WALTheme : NSObject

- (UIColor*) getBarColor;
- (UIColor*) getBackgroundColor;
- (UIColor*) getTextColor;
- (UIColor*) getTintColor;

- (NSURL*) getPathToMainCSSFile;
- (NSURL*) getPathtoExtraCSSFile;

@end
