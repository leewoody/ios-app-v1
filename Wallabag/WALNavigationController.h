//
//  WALNavigationController.h
//  Wallabag
//
//  Created by Kevin Meyer on 01.06.14.
//  Copyright (c) 2014 Wallabag. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    WALThemeDay,
	WALThemeNight
} WALTheme;

@interface WALNavigationController : UINavigationController

- (void) changeTheme;

@end
