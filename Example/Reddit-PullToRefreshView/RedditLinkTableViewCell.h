//
//  JBLinkTableViewCell.h
//  JBTableView Example
//
//  Created by tehjord on 2014-09-04.
//  Copyright (c) 2014 Jordane Belanger. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const kRedditLinkTableViewCellIdentifier;

@interface RedditLinkTableViewCell : UITableViewCell

+ (CGFloat)cellHeightForCellWidth:(CGFloat)cellWidth withLinkTitle:(NSString *)linkTitle;

@end
