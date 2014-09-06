//
//  JBTableView.m
//  Redditerino
//
//  Created by tehjord on 2014-08-06.
//  Copyright (c) 2014 tehjord. All rights reserved.
//

#import "JBTableView.h"
#import "JBPullToRefreshView.h"
#import <objc/runtime.h>

@interface JBTableView () <UITableViewDelegate>

@property (weak, nonatomic) id<UITableViewDelegate> publicDelegate;
@property (weak, nonatomic) id<UITableViewDataSource> publicDataSource;

// Public delegate method responded to caching, to avoid costly respondsToSelector calls
@property (assign, nonatomic) BOOL publicDelegateRespondsToDidScroll;
@property (assign, nonatomic) BOOL publicDelegateRespondsToDidEndDragging;

// The pullToRefreshView and caching its private ivar for quick modifications
@property (assign, nonatomic) Class pullToRefreshViewClass;
@property (strong, nonatomic) UIView<JBPullToRefreshView> *pullToRefreshView;
@property (assign, nonatomic) BOOL pullToRefreshViewRespondToPositionUpdated;
@property (assign, nonatomic) CGFloat *pullToRefreshViewDistanceFromTop;
@property (assign, nonatomic) CGFloat *pullToRefreshViewPercentShown;
@property (assign, nonatomic) BOOL *pullToRefreshViewRefreshing;

@property (assign, nonatomic, getter = isAnimatingContentInset) BOOL animatingContentInset;

@end

@implementation JBTableView

