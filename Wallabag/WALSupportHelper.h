//
//  WALSupportHelper.h
//  Wallabag
//
//  Created by Kevin Meyer on 04/10/14.
//  Copyright (c) 2014 Wallabag. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface WALSupportHelper : NSObject

+ (NSString*)getBodyForSupportMail;
+ (MFMailComposeViewController *)getPreparedMailComposeVCForCrashReportingWithCrashData:(NSData*) crashData;

@end
