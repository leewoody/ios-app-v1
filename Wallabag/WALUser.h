//
//  WALUser.h
//  Wallabag
//
//  Created by Kevin Meyer on 10/02/15.
//  Copyright (c) 2015 Wallabag. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WALUser : NSObject

@property (strong) NSString *username;
@property (readonly, strong) NSString *passwordHashed;

- (instancetype)initWithUsername:(NSString *)username andHashedPassword:(NSString *)passwordHashed;

- (NSString *)wsseHeaderKey;
- (NSString *)wsseHeaderValue;

@end
