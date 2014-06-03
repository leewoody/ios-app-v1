//
//  WALDetailViewController.h
//  Wallabag
//
//  Created by Kevin Meyer on 19.02.14.
//  Copyright (c) 2014 Wallabag. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WALThemeOrganizerDelegate.h"
@class WALArticle;

@interface WALArticleViewController : UIViewController<UIWebViewDelegate, WALThemeOrganizerDelegate>

- (void) setDetailArticle:(WALArticle*) article;

@end
