//
//  WALSupportHelper.m
//  Wallabag
//
//  Created by Kevin Meyer on 04/10/14.
//  Copyright (c) 2014 Wallabag. All rights reserved.
//

#import "WALSupportHelper.h"
#import <sys/utsname.h>

@implementation WALSupportHelper

+(NSString*)getBodyForSupportMail {
	struct utsname systemInfo;
	uname(&systemInfo);
	
	NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
	NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
	NSString *appBuildVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
	NSString *deviceModel = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
	NSString *locale = [[NSBundle mainBundle] preferredLocalizations][0];
	NSString *seperator = @"--------------------------------";
	
	NSString *message = [NSString stringWithFormat:
						 @"\n\n%@\nApp: %@\nVersion: %@ (build: %@)\nDevice Model: %@\niOS: %@\nLocale: %@\n%@\n",
						 seperator, appName, appVersion, appBuildVersion, deviceModel, [[UIDevice currentDevice] systemVersion], locale, seperator];
	
	return message;
}

@end
