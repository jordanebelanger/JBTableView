//
//  JBAppDelegate.m
//  Example
//
//  Created by tehjord on 2014-09-04.
//  Copyright (c) 2014 Jordane Belanger. All rights reserved.
//

#import "AppDelegate.h"
#import "RedditViewController.h"
#import "CirclePullToRefreshView.h"
#import "BallsPullToRefreshView.h"
#import "JBTableView/JBPullToRefreshView.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:17.0], NSFontAttributeName, nil] forState:UIControlStateNormal];

    UIColor *lightBlueColor = [UIColor colorWithRed:95./255. green:217./255. blue:239./.255 alpha:1.0];
    UIColor *lightOrangeColor = [UIColor colorWithRed:253./255. green:146./255. blue:27./255. alpha:1.0];
    UIColor *lightGreenColor = [UIColor colorWithRed:166./255. green:226./255. blue:46./255. alpha:1.0];
    
    RedditViewController *redditAllVC = [[RedditViewController alloc] initWithDefaultColor:lightBlueColor
                                                                    pullToRefreshViewClass:[JBPullToRefreshView class]
                                                                             subredditLink:@"/r/all"
                                                           pullToRefreshCustomizationBlock:^(UIView<JBPullToRefreshView> *pullToRefreshView) {
                                                               [(JBPullToRefreshView *)pullToRefreshView setActivityIndicatorColor:lightBlueColor.copy];
    }];
    
    
    RedditViewController *redditPoliticsVC = [[RedditViewController alloc] initWithDefaultColor:lightOrangeColor
                                                                    pullToRefreshViewClass:[CirclePullToRefreshView class]
                                                                             subredditLink:@"/r/politics"
                                                           pullToRefreshCustomizationBlock:^(UIView<JBPullToRefreshView> *pullToRefreshView) {
                                                               [(CirclePullToRefreshView *)pullToRefreshView setCircleColor:lightOrangeColor];
    }];
    
    
    RedditViewController *redditLolVC = [[RedditViewController alloc] initWithDefaultColor:lightGreenColor
                                                                                   pullToRefreshViewClass:[BallsPullToRefreshView class]
                                                                                            subredditLink:@"/r/leagueoflegends"
                                                                          pullToRefreshCustomizationBlock:^(UIView<JBPullToRefreshView> *pullToRefreshView) {
                                                                              [(BallsPullToRefreshView *)pullToRefreshView setBallsColor:lightGreenColor];
    }];

    UINavigationController *defaultNavVC = [[UINavigationController alloc] initWithRootViewController:redditAllVC];
    defaultNavVC.title = @"Default";
    UINavigationController *circleNavVC = [[UINavigationController alloc] initWithRootViewController:redditLolVC];
    circleNavVC.title = @"Circle";
    UINavigationController *ballsNavVC = [[UINavigationController alloc] initWithRootViewController:redditPoliticsVC];
    ballsNavVC.title = @"Balls";
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    tabBarController.tabBar.tintColor = [UIColor whiteColor];
    tabBarController.viewControllers = @[
        defaultNavVC,
        circleNavVC,
        ballsNavVC
    ];
    
    defaultNavVC.tabBarItem.titlePositionAdjustment = UIOffsetMake(0.0, -13.);
    circleNavVC.tabBarItem.titlePositionAdjustment = UIOffsetMake(0.0, -13.);
    ballsNavVC.tabBarItem.titlePositionAdjustment = UIOffsetMake(0.0, -13.);
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = tabBarController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
