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
		[self presentEmailSheetWithCrashData:self.crashData];
		self.crashData = nil;
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



- (void)presentEmailSheetWithCrashData:(NSData*) crashData {
	if ([MFMailComposeViewController canSendMail]) {
		MFMailComposeViewController *mailVC = [[MFMailComposeViewController alloc] init];
		[mailVC setToRecipients:[NSArray arrayWithObject:@"wallabag@kevin-meyer.de"]];
		[mailVC setSubject:@"Crash Report wallabag iOS-App"];
		[mailVC setMessageBody:[WALSupportHelper getBodyForSupportMail] isHTML:NO];
		[mailVC addAttachmentData:crashData mimeType:@"application/crash" fileName:@"wallabag.crash"];
		mailVC.mailComposeDelegate = self;
		
		[self presentViewController:mailVC animated:YES completion:nil];
	}
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
