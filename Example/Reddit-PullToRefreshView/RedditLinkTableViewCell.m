//
//  JBLinkTableViewCell.m
//  JBTableView Example
//
//  Created by tehjord on 2014-09-04.
//  Copyright (c) 2014 Jordan Belanger. All rights reserved.
//

#import "RedditLinkTableViewCell.h"

NSString * const kRedditLinkTableViewCellIdentifier = @"kRedditLinkTableViewCellIdentifier";

static UIFont *kLinkTitleFont;
static const CGFloat kHorizontalPadding = 10.0;
static const CGFloat kVerticalPadding = 10.0;

@implementation RedditLinkTableViewCell

+ (void)initialize
{
    kLinkTitleFont = [UIFont systemFontOfSize:18.0];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.font = kLinkTitleFont;
        self.textLabel.textColor = [UIColor colorWithRed:0.1 green:0.4 blue:0.7 alpha:1.0];
        self.textLabel.numberOfLines = 0;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGRect textLabelFrame = CGRectMake(kHorizontalPadding,
                                       kVerticalPadding,
                                       CGRectGetWidth(self.contentView.bounds) - 2*kHorizontalPadding,
                                       CGRectGetHeight(self.contentView.bounds) - 2*kVerticalPadding);
    self.textLabel.frame = textLabelFrame;
}

#pragma mark - Public

+ (CGFloat)cellHeightForCellWidth:(CGFloat)cellWidth withLinkTitle:(NSString *)linkTitle
{
    CGFloat height = 2*kVerticalPadding; //top + bottom padding
    CGRect linkTitleBoundingRect = [linkTitle boundingRectWithSize:CGSizeMake(cellWidth - 2*kHorizontalPadding, CGFLOAT_MAX)
                                                           options:NSStringDrawingUsesLineFragmentOrigin
                                                        attributes:@{NSFontAttributeName: kLinkTitleFont} context:nil];
    height += CGRectGetHeight(linkTitleBoundingRect);
    return ceil(height + 1.0);
}

@end
