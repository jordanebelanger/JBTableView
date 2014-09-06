//
//  JBAppDelegate.m
//  JBTableView Example
//
//  Created by tehjord on 2014-09-04.
//  Copyright (c) 2014 Jordan Belanger. All rights reserved.
//

#import "JBAppDelegate.h"
#import "JBRedditViewController.h"

@implementation JBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    JBRedditViewController *redditVC = [[JBRedditViewController alloc] init];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:redditVC];
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

@end
