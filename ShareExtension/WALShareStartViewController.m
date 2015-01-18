//
//  WALShareStartViewController.m
//  Wallabag
//
//  Created by Kevin Meyer on 17/01/15.
//  Copyright (c) 2015 Wallabag. All rights reserved.
//

#import "WALShareStartViewController.h"
#import "WALShareBrowserViewController.h"

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


	NSExtensionItem *item = self.extensionContext.inputItems[0];
	NSItemProvider *provider = item.attachments[0];
	[provider loadItemForTypeIdentifier:@"public.url" options:nil completionHandler:^(id<NSSecureCoding> item, NSError *error) {
		self.addUrl = (NSURL*)item;
		dispatch_async(dispatch_get_main_queue(), ^{
			[UIView animateWithDuration:0.25 animations:^{
				self.statusView.alpha = 1.0;
			} completion:^(BOOL finished) {
				[self startBrowserViewController];
			}];
		});
	}];
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
	[self.extensionContext cancelRequestWithError:nil];
}

- (void)closeExtension {
	[self.extensionContext completeRequestReturningItems:nil completionHandler:nil];
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

- (void)shareBrowserDidCancel:(WALShareBrowserViewController *)browser {
	[self dismissViewControllerAnimated:YES completion:^{
		[self performSelector:@selector(cancelExtension) withObject:nil afterDelay:2];
	}];

	self.statusLabel.text = @"Canceled!";
	[self.activityIndicator stopAnimating];
}

@end
