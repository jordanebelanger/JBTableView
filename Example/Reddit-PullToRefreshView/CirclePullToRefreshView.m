//
//  CirclePullToRefreshView.m
//  JBTableView Example
//
//  Created by tehjord on 2014-09-07.
//  Copyright (c) 2014 Jordane Belanger. All rights reserved.
//

#import "CirclePullToRefreshView.h"

// UIView that gradually shows a full circle, used to inform the user about when he can
// release the pull to refresh view to initiate a pullToRefresh (when the circle is full)
//
@interface CirclePercentView : UIView

@property (assign, nonatomic) CGFloat percentShown;

@property (assign, nonatomic) CGFloat circleWidth;
@property (strong, nonatomic) UIColor *circleColor;

@end

@implementation CirclePercentView

- (void)drawRect:(CGRect)rect
{
    [self drawPercentCircleInRect:rect];
}

- (void)drawPercentCircleInRect:(CGRect)rect
{
    CGFloat circleWidth = self.circleWidth;
    CGFloat radius = (CGRectGetWidth(rect) / 2.0) - circleWidth/2;
    CGFloat startAngle = 0.0 - 90.0;
    CGFloat endAngle = (self.percentShown * 360.0) - 90.0;
    
    UIBezierPath* ovalPath = UIBezierPath.bezierPath;
    [ovalPath addArcWithCenter:CGPointMake(0, 0) radius:radius startAngle:startAngle * M_PI/180 endAngle:endAngle * M_PI/180 clockwise:YES];
    
    CGAffineTransform ovalTransform = CGAffineTransformMakeTranslation(CGRectGetMidX(rect), CGRectGetMidY(rect));
    ovalTransform = CGAffineTransformScale(ovalTransform, 1, CGRectGetHeight(rect) / CGRectGetWidth(rect));
    [ovalPath applyTransform:ovalTransform];
    
    [self.circleColor setStroke];
    ovalPath.lineWidth = self.circleWidth;
    [ovalPath stroke];
}

@end



@interface CirclePullToRefreshView ()

@property (assign, nonatomic) CGFloat percentShown;
@property (assign, nonatomic) CGFloat circleWidth;

@property (strong, nonatomic) UIImageView *animatedCircleImageView;
@property (strong, nonatomic) CirclePercentView *percentCircleView;

@property (assign, nonatomic, getter = isAnimatingCircle) BOOL animatingCircle;

@property (copy, nonatomic) dispatch_queue_t drawQueue;
@property (assign, nonatomic) BOOL animatedCircleImageNeedsDrawing;
@property (strong, nonatomic) UIImage *animatedCircleImage;

@end

@implementation CirclePullToRefreshView

#pragma mark - JBPullToRefreshView

- (void)setup
{
    _drawQueue = dispatch_queue_create("Draw Queue", DISPATCH_QUEUE_SERIAL);
    _animatedCircleImageNeedsDrawing = YES;
    _circleColor = self.circleColor;
    _circleWidth = 2.5;
    
    CGFloat circleDiameter = 21.0;
    CGRect circleViewFrame = CGRectMake((CGRectGetWidth(self.bounds) / 2.0) - (circleDiameter / 2.0),
                                        CGRectGetHeight(self.bounds) - circleDiameter,
                                        circleDiameter,
                                        circleDiameter);
    CirclePercentView *percentCircleView = [[CirclePercentView alloc] initWithFrame:circleViewFrame];
    percentCircleView.backgroundColor = [UIColor clearColor];
    percentCircleView.percentShown = 0.0;
    percentCircleView.circleWidth = _circleWidth;
    percentCircleView.circleColor = _circleColor;
    _percentCircleView = percentCircleView;
    
    UIImageView *animatedCircleImageView = [[UIImageView alloc] initWithFrame:circleViewFrame];
    animatedCircleImageView.backgroundColor = [UIColor clearColor];
    animatedCircleImageView.hidden = YES;
    _animatedCircleImageView = animatedCircleImageView;
    
    [self addSubview:percentCircleView];
    [self addSubview:animatedCircleImageView];
}

