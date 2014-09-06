//
//  JBPullToRefresh.m
//  Redditerino
//
//  Created by tehjord on 2014-08-06.
//  Copyright (c) 2014 tehjord. All rights reserved.
//

#import "JBBallsPullToRefreshView.h"
#import <POP.h>
#import <UIView+DrawRectBlock.h>

static const CGFloat kGR = 1.61803398875;

@interface JBBallsPullToRefreshView ()

@property (assign, nonatomic) CGFloat ballDiameter;
@property (assign, nonatomic) CGFloat ballHorizontalPadding;
@property (assign, nonatomic) CGFloat scaleFactor;

@property (assign, nonatomic) UIColor *ballColorDefault;
@property (assign, nonatomic) UIColor *ballColorActivated;

// This view slides down as the drawer is shown to give the impression that
// the refresh view is actually underneath the table and not underneath the navigation bar
//@property (strong, nonatomic) UIView *drawerView;

@property (strong, nonatomic) UIView *leftBall;
@property (strong, nonatomic) UIView *middleBall;
@property (strong, nonatomic) UIView *rightBall;

@property (assign, nonatomic, getter = isAnimating) BOOL animating;

@end

@implementation JBBallsPullToRefreshView

@synthesize distanceFromTop = _distanceFromTop;
@synthesize percentShown = _percentShown;
@synthesize refreshing = _refreshing;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _ballDiameter = 10.0;
        _ballHorizontalPadding = _ballDiameter / kGR;
        _scaleFactor = kGR;
        _ballColorDefault = [UIColor grayColor];
        _ballColorActivated = [UIColor blackColor];

        [self setupElements];
    }
    return self;
}

- (void)setupElements
{
    __weak __typeof(self) weakself = self;
    
//    CGRect drawerViewFrame = CGRectMake(0.0,
//                                        CGRectGetHeight(self.bounds),
//                                        CGRectGetWidth(self.bounds),
//                                        CGRectGetHeight(self.bounds));
//    UIView *drawerView = [[UIView alloc] initWithFrame:drawerViewFrame];
//    drawerView.backgroundColor = [UIColor clearColor];
//    self.drawerView = drawerView;
    
    CGRect leftBallFrame = CGRectMake(CGRectGetMidX(self.bounds) - (self.ballDiameter / 2) - self.ballHorizontalPadding - self.ballDiameter,
                                      CGRectGetMidY(self.bounds) - (self.ballDiameter / 2),
                                      self.ballDiameter,
                                      self.ballDiameter);
    UIView *leftBall = [UIView viewWithFrame:leftBallFrame drawRectBlock:^(CGRect rect) {
        [weakself drawCircleInRect:rect];
    }];
    leftBall.backgroundColor = [UIColor clearColor];
    self.leftBall = leftBall;
    
    CGRect middleBallFrame = CGRectMake(CGRectGetMidX(self.bounds) - (self.ballDiameter / 2),
                                      CGRectGetMidY(self.bounds) - (self.ballDiameter / 2),
                                      self.ballDiameter,
                                      self.ballDiameter);
    UIView *middleBall = [UIView viewWithFrame:middleBallFrame drawRectBlock:^(CGRect rect) {
        [weakself drawCircleInRect:rect];
    }];
    middleBall.backgroundColor = [UIColor clearColor];
    self.middleBall = middleBall;
    
    CGRect rightBallFrame = CGRectMake(CGRectGetMidX(self.bounds) + (self.ballDiameter / 2) + self.ballHorizontalPadding,
                                      CGRectGetMidY(self.bounds) - (self.ballDiameter / 2),
                                      self.ballDiameter,
                                      self.ballDiameter);
    UIView *rightBall = [UIView viewWithFrame:rightBallFrame drawRectBlock:^(CGRect rect) {
        [weakself drawCircleInRect:rect];
    }];
    rightBall.backgroundColor = [UIColor clearColor];
    self.rightBall = rightBall;
    
//    [self addSubview:drawerView];
//    [drawerView addSubview:leftBall];
//    [drawerView addSubview:middleBall];
//    [drawerView addSubview:rightBall];
    [self addSubview:leftBall];
    [self addSubview:middleBall];
    [self addSubview:rightBall];
}

