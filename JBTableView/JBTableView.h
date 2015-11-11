//
//  JBTableView.h
//  JBTableView
//
//  Created by tehjord on 2014-08-06.
//  Copyright (c) 2014 Jordane Belanger. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JBPullToRefreshView;
@protocol JBTableViewPullToRefreshViewDelegate;

@interface JBTableView : UITableView

- (instancetype)initWithPullToRefreshViewClass:(Class<JBPullToRefreshView>)pullToRefreshViewClass;
- (instancetype)initWithFrame:(CGRect)frame pullToRefreshViewClass:(Class<JBPullToRefreshView>)pullToRefreshViewClass;
- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style pullToRefreshViewClass:(Class<JBPullToRefreshView>)pullToRefreshViewClass;

// The class used when instantiating the pullToRefreshView, you can change it at anytime during your tableView's lifetime
// The pullToRefreshView class must be a UIView subclass comforming to the JBPullToRefreshView protocol
@property (assign, nonatomic) Class pullToRefreshViewClass;

@property (weak, nonatomic) id<JBTableViewPullToRefreshViewDelegate> pullToRefreshViewDelegate;

// This block is called when a pullToRefresh is triggered by the user
@property (copy, nonatomic) void (^pullToRefreshBlock)(void);

// default is 1000 Ms. Use to ensure your refresh animation is shown for a minimum amount of time even if your refresh cycle is very short
@property (assign, nonatomic) NSTimeInterval minimumRefreshTimeInMs;

// Shows your pullToRefreshView under the top of the table and starts the pullToRefreshView animation
- (void)startRefreshing;

// Hides the pullToRefreshView over the top of the table after which the pullToRefreshView animation will be stopped
- (void)stopRefreshing;

@property (assign, nonatomic, readonly, getter = isRefreshing) BOOL refreshing;

@end

@protocol JBTableViewPullToRefreshViewDelegate <NSObject>

// Use to set public properties on your pullToRefreshView before its subviews are initialized
- (void)JBTableView:(JBTableView *)tableView willSetupPullToRefreshView:(UIView<JBPullToRefreshView> *)pullToRefreshView;

@end
