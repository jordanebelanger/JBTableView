//
//  JBTableView.h
//  Redditerino
//
//  Created by tehjord on 2014-08-06.
//  Copyright (c) 2014 tehjord. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JBPullToRefreshView;

@interface JBTableView : UITableView

- (instancetype)initWithPullToRefreshViewClass:(Class<JBPullToRefreshView>)pullToRefreshViewClass;
- (instancetype)initWithFrame:(CGRect)frame pullToRefreshViewClass:(Class<JBPullToRefreshView>)pullToRefreshViewClass;

@property (assign, nonatomic, getter = isAnimatingPullToRefresh) BOOL animatingPullToRefresh;
@property (assign, nonatomic, getter = isAnimatingLoadMore) BOOL animatingLoadMore;

@property (copy, nonatomic) void (^pullToRefreshBlock)(void);

@end
