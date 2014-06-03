//
//  WALThemeOrganizerDelegate.h
//  Wallabag
//
//  Created by Kevin Meyer on 03.06.14.
//  Copyright (c) 2014 Wallabag. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WALThemeOrganizer;
@class WALTheme;

@protocol WALThemeOrganizerDelegate <NSObject>

- (void) themeOrganizer:(WALThemeOrganizer*) organizer setNewTheme:(WALTheme*) theme;

@end
