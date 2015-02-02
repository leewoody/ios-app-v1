//
//  NSString+HTML.h
//  Wallabag
//
//  Created by Kevin Meyer on 02/02/15.
//  Copyright (c) 2015 Wallabag. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (HTML)

- (NSString*) stringByHtmlUnescapingString;

@end
