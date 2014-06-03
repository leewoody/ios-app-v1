//
//  WALThemeOrganizer.h
//  Wallabag
//
//  Created by Kevin Meyer on 03.06.14.
//  Copyright (c) 2014 Wallabag. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WALThemeOrganizerDelegate.h"

@class WALTheme;

@interface WALThemeOrganizer : NSObject

+ (WALThemeOrganizer*) sharedThemeOrganizer;

- (WALTheme*) getCurrentTheme;
- (void) changeTheme;

- (void) subscribeToThemeChanges:(id<WALThemeOrganizerDelegate>) subscriber;
- (void) unsubscribeToThemeChanges:(id<WALThemeOrganizerDelegate>) subscriber;

@end
