//
//  WALShareStartViewController.m
//  Wallabag
//
//  Created by Kevin Meyer on 17/01/15.
//  Copyright (c) 2015 Wallabag. All rights reserved.
//

#import "WALShareStartViewController.h"
#import "WALShareBrowserViewController.h"

#import <MobileCoreServices/MobileCoreServices.h>

#import "WALSettings.h"

@interface WALShareStartViewController ()<WALShareBrowserDelegate>

@property (weak) IBOutlet UIView *statusView;
@property (weak) IBOutlet UILabel *statusLabel;
@property (weak) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (strong) WALShareBrowserViewController *browserVC;
@property (strong) NSURL *addUrl;
@property (strong) WALSettings *settings;

@end

@implementation WALShareStartViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	self.statusView.layer.cornerRadius = 8;
	self.statusView.alpha = 0;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	self.settings = [WALSettings settingsFromSavedSettings];
	if (!self.settings) {
		UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Warning"
																	   message:@"In order to use the wallabag extension, you have to configure your account inside the wallabag app first."
																preferredStyle:UIAlertControllerStyleAlert];
		[alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
			[self cancelExtension];
		}]];
		[self presentViewController:alert animated:YES completion:nil];
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
	[self cancelExtension];
}

- (void)startBrowserViewController {
	self.browserVC = [[UIStoryboard storyboardWithName:@"MainInterface" bundle:nil] instantiateViewControllerWithIdentifier:@"BrowserViewController"];
	self.browserVC.delegate = self;
	self.browserVC.addUrl = self.addUrl;
	self.browserVC.settings = self.settings;
	
	UINavigationController *navC = [[UINavigationController alloc] initWithRootViewController:self.browserVC];
	navC.modalPresentationStyle = UIModalPresentationFormSheet;
	[self presentViewController:navC animated:YES completion:nil];
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

#pragma mark - Browser Delegate

- (void)shareBrowser:(WALShareBrowserViewController *)browser didAddURL:(NSURL *)url {
	[self dismissViewControllerAnimated:YES completion:^{
		[self performSelector:@selector(closeExtension) withObject:nil afterDelay:2];
	}];

	self.statusLabel.text = @"Successfully added link!";
	[self.activityIndicator stopAnimating];
}

- (void)shareBrowserNeedsFurtherActions:(WALShareBrowserViewController *)browser {
}

- (void)shareBrowser:(WALShareBrowserViewController *)browser didCancelWithError:(NSError *)error {
	[self dismissViewControllerAnimated:YES completion:^{
		[self performSelector:@selector(cancelExtension) withObject:nil afterDelay:1.75];
	}];

	if (error) {
		self.statusLabel.text = @"Error adding link!";
	} else {
		self.statusLabel.text = @"Canceled!";
	}
	[self.activityIndicator stopAnimating];
}

@end
