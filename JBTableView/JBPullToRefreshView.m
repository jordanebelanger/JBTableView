//
//  JBPullToRefreshView.m
//  JBTableView
//
//  Created by tehjord on 2014-09-04.
//  Copyright (c) 2014 Jordan Belanger. All rights reserved.
//

#import "JBPullToRefreshView.h"

@interface JBPullToRefreshView ()

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;

@end

@implementation JBPullToRefreshView

- (void)setup
{
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicatorView = activityIndicatorView;
    
    // Placing the UIActivityIndicatorView in the X center and Y bottom of the pullToRefreshView
    CGRect activityIndicatorViewFrame = CGRectMake((CGRectGetWidth(self.bounds) / 2) - (CGRectGetWidth(activityIndicatorView.bounds) / 2.0),
                                                   CGRectGetHeight(self.bounds) - CGRectGetWidth(activityIndicatorView.bounds),
                                                   CGRectGetWidth(activityIndicatorView.bounds),
                                                   CGRectGetHeight(activityIndicatorView.bounds));
    activityIndicatorView.frame = activityIndicatorViewFrame;
    activityIndicatorView.color = [UIColor blackColor];
    activityIndicatorView.hidesWhenStopped = NO;

    [self addSubview:activityIndicatorView];
}

#pragma mark - JBPullToRefreshView

- (void)beginRefreshing
{
    [self.activityIndicatorView startAnimating];
}

- (void)endRefreshing
{
    [self.activityIndicatorView stopAnimating];
}

+ (CGFloat)defaultHeight
{
    return 40.0;
}

- (void)percentOfRefreshViewShown:(CGFloat)percentageShown;
{
    // Progressively grow and rotate the activity indicator view to its full size as it becomes visible on screen
    if (!self.activityIndicatorView.isAnimating) {
        CGAffineTransform scaleTransform = CGAffineTransformMakeScale(percentageShown, percentageShown);
        CGAffineTransform rotationTransform = CGAffineTransformMakeRotation(-2*M_PI + (percentageShown * 2*M_PI));
        CGAffineTransform finalTransform = CGAffineTransformConcat(scaleTransform, rotationTransform);
        
        self.activityIndicatorView.transform = finalTransform;
    }
}

@end
