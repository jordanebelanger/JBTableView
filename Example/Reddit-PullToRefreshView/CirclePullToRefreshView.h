//
//  CirclePullToRefreshView.h
//  JBTableView Example
//
//  Created by tehjord on 2014-09-07.
//  Copyright (c) 2014 Jordane Belanger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JBTableView/JBPullToRefreshViewProtocol.h"

// Gradually show a full circle as the pullToRequestView is pulled down.
// When this pullToRefreshView begins refreshing, a gradient colored circle is shown spinning
// instead of the normal full color circle (the CirclePercentView instance)
//
@interface CirclePullToRefreshView : UIView <JBPullToRefreshView>

@property (strong, nonatomic) UIColor *circleColor;
@property (assign, nonatomic) CGFloat circleWidth;

@end
