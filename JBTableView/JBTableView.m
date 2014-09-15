//
//  JBTableView.m
//  JBTableView
//
//  Created by tehjord on 2014-08-06.
//  Copyright (c) 2014 Jordane Belanger. All rights reserved.
//

#import "JBTableView.h"
#import "JBPullToRefreshView.h"

@interface JBTableView () <UITableViewDelegate>

@property (weak, nonatomic) id<UITableViewDelegate> publicDelegate;
@property (assign, nonatomic) BOOL publicDelegateRespondsToDidScroll;
@property (assign, nonatomic) BOOL publicDelegateRespondsToDidEndDragging;

@property (strong, nonatomic) UIView<JBPullToRefreshView> *pullToRefreshView;
@property (assign, nonatomic) BOOL pullToRefreshViewRespondsToRefreshViewDistanceFromTableTop;
@property (assign, nonatomic) BOOL pullToRefreshViewRespondsToPercentOfRefreshViewShown;

@property (assign, nonatomic, getter = isRefreshing) BOOL refreshing;

@property (assign, nonatomic) BOOL pullToRefreshViewNeedsLayout;

@end

@implementation JBTableView

@synthesize pullToRefreshViewClass = _pullToRefreshViewClass;

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self defaultSetup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self defaultSetup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        [self defaultSetup];
    }
    return self;
}

