//
//  JBLinkTableViewCell.m
//  JBTableView Example
//
//  Created by tehjord on 2014-09-04.
//  Copyright (c) 2014 Jordan Belanger. All rights reserved.
//

#import "JBLinkTableViewCell.h"

NSString * const JBLinkTableViewCellIdentifier = @"JBLinkTableViewCellIdentifier";

static const CGFloat kHorizontalPadding = 10.0;
static const CGFloat kVerticalPadding = 10.0;

@implementation JBLinkTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:80.0/255.0 green:80/255.0 blue:50.0/255.0 alpha:1.0];
        self.textLabel.font = [UIFont systemFontOfSize:18.0];
        self.textLabel.textColor = [UIColor brownColor];
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
    CGFloat height = kVerticalPadding * 2; //top + bottom padding
    CGRect linkTitleBoundingRect = [linkTitle boundingRectWithSize:CGSizeMake(cellWidth - 2*kHorizontalPadding, CGFLOAT_MAX)
                                                           options:NSStringDrawingUsesLineFragmentOrigin
                                                        attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:18.0]} context:nil];
    height += CGRectGetHeight(linkTitleBoundingRect);
    return ceil(height + 1);
}

@end
