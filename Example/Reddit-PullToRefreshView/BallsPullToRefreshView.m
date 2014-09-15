//
//  BallsPullToRefreshView.m
//  JBTableView Example
//
//  Created by tehjord on 2014-08-06.
//  Copyright (c) 2014 Jordane Belanger. All rights reserved.
//

#import "BallsPullToRefreshView.h"
#import <POP.h>
#import <UIView+DrawRectBlock.h>

// This is the famed Golden ratio. It is used to size subviews etc as it makes things look nice :)
static const CGFloat kGR = 1.61803398875;

@interface BallsPullToRefreshView ()

@property (assign, nonatomic) CGFloat ballHorizontalPadding;
@property (assign, nonatomic) CGFloat scaleFactor;

@property (assign, nonatomic) CGFloat ballDiameter;

@property (strong, nonatomic) UIView *leftBall;
@property (strong, nonatomic) UIView *middleBall;
@property (strong, nonatomic) UIView *rightBall;

@property (assign, nonatomic, getter = isAnimating) BOOL animating;

@property (assign, nonatomic) NSUInteger currentAnimationKey;

@end

@implementation BallsPullToRefreshView

#pragma mark - JBPullToRefreshView

- (void)setup
{
    _ballDiameter = 10.0;
    _ballHorizontalPadding = _ballDiameter / kGR;
    _scaleFactor = kGR;

    __weak __typeof(self) weakself = self;
    
    CGRect leftBallFrame = CGRectMake(CGRectGetMidX(self.bounds) - (self.ballDiameter / 2) - self.ballHorizontalPadding - self.ballDiameter,
                                      CGRectGetHeight(self.bounds) - self.scaleFactor*self.ballDiameter,
                                      self.ballDiameter,
                                      self.ballDiameter);
    UIView *leftBall = [UIView viewWithFrame:leftBallFrame drawRectBlock:^(CGRect rect) {
        [weakself drawCircleInRect:rect];
    }];
    leftBall.backgroundColor = [UIColor clearColor];
    self.leftBall = leftBall;
    
    CGRect middleBallFrame = CGRectMake(CGRectGetMidX(self.bounds) - (self.ballDiameter / 2),
                                        CGRectGetHeight(self.bounds) - self.scaleFactor*self.ballDiameter,
                                        self.ballDiameter,
                                        self.ballDiameter);
    UIView *middleBall = [UIView viewWithFrame:middleBallFrame drawRectBlock:^(CGRect rect) {
        [weakself drawCircleInRect:rect];
    }];
    middleBall.backgroundColor = [UIColor clearColor];
    self.middleBall = middleBall;
    
    CGRect rightBallFrame = CGRectMake(CGRectGetMidX(self.bounds) + (self.ballDiameter / 2) + self.ballHorizontalPadding,
                                       CGRectGetHeight(self.bounds) - self.scaleFactor*self.ballDiameter,
                                       self.ballDiameter,
                                       self.ballDiameter);
    UIView *rightBall = [UIView viewWithFrame:rightBallFrame drawRectBlock:^(CGRect rect) {
        [weakself drawCircleInRect:rect];
    }];
    rightBall.backgroundColor = [UIColor clearColor];
    self.rightBall = rightBall;
    
    [self addSubview:leftBall];
    [self addSubview:middleBall];
    [self addSubview:rightBall];
}

- (void)beginRefreshing
{
    self.animating = YES;
    [self removeAllBallsAnimation];
    [self animateBalls];
}

- (void)endRefreshing
{
    self.animating = NO;
}

- (void)percentOfRefreshViewShown:(CGFloat)percentShown
{
    if (!self.isAnimating) {
        CGFloat translationRawDistance = (_ballDiameter + _ballHorizontalPadding) * (1 - percentShown);
        
        CGAffineTransform leftBallTranslation = CGAffineTransformMakeTranslation(translationRawDistance, 0.0);
        self.leftBall.transform = leftBallTranslation;
        
        CGAffineTransform rightBallTranslation = CGAffineTransformMakeTranslation(-translationRawDistance, 0.0);
        self.rightBall.transform = rightBallTranslation;
    }
}

+ (CGFloat)defaultHeight
{
    return 40.0;
}

#pragma mark - Public

- (UIColor *)ballsColor
{
    // Defaults the ballsColor to black if the JBTableViewPullToRefreshViewDelegate was not used to
    // set the balls color before this pullToRefreshView's setup
    if (!_ballsColor) {
        _ballsColor = [UIColor blackColor];
    }
    return _ballsColor;
}

#pragma mark - Private

- (void)drawCircleInRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextAddEllipseInRect(ctx, rect);
    CGContextSetFillColorWithColor(ctx, self.ballsColor.CGColor);
    CGContextFillPath(ctx);
}

- (void)removeAllBallsAnimation
{
    [self.leftBall pop_removeAllAnimations];
    [self.middleBall pop_removeAllAnimations];
    [self.rightBall pop_removeAllAnimations];
}

- (NSUInteger)getNewAnimationKey
{
    if (self.currentAnimationKey > 1000) {
        self.currentAnimationKey = 0;
        return self.currentAnimationKey;
    }
    self.currentAnimationKey++;
    return self.currentAnimationKey;
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
    
    NSUInteger animationKey = [self getNewAnimationKey];
    
    __weak __typeof(self) weakself = self;
    [leftBallIncreaseAnim setCompletionBlock:^(POPAnimation *anim, BOOL finished) {
        if (weakself.currentAnimationKey == animationKey) {
            [weakself.leftBall.layer pop_addAnimation:leftBallDecreaseAnim forKey:@"size"];
            double delayInMs = 50.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInMs * NSEC_PER_MSEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [weakself.middleBall.layer pop_addAnimation:middleBallIncreaseAnim forKey:@"size"];
            });
        }
    }];
    
    [middleBallIncreaseAnim setCompletionBlock:^(POPAnimation *anim, BOOL finished) {
        if (weakself.currentAnimationKey == animationKey) {
            [weakself.middleBall.layer pop_addAnimation:middleBallDecreaseAnim forKey:@"size"];
            double delayInMs = 40.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInMs * NSEC_PER_MSEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [weakself.rightBall.layer pop_addAnimation:rightBallIncreaseAnim forKey:@"size"];
            });
        }
    }];
    
    [rightBallIncreaseAnim setCompletionBlock:^(POPAnimation *anim, BOOL finished) {
        if (weakself.currentAnimationKey == animationKey) {
            [weakself.rightBall.layer pop_addAnimation:rightBallDecreaseAnim forKey:@"size"];
        }
    }];
    
    [rightBallDecreaseAnim setCompletionBlock:^(POPAnimation *anim, BOOL finished) {
        if (weakself.currentAnimationKey == animationKey) {
            double delayInMs = 400.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInMs * NSEC_PER_MSEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                if (weakself.isAnimating) {
                    [weakself animateBalls];
                }
            });
        }
    }];
    
    [self.leftBall.layer pop_addAnimation:leftBallIncreaseAnim forKey:@"size"];
}

@end
