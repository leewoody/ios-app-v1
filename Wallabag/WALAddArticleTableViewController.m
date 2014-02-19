//
//  WALAddArticleTableViewController.m
//  Wallabag
//
//  Created by Kevin Meyer on 19.02.14.
//  Copyright (c) 2014 Wallabag. All rights reserved.
//

#import "WALAddArticleTableViewController.h"

@interface WALAddArticleTableViewController ()
- (IBAction)cancelButtonPushed:(id)sender;
@end

@implementation WALAddArticleTableViewController


- (IBAction)cancelButtonPushed:(id)sender
{
	[self.delegate callbackFromAddArticleController:self withURL:nil];
}
@end
