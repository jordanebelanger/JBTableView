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

// default is 1 second. Use to ensure your refresh animation is shown for a minimum amount of time even if your refresh cycle is very short
@property (assign, nonatomic) NSTimeInterval minimumRefreshTime;

// Shows your pullToRefreshView under the top of the table and starts the pullToRefreshView animation
- (void)startRefreshing;

// Hides the pullToRefreshView over the top of the table after which the pullToRefreshView animation will be stopped
- (void)stopRefreshing;

// This property is TRUE after you call startRefreshing. This property becomes FALSE once stopRefreshing is called and the
// pullToRefreshView hiding animation has fully executed. There might be a delay between the time
// you call stopRefreshing and the time this property is FALSE depending on your tableView's minimumRefreshTime
@property (assign, nonatomic, readonly, getter = isRefreshing) BOOL refreshing;

@end

@protocol JBTableViewPullToRefreshViewDelegate <NSObject>

// Use to set public properties on your pullToRefreshView before its subviews are initialized
- (void)JBTableView:(JBTableView *)tableView willSetupPullToRefreshView:(UIView<JBPullToRefreshView> *)pullToRefreshView;

@end
