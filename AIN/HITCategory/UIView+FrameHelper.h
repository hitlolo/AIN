//
//  UIView+Helper.h
//  HITRefreshView
//
//  Created by Lolo on 15/12/6.
//  Copyright © 2015年 Lolo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (FrameHelper)

@property (nonatomic) CGSize  size;
@property (nonatomic) CGPoint origin;
@property (nonatomic,readonly) CGPoint bottomLeft;
@property (nonatomic,readonly) CGPoint bottomRight;
@property (nonatomic,readonly) CGPoint topRight;
@property (nonatomic) CGFloat height;
@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat top;
@property (nonatomic) CGFloat left;
@property (nonatomic) CGFloat bottom;
@property (nonatomic) CGFloat right;
@property (nonatomic) CGFloat x;
@property (nonatomic) CGFloat y;
@property (nonatomic) CGPoint screenCenter;
@property (nonatomic,readonly)CGFloat screenWidth;
@property (nonatomic,readonly)CGFloat screenHeight;



- (void) moveBy: (CGPoint) delta;
- (void) scaleBy: (CGFloat) scaleFactor;
- (void) fitInSize: (CGSize) aSize;


@end

CGPoint CGRectGetCenter(CGRect rect);
CGRect  CGRectMoveToCenter(CGRect rect, CGPoint center);