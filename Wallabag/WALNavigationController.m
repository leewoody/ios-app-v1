//
//  WALNavigationController.m
//  Wallabag
//
//  Created by Kevin Meyer on 01.06.14.
//  Copyright (c) 2014 Wallabag. All rights reserved.
//

#import "WALNavigationController.h"
#import "WALTheme.h"
#import "WALThemeNight.h"
#import "WALThemeOrganizer.h"
#import "WALSupportHelper.h"

@interface WALNavigationController ()
@property (strong) NSData *crashData;
@end

@implementation WALNavigationController

- (void)awakeFromNib
{
	[super awakeFromNib];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	if (self.crashData) {
		[self askUserToSendCrashMail];
	}
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	WALThemeOrganizer *organizer = [WALThemeOrganizer sharedThemeOrganizer];
	[organizer subscribeToThemeChanges:self];
	[self updateWithTheme:[organizer getCurrentTheme]];

}

- (UIStatusBarStyle)preferredStatusBarStyle
{
	WALTheme *currentTheme = [[WALThemeOrganizer sharedThemeOrganizer] getCurrentTheme];
	return [currentTheme getPreferredStatusBarStyle];
}

- (void) updateWithTheme:(WALTheme*) theme
{
	if (SYSTEM_VERSION_LESS_THAN(@"7.0"))
		return;

	[self.navigationBar setBarTintColor:[theme getBarColor]];
	[self.navigationBar setTintColor:[theme getTintColor]];
	[self.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [theme getTextColor]}];
	
	[self.toolbar setBarTintColor:[theme getBarColor]];
	[self.toolbar setTintColor:[theme getTintColor]];
	[self setNeedsStatusBarAppearanceUpdate];
}

- (void)themeOrganizer:(WALThemeOrganizer *)organizer setNewTheme:(WALTheme *)theme
{
	[self updateWithTheme:theme];
}

#pragma mark - CrashHandling

- (void)setCrashDataToBeSent:(NSData *)attachment {
	self.crashData = attachment;
}

- (void)askUserToSendCrashMail {
	if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Oops", nil)
															message:NSLocalizedString(@"Sorry, but it seems like we crashed. Please support to fix this bug by sending a crash report.", nil)
														   delegate:self
												  cancelButtonTitle:NSLocalizedString(@"Don't send", nil)
												  otherButtonTitles:NSLocalizedString(@"Send report", nil), nil];
		
		[alertView show];
		
	} else {
		UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Oops", nil)
																				 message:NSLocalizedString(@"Sorry, but it seems like we crashed. Please support to fix this bug by sending a crash report.", nil)
																		  preferredStyle:UIAlertControllerStyleAlert];
		
		[alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Send report", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
			[self presentEmailSheetWithCrashData:self.crashData];
			self.crashData = nil;
		}]];
		[alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Don't send", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
			self.crashData = nil;
		}]];
		
		[self presentViewController:alertController animated:YES completion:nil];
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		// Canceling Report sending
		self.crashData = nil;
	} else if (buttonIndex == 1) {
		// Send Crash Report
		[self presentEmailSheetWithCrashData:self.crashData];
		self.crashData = nil;
	}
}

- (void)presentEmailSheetWithCrashData:(NSData*) crashData {
	MFMailComposeViewController *mailVC = [WALSupportHelper getPreparedMailComposeVCForCrashReportingWithCrashData:crashData];
	
	if (mailVC) {
		mailVC.mailComposeDelegate = self;
		[self presentViewController:mailVC animated:YES completion:nil];
	}
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
