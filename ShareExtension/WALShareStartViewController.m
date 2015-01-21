//
//  WALShareStartViewController.m
//  Wallabag
//
//  Created by Kevin Meyer on 17/01/15.
//  Copyright (c) 2015 Wallabag. All rights reserved.
//

#import "WALShareStartViewController.h"
#import "WALShareBrowserViewController.h"
#import "WALWebViewHelper.h"

#import <MobileCoreServices/MobileCoreServices.h>

#import "WALSettings.h"

@interface WALShareStartViewController ()<WALShareBrowserDelegate>

@property (strong) UIWebView *webView;
@property (strong) WALWebViewHelper *helper;

@property (weak) IBOutlet UIView *statusView;
@property (weak) IBOutlet UILabel *statusLabel;
@property (weak) IBOutlet UILabel *statusDone;
@property (weak) IBOutlet UILabel *statusError;
@property (weak) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (strong) WALShareBrowserViewController *browserVC;
@property (strong) NSURL *addUrl;
@property (strong) WALSettings *settings;

@end

@implementation WALShareStartViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.statusLabel.text = NSLocalizedString(@"Adding Link", nil);

	self.statusView.layer.cornerRadius = 8;
	self.statusView.alpha = 0;
	self.statusView.layer.shadowOpacity = 0.3;
	self.statusView.layer.shadowOffset = CGSizeMake(3.0, 3.0);
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	self.settings = [WALSettings settingsFromSavedSettings];
	if (!self.settings) {
		[self showErrorAndCancelExtension:NSLocalizedString(@"In order to use the wallabag extension, you have to configure your account inside the wallabag app first.", nil)];
		return;
	}
	
	NSExtensionItem *item = self.extensionContext.inputItems[0];
	
	for (NSItemProvider *provider in item.attachments) {
		if ([provider hasItemConformingToTypeIdentifier:(NSString*)kUTTypeURL]) {
			[provider loadItemForTypeIdentifier:(NSString*)kUTTypeURL options:nil completionHandler:^(id<NSSecureCoding> item, NSError *error) {
				self.addUrl = (NSURL*)item;
				dispatch_async(dispatch_get_main_queue(), ^{
					[UIView animateWithDuration:0.25 animations:^{
						self.statusView.alpha = 1.0;
					} completion:^(BOOL finished) {
						[self startBrowserViewController];
					}];
				});
			}];
			return;
		}
	}

	NSLog(@"Didn't find URL!");
	[self showErrorAndCancelExtension:NSLocalizedString(@"Couldn't find a valid link to add.", nil)];
}

- (void)startBrowserViewController {
	self.webView = [[UIWebView alloc] initWithFrame:self.view.frame];
	self.webView.hidden = YES;

	WALWebViewHelper *helper = [[WALWebViewHelper alloc] init];
	helper.delegate = self;
	helper.addUrl = self.addUrl;
	helper.settings = self.settings;
	self.helper = helper;
	
	[self.helper startWithWebView:self.webView];
}

#pragma mark - Extension Exit

- (void)cancelExtension {
	[UIView animateWithDuration:0.25 animations:^{
		self.statusView.alpha = 0;
	} completion:^(BOOL finished) {
		[self.extensionContext cancelRequestWithError:nil];
	}];
}

- (void)closeExtension {
	[UIView animateWithDuration:0.25 animations:^{
		self.statusView.alpha = 0;
	} completion:^(BOOL finished) {
		[self.extensionContext completeRequestReturningItems:nil completionHandler:nil];
	}];
}

- (void)showErrorAndCancelExtension:(NSString*) errorMessage {
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Couldn't add link", nil)
																   message:errorMessage
															preferredStyle:UIAlertControllerStyleAlert];
	[alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
		[self cancelExtension];
	}]];
	[self presentViewController:alert animated:YES completion:nil];

}

#pragma mark - Browser Delegate

- (void)shareBrowser:(WALShareBrowserViewController *)browser didAddURL:(NSURL *)url {
	[self dismissViewControllerAnimated:YES completion:nil];
	[self performSelector:@selector(closeExtension) withObject:nil afterDelay:1.75];

	[self.activityIndicator stopAnimating];
	self.statusLabel.text = NSLocalizedString(@"Added link.", nil);
	self.statusDone.hidden = NO;
	self.statusError.hidden = YES;
}

- (void)shareBrowserNeedsFurtherActions:(WALShareBrowserViewController *)browser {
	NSLog(@"Need futher actions");
	if (self.presentedViewController == nil) {
		WALShareBrowserViewController *browser = [[WALShareBrowserViewController alloc] init];
		browser.webView = self.webView;
		browser.helper = self.helper;
		
		UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:browser];
		nav.modalPresentationStyle = UIModalPresentationFormSheet;
		[self presentViewController:nav animated:YES completion:nil];
	}
}

- (void)shareBrowser:(WALShareBrowserViewController *)browser didCancelWithError:(NSError *)error {
	[self dismissViewControllerAnimated:YES completion:nil];
	[self.activityIndicator stopAnimating];
	self.statusDone.hidden = YES;
	self.statusError.hidden = NO;

	if (error) {
		self.statusLabel.text = NSLocalizedString(@"Error adding link!", nil);
		[self showErrorAndCancelExtension:error.localizedDescription];
	} else {
		self.statusLabel.text = NSLocalizedString(@"Canceled!", nil);
		[self performSelector:@selector(cancelExtension) withObject:nil afterDelay:1.75];
	}
}

@end
