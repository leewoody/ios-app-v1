//
//  WALBrowserViewController.h
//  Wallabag
//
//  Created by Kevin Meyer on 24.02.14.
//  Copyright (c) 2014 Wallabag. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WALBrowserViewController : UIViewController <UIWebViewDelegate>

- (void)setStartURL:(NSURL*) startURL;

@end
