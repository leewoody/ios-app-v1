//
//  WALAddArticleTableViewController.m
//  Wallabag
//
//  Created by Kevin Meyer on 19.02.14.
//  Copyright (c) 2014 Wallabag. All rights reserved.
//

#import "WALAddArticleTableViewController.h"

@interface WALAddArticleTableViewController ()
@property (strong, nonatomic) IBOutlet UITextField *urlTextField;
- (IBAction)cancelButtonPushed:(id)sender;
- (IBAction)saveButtonPushed:(id)sender;
@end

@implementation WALAddArticleTableViewController

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[self.urlTextField becomeFirstResponder];
}

- (IBAction)cancelButtonPushed:(id)sender
{
	[self.delegate addArticleController:self didFinishWithURL:nil];
}

- (IBAction)saveButtonPushed:(id)sender
{
	NSURL *saveUrl = [NSURL URLWithString:self.urlTextField.text];
	
	if (saveUrl)
	{
		[self.delegate addArticleController:self didFinishWithURL:saveUrl];
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[[tableView cellForRowAtIndexPath:indexPath] setSelected:false animated:true];
	
	if (indexPath.section == 1 && indexPath.row == 0)
	{
		self.urlTextField.text = [[UIPasteboard generalPasteboard] string];
	}
}

@end
