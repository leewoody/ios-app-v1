//
//  WALNavigationController.h
//  Wallabag
//
//  Created by Kevin Meyer on 01.06.14.
//  Copyright (c) 2014 Wallabag. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WALTheme;

@interface WALNavigationController : UINavigationController

- (WALTheme*) getCurrentTheme;
- (void) changeTheme;

@end
