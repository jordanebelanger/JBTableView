//
//  JBPullToRefresh.h
//  JBTableView Example
//
//  Created by tehjord on 2014-08-06.
//  Copyright (c) 2014 Jordane Belanger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JBTableView/JBPullToRefreshViewProtocol.h"

@interface BallsPullToRefreshView : UIView <JBPullToRefreshView>

@property (strong, nonatomic) UIColor *ballsColor;

@end
