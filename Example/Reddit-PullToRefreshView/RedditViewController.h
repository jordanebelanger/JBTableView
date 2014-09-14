//
//  JBRedditViewController.h
//  JBTableView Example
//
//  Created by tehjord on 2014-09-04.
//  Copyright (c) 2014 Jordane Belanger. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JBPullToRefreshView;

// This view controller shows the 25 latest links of the /r/all subreddit using a JBTableView
// using a variety of pullToRefreshView classes
//
@interface RedditViewController : UIViewController

- (instancetype)initWithPullToRefreshViewClass:(Class<JBPullToRefreshView>)pullToRefreshViewClass;

@end
