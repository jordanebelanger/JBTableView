//
//  JBPullToRefreshViewProtocol.h
//  JBTableView
//
//  Created by tehjord on 2014-09-04.
//  Copyright (c) 2014 Jordan Belanger. All rights reserved.
//

#import <Foundation/Foundation.h>

// Use this protocol to create your own pullToRefreshView to be used in a JBTableView.
// The protocol's methods are called at various time during your pullToRefreshView lifetime and should be used to
// create your pullToRefreshView subviews, start and end an animation when the JBTableView is refreshing and modify the
// the pullToRefreshView as it is gradually shown on screen (a UILabel's text change from "pull" to "release" etc)
//
@protocol JBPullToRefreshView <NSObject>

// JBTableView will call this method after initializing your JBPullToRefreshView, use it to add subviews to your pullToRefreshView.
// The frame property of your pullToRefreshView is at its final size by the time this method is called
// self.frame.width = tableView.frame.width and self.frame.height = your class' + (CGFloat)defaultHeight method result
// You can use the "willSetupPullToRefreshView" method of JBTableView's JBPullToRefreshViewDelegate to set public properties on your pullToRefreshView before this method is called
- (void)setup;

// This is called by the JBTableView when it begins or end refreshing its pullToRefreshView. You should implement
// these to start and stop your refresh animation.
- (void)beginRefreshing;
- (void)endRefreshing;

// Must return the initial height of your pullToRefreshView.
+ (CGFloat)defaultHeight;

@optional

// This method will be called by the JBTableView everytime the pullToRefreshView moves up or down in your tableView.
// The percentShown parameter is the percent of your JBPullToRefreshView currently being shown.
// Use this to modify your pullToRefreshView as it becomes visible on screen, for example,
// by changing a UILabel's text from "pull" to "release when percent shown is 1.0, etc.
//
// TIPS:
// 1: A percentShown == 0.0 means your pullToRefreshView is entirely hidden at the top of your tableView
// 2: A percentShown ]0.0 , 1.0[ means your pullToRefreshView is partly visible
// 3: A percentShown == 1.0 means your pullToRefreshView is entirely visible
- (void)percentOfRefreshViewShown:(CGFloat)percentShown;

// Similar to percentOfRefreshViewShown, this method will be called by the JBTableView everytime the pullToRefreshView moves up or down in your tableView.
// The distanceFromTop parameter is the distance between the top of your pullToRefreshView and the
// top of your UITableView. Use this to modify your pullToRefreshView as it becomes visible on screen.
//
// TIPS:
// 1: A distanceFromTop == 0 means your pullToRefreshView is fully visible and flush with the top of your tableView
// 2: A distanceFromTop < 0 means your pullToRefreshView is currently hidden or partly hidden behind the top of your JBTableView.
// 3: A distanceFromTop > 0 means your pullToRefreshView is fully visible with space to spare between it and the top of your JBTableView.
- (void)refreshViewDistanceFromTableTop:(CGFloat)distancefromTop;

@end
