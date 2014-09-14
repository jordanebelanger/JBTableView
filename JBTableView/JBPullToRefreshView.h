//
//  JBPullToRefreshView.h
//  JBTableView
//
//  Created by tehjord on 2014-09-04.
//  Copyright (c) 2014 Jordane Belanger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JBPullToRefreshViewProtocol.h"

// This is the default UIView used by the JBTableView for its pullToRefreshView, use it as a guideline to
// implement your own. You do not have to subclass this class to create your own custom pullToRefreshView.
// It is strongly recommended that you create a UIView subclass and implements the JBPullToRefreshView protocol instead of subclassing JBPullToRefreshView
//
@interface JBPullToRefreshView : UIView <JBPullToRefreshView>

@property (strong, nonatomic) UIColor *activityIndicatorColor;

@end
