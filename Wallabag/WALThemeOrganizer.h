//
//  WALThemeOrganizer.h
//  Wallabag
//
//  Created by Kevin Meyer on 03.06.14.
//  Copyright (c) 2014 Wallabag. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WALTheme;

@interface WALThemeOrganizer : NSObject

+ (WALThemeOrganizer*) sharedThemeOrganizer;

- (WALTheme*) getCurrentTheme;
- (void) changeTheme;

@end
