//
//  JBTableView.m
//  JBTableView
//
//  Created by tehjord on 2014-08-06.
//  Copyright (c) 2014 Jordan Belanger. All rights reserved.
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

- (instancetype)initWithPullToRefreshViewClass:(Class<JBPullToRefreshView>)pullToRefreshViewClass
{
	self = [super init];
    if (self) {
        self.pullToRefreshViewClass = pullToRefreshViewClass;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame pullToRefreshViewClass:(Class<JBPullToRefreshView>)pullToRefreshViewClass
{
    self = [super init];
    if (self) {
        self.pullToRefreshViewClass = pullToRefreshViewClass;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style pullToRefreshViewClass:(Class<JBPullToRefreshView>)pullToRefreshViewClass
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        self.pullToRefreshViewClass = pullToRefreshViewClass;
    }
    return self;
}

#pragma mark - Private

- (void)layoutSubviews
{
    if (self.pullToRefreshViewNeedsLayout) {
        self.pullToRefreshViewNeedsLayout = NO;
        [self setupPullToRefreshView];
    }
    
    [super layoutSubviews];
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
    
    CGFloat pullToRefreshViewHeight = [self.pullToRefreshViewClass defaultHeight];
    CGFloat pullToRefreshViewWidth = CGRectGetWidth(self.bounds);
    CGRect pullToRefreshViewFrame = CGRectMake(0.0f,
                                               -pullToRefreshViewHeight,
                                               pullToRefreshViewWidth,
                                               pullToRefreshViewHeight);
    
    UIView<JBPullToRefreshView> *pullToRefreshView = [[self.pullToRefreshViewClass alloc] initWithFrame:pullToRefreshViewFrame];
    
    NSAssert([pullToRefreshView isKindOfClass:[UIView class]], @"Your JBPullToRefreshView Class must be a UIView subclass");
    NSAssert([pullToRefreshView conformsToProtocol:@protocol(JBPullToRefreshView)], @"Your JBPullToRefreshView Class must conform to the JBPullToRefreshView protocol");
    
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
    self.refreshing = YES;
}

- (void)stopRefreshing
{
    self.refreshing = NO; 
}

- (void)setRefreshing:(BOOL)animatingPullToRefresh
{
    if (animatingPullToRefresh && !self.refreshing) {
        [self.pullToRefreshView beginRefreshing];
        UIEdgeInsets contentInset = self.contentInset;
        CGPoint contentOffset = self.contentOffset;
        
        contentInset.top += CGRectGetHeight(self.pullToRefreshView.bounds);
        contentOffset.y -= CGRectGetHeight(self.pullToRefreshView.bounds);
        
        [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut animations:^{
            self.contentInset = contentInset;
            self.contentOffset = contentOffset;
        } completion:nil];

    } else if (!animatingPullToRefresh && self.refreshing) {
        [self.pullToRefreshView endRefreshing];
        UIEdgeInsets contentInset = self.contentInset;
        CGPoint contentOffset = self.contentOffset;
        
        contentInset.top -= CGRectGetHeight(self.pullToRefreshView.bounds);
        contentOffset.y += CGRectGetHeight(self.pullToRefreshView.bounds);
        
        [UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut animations:^{
            self.contentInset = contentInset;
            self.contentOffset = contentOffset;
        } completion:^(BOOL finished) {
        }];
    }
    
    _refreshing = animatingPullToRefresh;
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
        if (percentShown < 0.0) {
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