- (instancetype)init
{
    self = [self init];
    if (self) {
        _pullToRefreshViewClass = [JBPullToRefreshView class];
        [self setupPullToRefreshView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [self initWithCoder:aDecoder];
    if (self) {
        _pullToRefreshViewClass = [JBPullToRefreshView class];
        [self setupPullToRefreshView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        _pullToRefreshViewClass = [JBPullToRefreshView class];
        [self setupPullToRefreshView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _pullToRefreshViewClass = [JBPullToRefreshView class];
        [self setupPullToRefreshView];
    }
    return self;
}

- (instancetype)initWithPullToRefreshViewClass:(Class<JBPullToRefreshView>)pullToRefreshViewClass
{
    self = [super init];
    if (self) {
        _pullToRefreshViewClass = pullToRefreshViewClass;
        [self setupPullToRefreshView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame pullToRefreshViewClass:(Class<JBPullToRefreshView>)pullToRefreshViewClass
{
    self = [super initWithFrame:frame];
    if (self) {
        _pullToRefreshViewClass = pullToRefreshViewClass;
        [self setupPullToRefreshView];
    }
    return self;
}

#pragma mark - Private

- (void)setupPullToRefreshView
{
    CGFloat customRefreshControlHeight = [self.pullToRefreshViewClass defaultHeight];
    CGFloat customRefreshControlWidth = CGRectGetWidth(self.bounds);
    CGRect customRefreshControlFrame = CGRectMake(0.0f,
                                                  -customRefreshControlHeight,
                                                  customRefreshControlWidth,
                                                  customRefreshControlHeight);
    
    UIView<JBPullToRefreshView> *pullToRefreshView = [[self.pullToRefreshViewClass alloc] initWithFrame:customRefreshControlFrame];
    self.pullToRefreshView = pullToRefreshView;
    
    [self getPullToRefreshIvars];
    self.pullToRefreshViewRespondToPositionUpdated = [pullToRefreshView respondsToSelector:@selector(positionUpdated)];
    
    [self addSubview:pullToRefreshView];
    [self sendSubviewToBack:pullToRefreshView];
}

- (void)getPullToRefreshIvars
{
    // Finding the name of the synthesized JBPullToRefreshView Protocol ivars
    objc_property_t distanceFromTopProperty = class_getProperty(self.pullToRefreshViewClass, [@"distanceFromTop" UTF8String]);
    const char *distanceFromTopPropertyAttributes = property_getAttributes(distanceFromTopProperty);
    const char *distanceFromTopIvarName = [[[[NSString stringWithUTF8String:distanceFromTopPropertyAttributes] componentsSeparatedByString:@",V"] lastObject] UTF8String];
    
    objc_property_t percentShownProperty = class_getProperty(self.pullToRefreshViewClass, [@"percentShown" UTF8String]);
    const char *percentShownPropertyAttributes = property_getAttributes(percentShownProperty);
    const char *percentShownIvarName = [[[[NSString stringWithUTF8String:percentShownPropertyAttributes] componentsSeparatedByString:@",V"] lastObject] UTF8String];
    
    objc_property_t refreshingProperty = class_getProperty(self.pullToRefreshViewClass, [@"refreshing" UTF8String]);
    const char *refreshingPropertyAttributes = property_getAttributes(refreshingProperty);
    const char *refreshingIvarName = [[[[NSString stringWithUTF8String:refreshingPropertyAttributes] componentsSeparatedByString:@",V"] lastObject] UTF8String];
    
    unsigned int count;
    Ivar* ivars = class_copyIvarList([self.pullToRefreshView class], &count);
    for(int i = 0; i < count; i++) {
        Ivar ivar = ivars[i];
        const char *ivarName = ivar_getName(ivar);
        
        if (strcmp(distanceFromTopIvarName, ivarName) == 0) {
            CGFloat *ivarPointer = ((CGFloat *)((__bridge void *)self.pullToRefreshView + ivar_getOffset(ivar)));
            self.pullToRefreshViewDistanceFromTop = ivarPointer;
        }
        if (strcmp(percentShownIvarName, ivarName) == 0) {
            CGFloat *ivarPointer = ((CGFloat *)((__bridge void *)self.pullToRefreshView + ivar_getOffset(ivar)));
            self.pullToRefreshViewPercentShown = ivarPointer;
        }
        if (strcmp(refreshingIvarName, ivarName) == 0) {
            BOOL *ivarPointer = ((BOOL *)((__bridge void *)self.pullToRefreshView + ivar_getOffset(ivar)));
            self.pullToRefreshViewRefreshing = ivarPointer;
        }
    }
}

#pragma mark - Public

- (void)setAnimatingPullToRefresh:(BOOL)animatingPullToRefresh
{
    if (animatingPullToRefresh && !_animatingPullToRefresh) {
        *_pullToRefreshViewRefreshing = YES;
        [self.pullToRefreshView beginRefreshing];
    } else if (!animatingPullToRefresh && _animatingPullToRefresh) {
        *_pullToRefreshViewRefreshing = NO;
        [self.pullToRefreshView endRefreshing];
    }
    
    _animatingPullToRefresh = animatingPullToRefresh;
}

- (void)setAnimatingLoadMore:(BOOL)animatingLoadMore
{
    _animatingLoadMore = animatingLoadMore;
    
}

#pragma mark - UITableViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat distanceFromTop = 0.0;//-scrollView.contentOffset.y - scrollView.contentInset.top;
    if (_animatingPullToRefresh) {
        distanceFromTop = -scrollView.contentOffset.y - (scrollView.contentInset.top - CGRectGetHeight(_pullToRefreshView.bounds));
    } else {
        distanceFromTop = -scrollView.contentOffset.y - scrollView.contentInset.top;
    }
    *_pullToRefreshViewDistanceFromTop = distanceFromTop;
    
    CGFloat percentShown = (distanceFromTop + CGRectGetHeight(_pullToRefreshView.bounds)) / CGRectGetHeight(_pullToRefreshView.bounds);
    if (percentShown < 0.0) {
        percentShown = 0.0;
    } else if (percentShown > 1.0) {
        percentShown = 1.0;
    }
    *_pullToRefreshViewPercentShown = percentShown;

    if (_pullToRefreshViewRespondToPositionUpdated) {
        [_pullToRefreshView positionUpdated];
    }
    
    if (_publicDelegateRespondsToDidScroll) {
        [_publicDelegate scrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView.contentOffset.y <= -CGRectGetHeight(_pullToRefreshView.bounds) - scrollView.contentInset.top && !_animatingPullToRefresh) {
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