#pragma mark - JBPullToRefreshView

- (void)beginRefreshing
{
    [self animateBalls];
}

- (void)endRefreshing
{
    //
}

- (void)positionUpdated
{
    
}

+ (CGFloat)defaultHeight
{
    return 50.0;
}

#pragma mark - Private

- (void)drawCircleInRect:(CGRect)rect
{
    UIColor *circleColor = (self.isAnimating || self.percentShown >= 1.0) ? self.ballColorActivated : self.ballColorDefault;
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextAddEllipseInRect(ctx, rect);
    CGContextSetFillColorWithColor(ctx, circleColor.CGColor);
    CGContextFillPath(ctx);
}

- (void)animateBalls
{
    CGFloat factor = self.scaleFactor;
    CGFloat ballDiameter = self.ballDiameter;
    CGFloat ballDiameterIncreased = ballDiameter * factor;
    
    POPSpringAnimation *leftBallIncreaseAnim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerBounds];
    leftBallIncreaseAnim.springBounciness = 7;
    leftBallIncreaseAnim.removedOnCompletion = YES; 
    leftBallIncreaseAnim.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, ballDiameterIncreased, ballDiameterIncreased)];
    
    POPSpringAnimation *leftBallDecreaseAnim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerBounds];
    leftBallDecreaseAnim.springBounciness = 15;
    leftBallDecreaseAnim.removedOnCompletion = YES;
    leftBallDecreaseAnim.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, ballDiameter, ballDiameter)];
    
    POPSpringAnimation *middleBallIncreaseAnim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerBounds];
    middleBallIncreaseAnim.springBounciness = 7;
    middleBallIncreaseAnim.removedOnCompletion = YES;
    middleBallIncreaseAnim.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, ballDiameterIncreased, ballDiameterIncreased)];
    
    POPSpringAnimation *middleBallDecreaseAnim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerBounds];
    middleBallDecreaseAnim.springBounciness = 19;
    middleBallDecreaseAnim.removedOnCompletion = YES;
    middleBallDecreaseAnim.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, ballDiameter, ballDiameter)];
    
    POPSpringAnimation *rightBallIncreaseAnim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerBounds];
    rightBallIncreaseAnim.springBounciness = 7;
    rightBallIncreaseAnim.removedOnCompletion = YES;
    rightBallIncreaseAnim.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, ballDiameterIncreased, ballDiameterIncreased)];
    
    POPSpringAnimation *rightBallDecreaseAnim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerBounds];
    rightBallDecreaseAnim.springBounciness = 24;
    rightBallDecreaseAnim.removedOnCompletion = YES;
    rightBallDecreaseAnim.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, ballDiameter, ballDiameter)];
    
    __weak __typeof(self) weakself = self;
    [leftBallIncreaseAnim setCompletionBlock:^(POPAnimation *anim, BOOL finished) {
        [weakself.leftBall.layer pop_addAnimation:leftBallDecreaseAnim forKey:@"size"];
        double delayInMs = 50.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInMs * NSEC_PER_MSEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [weakself.middleBall.layer pop_addAnimation:middleBallIncreaseAnim forKey:@"size"];
        });
    }];
    
    [middleBallIncreaseAnim setCompletionBlock:^(POPAnimation *anim, BOOL finished) {
        [weakself.middleBall.layer pop_addAnimation:middleBallDecreaseAnim forKey:@"size"];
        double delayInMs = 40.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInMs * NSEC_PER_MSEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [weakself.rightBall.layer pop_addAnimation:rightBallIncreaseAnim forKey:@"size"];
        });
    }];
    
    [rightBallIncreaseAnim setCompletionBlock:^(POPAnimation *anim, BOOL finished) {
        [weakself.rightBall.layer pop_addAnimation:rightBallDecreaseAnim forKey:@"size"];
    }];
    
    [rightBallDecreaseAnim setCompletionBlock:^(POPAnimation *anim, BOOL finished) {
        double delayInMs = 450.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInMs * NSEC_PER_MSEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//            if (weakself.isAnimating) {
                [weakself animateBalls];
//            }
        });
    }];
    
    [self.leftBall.layer pop_addAnimation:leftBallIncreaseAnim forKey:@"size"];
}

@end
