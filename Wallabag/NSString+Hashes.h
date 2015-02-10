//
//  NSString+Hashes.h
//  Wallabag
//
//  Created by Kevin Meyer on 10/02/15.
//  Copyright (c) 2015 Wallabag. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Hashes)

- (NSString *)stringByHashingWithSHA1;
- (NSData *)dataByHashingWithSHA1;

- (NSString *)stringByEncodingBase64;
- (NSString *)stringByDecodingBase64;

@end
