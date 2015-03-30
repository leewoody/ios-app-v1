//
//  WALLoginSalt.h
//  Wallabag
//
//  Created by Kevin Meyer on 11/02/15.
//  Copyright (c) 2015 Wallabag. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WALLoginSalt : NSObject

@property (strong) NSString *username;
@property (strong) NSString *salt;

@end
