//
//  JBAppDelegate.m
//  Example
//
//  Created by tehjord on 2014-09-04.
//  Copyright (c) 2014 Jordan Belanger. All rights reserved.
//

#import "AppDelegate.h"
#import "RedditViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    RedditViewController *redditVC = [[RedditViewController alloc] init];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:redditVC];
    
    [self.window makeKeyAndVisible];
    return YES;
}

@end
