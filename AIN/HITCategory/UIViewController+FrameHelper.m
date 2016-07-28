//
//  UIViewController+FrameHelper.m
//  AIN
//
//  Created by Lolo on 16/5/25.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "UIViewController+FrameHelper.h"

@implementation UIViewController (FrameHelper)

- (CGFloat)statusBarHeight{
    return [[UIApplication sharedApplication]statusBarFrame].size.height;
}

- (CGFloat)tabBarHeight{
    return self.tabBarController.tabBar.frame.size.height;
}

- (CGFloat)navigationBarHeight{
    return self.navigationController.navigationBar.frame.size.height;
}

- (CGSize)screenSize{
    CGSize size = [[UIScreen mainScreen]bounds].size;
    return size;
}
@end
