//
//  JBTableView.h
//  JBTableView
//
//  Created by tehjord on 2014-08-06.
//  Copyright (c) 2014 Jordan Belanger. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JBPullToRefreshView;
@protocol JBTableViewPullToRefreshViewDelegate;

@interface JBTableView : UITableView

- (instancetype)initWithPullToRefreshViewClass:(Class<JBPullToRefreshView>)pullToRefreshViewClass;
- (instancetype)initWithFrame:(CGRect)frame pullToRefreshViewClass:(Class<JBPullToRefreshView>)pullToRefreshViewClass;
- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style pullToRefreshViewClass:(Class<JBPullToRefreshView>)pullToRefreshViewClass;

@property (assign, nonatomic) Class pullToRefreshViewClass;
@property (weak, nonatomic) id<JBTableViewPullToRefreshViewDelegate> pullToRefreshViewDelegate;
@property (assign, nonatomic, readonly, getter = isRefreshing) BOOL refreshing;

- (void)startRefreshing;
- (void)stopRefreshing;

@property (copy, nonatomic) void (^pullToRefreshBlock)(void);

@end

@protocol JBTableViewPullToRefreshViewDelegate <NSObject>

// Should be used to set the public properties of your pullToRefreshView before its setup method is called by the JBTableView
- (void)JBTableView:(JBTableView *)tableView willSetupPullToRefreshView:(UIView<JBPullToRefreshView> *)pullToRefreshView;

@end
