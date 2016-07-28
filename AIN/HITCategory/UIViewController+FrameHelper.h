//
//  UIViewController+FrameHelper.h
//  AIN
//
//  Created by Lolo on 16/5/25.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (FrameHelper)

@property (nonatomic,readonly) CGFloat statusBarHeight;
@property (nonatomic,readonly) CGFloat tabBarHeight;
@property (nonatomic,readonly) CGFloat navigationBarHeight;
@property (nonatomic,readonly) CGSize  screenSize;
@end
