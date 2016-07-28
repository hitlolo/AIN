//
//  AINTabBarController.m
//  AIN
//
//  Created by Lolo on 16/5/26.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "AINTabBarController.h"


@interface AINTabBarController ()
<UITabBarControllerDelegate>
@end

@implementation AINTabBarController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.tabBar.hidden = YES;
    self.delegate = self;
}


- (void)tabBarController:(UITabBarController *)tabBarController
 didSelectViewController:(UIViewController *)viewController{
    

    BOOL isAutoHideNaviBar = [[AINSettingManager sharedManager]barAutoHide];
    BOOL isNavigationController = [viewController isKindOfClass:[UINavigationController class]];
    if (isNavigationController) {
        
        UINavigationController* navigationController = ((UINavigationController*)viewController);
        [navigationController setHidesBarsOnSwipe:isAutoHideNaviBar];

    }
}


@end
