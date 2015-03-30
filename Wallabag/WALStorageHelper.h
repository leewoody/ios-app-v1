//
//  WALStorageHelper.h
//  Wallabag
//
//  Created by Kevin Meyer on 05/02/15.
//  Copyright (c) 2015 Wallabag. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>

@interface WALStorageHelper : NSObject

+ (void)initializeCoreDataAndRestKit;
+ (void)updateRestKitWithNewSettings;

+ (RKObjectManager *)loginObjectManagerWithBaseURL:(NSURL *) baseURL;

@end
