//
//  WALAppDelegate.m
//  Wallabag
//
//  Created by Kevin Meyer on 19.02.14.
//  Copyright (c) 2014 Wallabag. All rights reserved.
//

#import "WALAppDelegate.h"
#import "WALArticle.h"
#import "WALIcons.h"
#import "WALSettings.h"
#import "WALSupportHelper.h"
#import "WALCrashDataProtocol.h"
#import <PLCrashReporter/PLCrashReporter.h>
#import <PLCrashReporter/PLCrashReport.h>
#import <PLCrashReporter/PLCrashReportTextFormatter.h>

@interface WALAppDelegate ()
@property (weak, nonatomic) UIBarButtonItem *lastBarButtonItem;
@end

@implementation WALAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	PLCrashReporter *reporter = [PLCrashReporter sharedReporter];
	
	if ([reporter hasPendingCrashReport]) {
		NSLog(@"Has Crash!");
		NSData *crashData = [self handleCrashReport];
		if (crashData) {
			id <WALCrashDataProtocol> crashDataHandler = ((id <WALCrashDataProtocol>)self.window.rootViewController);
			[crashDataHandler setCrashDataToBeSent:crashData];
		}
	}
	
	NSError *error = nil;
	if (![reporter enableCrashReporterAndReturnError:&error]) {
		NSLog(@"Error: %@", error);
	}
	
    // Override point for customization after application launch.
	
	UIViewController *rootViewController = self.window.rootViewController;
	
	if ([rootViewController isKindOfClass:[UISplitViewController class]])
	{
		((UISplitViewController*)rootViewController).delegate = self;
	}
	
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Crash Reporting

- (NSData*)handleCrashReport {
	PLCrashReporter *crashReporter = [PLCrashReporter sharedReporter];
	NSData *crashData;
	NSError *error;
	
	crashData = [crashReporter loadPendingCrashReportDataAndReturnError:&error];
	if (crashData == nil) {
		NSLog(@"Couldn't load crash data: %@", error);
		[crashReporter purgePendingCrashReport];
		return nil;
	}
	
	PLCrashReport *crashReport = [[PLCrashReport alloc] initWithData:crashData error:nil];
	NSString *crashLog = [PLCrashReportTextFormatter stringValueForCrashReport:crashReport withTextFormat:PLCrashReportTextFormatiOS];
	
	return [crashLog dataUsingEncoding:NSUTF8StringEncoding];
}

#pragma mark - UISplitView Delegate

- (void)splitViewController:(UISplitViewController *)svc
	 willHideViewController:(UIViewController *)aViewController
		  withBarButtonItem:(UIBarButtonItem *)barButtonItem
	   forPopoverController:(UIPopoverController *)pc
{
	UINavigationController *navigationVC = svc.viewControllers.lastObject;
	if (YES)
	{
		barButtonItem.image = [WALIcons imageOfNavbarList];
		((UIViewController*)navigationVC.viewControllers[0]).navigationItem.leftBarButtonItem = barButtonItem;
	}
	self.lastBarButtonItem = barButtonItem;
	pc.delegate = self;
}

- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
	UINavigationController *navigationVC = svc.viewControllers.lastObject;
	if (YES)
	{
		((UIViewController*)navigationVC.viewControllers[0]).navigationItem.leftBarButtonItem = nil;
		self.lastBarButtonItem = nil;
	}
}

- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation
{
	if (UIInterfaceOrientationIsLandscape(orientation))
		return NO;
	
	if (![WALSettings settingsFromSavedSettings])
		return NO;
	
	return YES;
}

#pragma mark - UIPopoverController

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
{
	if (![WALSettings settingsFromSavedSettings])
		return NO;
	
	return YES;
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
	UINavigationController *navigationVC = ((UISplitViewController*)self.window.rootViewController).viewControllers.lastObject;
	if (YES)
	{
		[((UIViewController*)navigationVC.viewControllers[0]).navigationItem setLeftBarButtonItem:self.lastBarButtonItem animated:true];
	}

}

@end
