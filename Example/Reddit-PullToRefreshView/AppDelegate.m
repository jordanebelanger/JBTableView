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

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:17.0], NSFontAttributeName, nil] forState:UIControlStateNormal];
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    tabBarController.tabBar.tintColor = [UIColor whiteColor];
    tabBarController.tabBar.barTintColor = [UIColor colorWithRed:0.1 green:0.4 blue:0.7 alpha:1.0];

    RedditViewController *redditVCDefaultPullToRefresh = [[RedditViewController alloc] init];
    RedditViewController *redditVCCirclePullToRefresh = [[RedditViewController alloc] initWithPullToRefreshViewClass:[CirclePullToRefreshView class]];
    RedditViewController *redditVCBallsPullToRefresh = [[RedditViewController alloc] initWithPullToRefreshViewClass:[BallsPullToRefreshView class]];

    UINavigationController *defaultNavVC = [[UINavigationController alloc] initWithRootViewController:redditVCDefaultPullToRefresh];
    defaultNavVC.title = @"Default";
    UINavigationController *circleNavVC = [[UINavigationController alloc] initWithRootViewController:redditVCCirclePullToRefresh];
    circleNavVC.title = @"Circle";
    UINavigationController *ballsNavVC = [[UINavigationController alloc] initWithRootViewController:redditVCBallsPullToRefresh];
    ballsNavVC.title = @"Balls";
    
    tabBarController.viewControllers = @[
                                         defaultNavVC,
                                         circleNavVC,
                                         ballsNavVC
                                    ];
    
    defaultNavVC.tabBarItem.titlePositionAdjustment = UIOffsetMake(0.0, -13);
    circleNavVC.tabBarItem.titlePositionAdjustment = UIOffsetMake(0.0, -13);
    ballsNavVC.tabBarItem.titlePositionAdjustment = UIOffsetMake(0.0, -13);
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = tabBarController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
