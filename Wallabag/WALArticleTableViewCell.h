//
//  WALArticleTableViewCell.h
//  Wallabag
//
//  Created by Kevin Meyer on 03/10/14.
//  Copyright (c) 2014 Wallabag. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MGSwipeTableCell/MGSwipeTableCell.h>

@interface WALArticleTableViewCell : MGSwipeTableCell

@property (weak) IBOutlet UILabel *titleLabel;
@property (weak) IBOutlet UILabel *detailLabel;
@property (weak) IBOutlet UILabel *dateLabel;

@end
