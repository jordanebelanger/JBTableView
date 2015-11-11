//
//  JBRedditViewController.h
//  JBTableView Example
//
//  Created by tehjord on 2014-09-04.
//  Copyright (c) 2014 Jordane Belanger. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JBPullToRefreshView;

typedef void (^PullToRefreshViewCustomizationBlock)(UIView<JBPullToRefreshView> *pullToRefreshView);

@interface RedditViewController : UIViewController

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

- (instancetype)initWithDefaultColor:(UIColor *)color
              pullToRefreshViewClass:(Class<JBPullToRefreshView>)pullToRefreshViewClass
                                 subredditLink:(NSString *)subredditLink
               pullToRefreshCustomizationBlock:(PullToRefreshViewCustomizationBlock)customizationBlock;

@property (strong, nonatomic, readonly) NSString *subredditLink;

@end
