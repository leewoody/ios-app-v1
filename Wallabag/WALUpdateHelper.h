//
//  WALUpdateHelper.h
//  Wallabag
//
//  Created by Kevin Meyer on 05/02/15.
//  Copyright (c) 2015 Wallabag. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WALSettings.h"

@interface WALUpdateHelper : NSObject

+ (NSDictionary *) parametersForGetArticlesWithSettings:(WALSettings *) settings;

@end
