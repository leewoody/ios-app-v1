//
//  WALSplitViewController.h
//  Wallabag
//
//  Created by Kevin Meyer on 26.07.14.
//  Copyright (c) 2014 Wallabag. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "WALThemeOrganizerDelegate.h"
#import "WALCrashDataProtocol.h"

@interface WALSplitViewController : UISplitViewController <WALThemeOrganizerDelegate, WALCrashDataProtocol, MFMailComposeViewControllerDelegate>

@end