- (void)beginRefreshing
{
    self.animatingCircle = YES;
    
    [self rotateAnimatedCircleImageView];
}

- (void)endRefreshing
{
    self.animatingCircle = NO;
}

- (void)percentOfRefreshViewShown:(CGFloat)percentageShown;
{
	_percentCircleView.percentShown = percentageShown;
    if (!self.animatingCircle) {
        _animatedCircleImageView.hidden = YES;
        _percentCircleView.hidden = NO;
        [_percentCircleView setNeedsDisplay];
    } else {
        _animatedCircleImageView.hidden = NO;
        _percentCircleView.hidden = YES;
    }
}

+ (CGFloat)defaultHeight
{
    return 40.0;
}

#pragma mark - Public

- (UIColor *)ballsColor
{
    // Defaults the circleColor to black if the JBTableViewPullToRefreshViewDelegate was not used to
    // set the balls color before this pullToRefreshView's setup
    if (!_circleColor) {
        _circleColor = [UIColor blackColor];
    }
    return _circleColor;
}

- (void)setCircleColor:(UIColor *)circleColor
{
    self.percentCircleView.circleColor = circleColor;
    self.animatedCircleImageNeedsDrawing = YES;
    _circleColor = circleColor;
}

- (void)setCircleWidth:(CGFloat)circleWidth
{
    self.percentCircleView.circleWidth = circleWidth;
    self.animatedCircleImageNeedsDrawing = YES;
    _circleWidth = circleWidth;
}

#pragma mark - CAAnimationDelegate

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    if (self.isAnimatingCircle) {
        [self rotateAnimatedCircleImageView];
    }
}

#pragma mark - Private

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.animatedCircleImageNeedsDrawing) {
        self.animatedCircleImageNeedsDrawing = NO;
        
        __weak __typeof(self) weakself = self;
        dispatch_async(self.drawQueue, ^{
            [weakself generateAnimatedCircleImageWithRect:self.animatedCircleImageView.bounds];
            dispatch_async(dispatch_get_main_queue(), ^{
                weakself.animatedCircleImageView.image = weakself.animatedCircleImage;
            });
        });
    }
}

- (void)rotateAnimatedCircleImageView
{
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.delegate = self;
    rotationAnimation.toValue = [NSNumber numberWithFloat:M_PI * 2.0];
    rotationAnimation.duration = 0.6;
    rotationAnimation.repeatCount = 0.0;
    
    [self.animatedCircleImageView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void)generateAnimatedCircleImageWithRect:(CGRect)rect
{
    CGFloat radius = (CGRectGetWidth(rect) / 2.0);
    CGFloat circleWidth = self.circleWidth;
    
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0f);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Gradient
    CGFloat gradientLocations[] = {0, 1};
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)@[(id)self.circleColor.CGColor, (id)UIColor.whiteColor.CGColor], gradientLocations);
    
    // Outer circle with gradient
    CGRect ovalRect = rect;
    UIBezierPath* ovalPath = UIBezierPath.bezierPath;
    [ovalPath addArcWithCenter:CGPointMake(CGRectGetMidX(ovalRect), CGRectGetMidY(ovalRect)) radius: CGRectGetWidth(ovalRect) / 2 startAngle: 45 * M_PI/180 endAngle: 0 * M_PI/180 clockwise: YES];
    [ovalPath addLineToPoint:CGPointMake(CGRectGetMidX(ovalRect), CGRectGetMidY(ovalRect))];
    [ovalPath closePath];
    
    CGContextSaveGState(context);
    [ovalPath addClip];
    CGContextDrawLinearGradient(context, gradient, CGPointMake(radius, 0), CGPointMake(radius, radius*2), 0);
    CGContextRestoreGState(context);
    
    // Inner circle
    UIBezierPath* oval2Path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(circleWidth, circleWidth, (radius*2) - 2*circleWidth, (radius*2) - 2*circleWidth)];
    [oval2Path fillWithBlendMode:kCGBlendModeClear alpha:1.0];
    
    // Saving the drawing context as an image
    self.animatedCircleImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
}

@end