- (instancetype)initWithPullToRefreshViewClass:(Class<JBPullToRefreshView>)pullToRefreshViewClass
{
	self = [super init];
    if (self) {
        self.pullToRefreshViewClass = pullToRefreshViewClass;
        [self defaultSetup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame pullToRefreshViewClass:(Class<JBPullToRefreshView>)pullToRefreshViewClass
{
    self = [super init];
    if (self) {
        self.pullToRefreshViewClass = pullToRefreshViewClass;
        [self defaultSetup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style pullToRefreshViewClass:(Class<JBPullToRefreshView>)pullToRefreshViewClass
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        self.pullToRefreshViewClass = pullToRefreshViewClass;
        [self defaultSetup];
    }
    return self;
}

- (void)defaultSetup
{
    self.pullToRefreshViewNeedsLayout = YES;
    self.minimumRefreshTime = 1.0;
}

#pragma mark - Private

- (void)layoutSubviews
{
    [super layoutSubviews];

    if (self.pullToRefreshViewNeedsLayout) {
        self.pullToRefreshViewNeedsLayout = NO;
        [self setupPullToRefreshView];
    }
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    self.pullToRefreshViewNeedsLayout = YES;
}

- (Class)pullToRefreshViewClass
{
    if (!_pullToRefreshViewClass) {
        _pullToRefreshViewClass = [JBPullToRefreshView class];
    }
    return _pullToRefreshViewClass;
}

- (void)setPullToRefreshViewClass:(Class)pullToRefreshViewClass
{
    _pullToRefreshViewClass = pullToRefreshViewClass;
    
    self.pullToRefreshViewNeedsLayout = YES;
}

- (void)setupPullToRefreshView
{
    if (self.pullToRefreshView) {
        [self.pullToRefreshView removeFromSuperview];
        self.pullToRefreshView = nil;
    }
    
    UIView<JBPullToRefreshView> *pullToRefreshView = [[self.pullToRefreshViewClass alloc] init];
    
    NSAssert([pullToRefreshView isKindOfClass:[UIView class]], @"Your JBPullToRefreshView Class must be a UIView subclass");
    NSAssert([pullToRefreshView conformsToProtocol:@protocol(JBPullToRefreshView)], @"Your JBPullToRefreshView Class must conform to the JBPullToRefreshView protocol");
    
    CGFloat pullToRefreshViewHeight = [self.pullToRefreshViewClass defaultHeight];
    CGFloat pullToRefreshViewWidth = CGRectGetWidth(self.bounds);
    CGRect pullToRefreshViewFrame = CGRectMake(0.0f,
                                               -pullToRefreshViewHeight,
                                               pullToRefreshViewWidth,
                                               pullToRefreshViewHeight);
    pullToRefreshView.frame = pullToRefreshViewFrame;
    
    [self.pullToRefreshViewDelegate JBTableView:self willSetupPullToRefreshView:pullToRefreshView];
    [pullToRefreshView setup];
    
    self.pullToRefreshView = pullToRefreshView;

    self.pullToRefreshViewRespondsToRefreshViewDistanceFromTableTop = [pullToRefreshView respondsToSelector:@selector(refreshViewDistanceFromTableTop:)];
    self.pullToRefreshViewRespondsToPercentOfRefreshViewShown = [pullToRefreshView respondsToSelector:@selector(percentOfRefreshViewShown:)];

    [self addSubview:pullToRefreshView];
    [self sendSubviewToBack:pullToRefreshView];
}

#pragma mark - Public

- (void)startRefreshing
{
    if (!_refreshing) {
        UIEdgeInsets contentInset = self.contentInset;
        CGPoint contentOffset = self.contentOffset;
        
        contentInset.top += CGRectGetHeight(self.pullToRefreshView.bounds);
        contentOffset.y -= CGRectGetHeight(self.pullToRefreshView.bounds);
        
        [_pullToRefreshView beginRefreshing];
        
        __weak __typeof(self) weakself = self;
        [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut animations:^{
            weakself.contentInset = contentInset;
            weakself.contentOffset = contentOffset;
        } completion:nil];
    } else {
        NSLog(@"Warning: Unbalanced call to beginRefreshing, make sure you call stopRefreshing before calling startRefreshing again and that the JBTableView refreshing property is FALSE at the moment beginRefreshing is called.");
    }
    _refreshing = YES;
}

- (void)stopRefreshing
{
    if (_refreshing) {
        // Calling a UIView animateWithDuration:delay animation will sometime freeze the initial contentInset refresh animation even with a non zero delay parameter.
        // Using a dispatch_after block ensure the initial animation is not blocked
        __weak __typeof(self) weakself = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(weakself.minimumRefreshTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UIEdgeInsets contentInset = weakself.contentInset;
            CGPoint contentOffset = weakself.contentOffset;
            
            contentInset.top -= CGRectGetHeight(weakself.pullToRefreshView.bounds);
            contentOffset.y += CGRectGetHeight(weakself.pullToRefreshView.bounds);
            [UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseIn animations:^{
                weakself.contentInset = contentInset;
                weakself.contentOffset = contentOffset;
            } completion:^(BOOL finished) {
                [weakself.pullToRefreshView endRefreshing];
                weakself.refreshing = NO;
            }];
        });
    } else {
        NSLog(@"Warning: Unbalanced call to endRefreshing, make sure you called beginRefreshing before calling endRefreshing");
    }
}

#pragma mark - UITableViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pullToRefreshViewHeight = CGRectGetHeight(_pullToRefreshView.bounds);
    CGFloat contentInsetTop = scrollView.contentInset.top;
    CGFloat contentOffSetY = scrollView.contentOffset.y;
    CGFloat distanceFromTop = -(contentInsetTop + contentOffSetY + pullToRefreshViewHeight);

    if (_pullToRefreshViewRespondsToRefreshViewDistanceFromTableTop) {
        [_pullToRefreshView refreshViewDistanceFromTableTop:distanceFromTop];
    }
    
    if (_pullToRefreshViewRespondsToPercentOfRefreshViewShown) {
        CGFloat percentShown = (distanceFromTop + pullToRefreshViewHeight) / pullToRefreshViewHeight;
        if (_refreshing) {
            percentShown = 1.0;
        } else if (percentShown < 0.0) {
            percentShown = 0.0;
        } else if (percentShown > 1.0) {
            percentShown = 1.0;
        }
        [_pullToRefreshView percentOfRefreshViewShown:percentShown];
    }
    
    if (_publicDelegateRespondsToDidScroll) {
        [_publicDelegate scrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView.contentOffset.y <= -CGRectGetHeight(_pullToRefreshView.bounds) - scrollView.contentInset.top && !_refreshing) {
        if (_pullToRefreshBlock) _pullToRefreshBlock();
    }
    
    if (_publicDelegateRespondsToDidEndDragging) {
        [_publicDelegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

#pragma mark - UITableViewDelegate Forwarding

- (void)setDelegate:(id<UITableViewDelegate>)delegate
{
    if (delegate == self) return;
    
    self.publicDelegate = delegate;
    
    self.publicDelegateRespondsToDidScroll = [self.publicDelegate respondsToSelector:@selector(scrollViewDidScroll:)];
    self.publicDelegateRespondsToDidEndDragging = [self.publicDelegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)];

    [super setDelegate:self];
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    if ([super respondsToSelector:aSelector]) return YES;
    
    return [self.publicDelegate respondsToSelector:aSelector];
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    return self.publicDelegate;
}

@end
