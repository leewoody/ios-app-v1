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

@property (weak) IBOutlet UILabel *statusLabel;
@property (weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong) WALShareBrowserViewController *browserVC;

@end

@implementation WALShareStartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	WALSettings *settings = [[WALSettings alloc] init];
	[settings setWallabagURL:[NSURL URLWithString:@"http://example.com/"]];
	

	NSExtensionItem *item = self.extensionContext.inputItems[0];
	NSItemProvider *provider = item.attachments[0];
	[provider loadItemForTypeIdentifier:@"public.url" options:nil completionHandler:^(id<NSSecureCoding> item, NSError *error) {
		NSURL* addUrl = (NSURL*)item;
		self.browserVC = [[UIStoryboard storyboardWithName:@"MainInterface" bundle:nil] instantiateViewControllerWithIdentifier:@"BrowserViewController"];
		self.browserVC.delegate = self;
		self.browserVC.addUrl = addUrl;
		self.browserVC.settings = settings;

		UINavigationController *navC = [[UINavigationController alloc] initWithRootViewController:self.browserVC];
		navC.modalPresentationStyle = UIModalPresentationFormSheet;
		[self presentViewController:navC animated:YES completion:nil];
	}];
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
