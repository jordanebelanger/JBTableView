//
//  JBPullToRefresh.h
//  Redditerino
//
//  Created by tehjord on 2014-08-06.
//  Copyright (c) 2014 Jordan Belanger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JBTableView/JBPullToRefreshViewProtocol.h"

@interface BallsPullToRefreshView : UIView <JBPullToRefreshView>

@property (strong, nonatomic) UIColor *ballsColor;

@end
