//
//  WALCrashDataProtocol.h
//  Wallabag
//
//  Created by Kevin Meyer on 12/10/14.
//  Copyright (c) 2014 Wallabag. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSData;

@protocol WALCrashDataProtocol <NSObject>

- (void)setCrashDataToBeSent:(NSData*) attachment;

@end