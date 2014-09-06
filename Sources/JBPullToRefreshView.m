//
//  JBPullToRefreshView.m
//  Redditerino
//
//  Created by tehjord on 2014-09-04.
//  Copyright (c) 2014 tehjord. All rights reserved.
//

#import "JBPullToRefreshView.h"

@interface PercentCircleView : UIView

@property (assign, nonatomic) CGFloat percentShown;

@end

@implementation PercentCircleView

-(void)drawRect:(CGRect)rect
{
    UIBezierPath* ovalPath = UIBezierPath.bezierPath;
    [ovalPath addArcWithCenter:CGPointMake(0, 0) radius: CGRectGetWidth(rect) / 2 startAngle:M_PI / 2.0 endAngle:self.percentShown * (5*(M_PI / 2))  clockwise: YES];
    
    CGAffineTransform ovalTransform = CGAffineTransformMakeTranslation(CGRectGetMidX(rect), CGRectGetMidY(rect));
    ovalTransform = CGAffineTransformScale(ovalTransform, 1, CGRectGetHeight(rect) / CGRectGetWidth(rect));
    [ovalPath applyTransform: ovalTransform];
    
    [UIColor.blueColor setStroke];
    ovalPath.lineWidth = 2;
    [ovalPath stroke];
}

@end




@interface JBPullToRefreshView ()

@property (strong, nonatomic) PercentCircleView *percentCircleView;

@end

@implementation JBPullToRefreshView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat circleRadius = 15.0;
        CGRect circleViewFrame = CGRectMake((CGRectGetWidth(frame) / 2) - (circleRadius / 2.0),
                                                   (CGRectGetHeight(frame) / 2) - (circleRadius / 2.0),
                                                   circleRadius,
                                                   circleRadius);
        PercentCircleView *percentCircleView = [[PercentCircleView alloc] initWithFrame:circleViewFrame];
        percentCircleView.percentShown = 0.0;
        self.percentCircleView = percentCircleView;
        
        [self addSubview:percentCircleView];
    }
    return self;
}

#pragma mark - JBPullToRefreshView

- (void)beginRefreshing
{
}

- (void)endRefreshing
{
}

+ (CGFloat)defaultHeight
{
    return 50.0;
}

- (void)percentOfRefreshViewShown:(CGFloat)percentageShown;
{
	self.percentCircleView.percentShown = percentageShown;
    [self.percentCircleView layoutIfNeeded];
}

@end
