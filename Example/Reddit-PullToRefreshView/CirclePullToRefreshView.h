//
//  JBCircleSpinnerPullToRefreshView.h
//  JBTableView Example
//
//  Created by tehjord on 2014-09-07.
//  Copyright (c) 2014 Jordan Belanger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JBTableView/JBPullToRefreshViewProtocol.h"

@interface CirclePullToRefreshView : UIView <JBPullToRefreshView>

@property (strong, nonatomic) UIColor *circleColor;

@end
