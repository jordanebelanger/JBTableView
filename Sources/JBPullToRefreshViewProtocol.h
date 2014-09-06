//
//  JBPullToRefreshViewProtocol.h
//  JBTableView Example
//
//  Created by tehjord on 2014-09-04.
//  Copyright (c) 2014 Jordan Belanger. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JBPullToRefreshView <NSObject>

// JBTableView will keep this set to the distance between the vertical top of your pullToRefreshView
// frame and the top of your JBTableView
//
// Examples
// 1: A distanceFromTop == 0 means your pull to refresh view is fully visible and aligned with the top of your JBTableView
// 2: A distanceFromTop < 0 means your pull to refresh view is currently hidden or partly hidden at the top of your JBTableView
// 3: A distanceFromTop > 0 means your pull to refresh view is fully visible with spacing between it and the top of your JBTableView
//@property (assign, nonatomic, readonly) CGFloat distanceFromTop;

// Percent of your pull to refresh view shown [0 .. 1.0], conveniance property directly related to
// the distanceFromTop property
//@property (assign, nonatomic, readonly) CGFloat percentShown;

// These are called by the tableView whenever it begins refreshing or end refreshing. You should
// begin and end your refreshing animation in these
- (void)beginRefreshing;
- (void)endRefreshing;

//@property (assign, nonatomic, readonly, getter = isRefreshing) BOOL refreshing;

// Must return the initial height of your pullToRefreshView
+ (CGFloat)defaultHeight;

@optional

- (void)refreshViewDistanceFromTableTop:(CGFloat)distancefromTop;
- (void)percentOfRefreshViewShown:(CGFloat)percentageShown;

@end
