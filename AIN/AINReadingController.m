//
//  AINReadingController.m
//  AIN
//
//  Created by Lolo on 16/6/14.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "AINReadingController.h"
#import "AINRootController.h"
@implementation AINReadingController


- (void)viewDidLoad{
    [super viewDidLoad];

    self.view.backgroundColor = [[[AINSettingManager sharedManager]themeManager]backgroundColor];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(updateThemeWhenNotificationReceived)
                                                name:mAINSettingManagerThemeChangeNotification
                                              object:nil];

    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rootController setHideCustomBarOnSwipe:YES];
}


- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    
    BOOL isNightOn = [[AINSettingManager sharedManager]isNightOn];
    if (isNightOn) {
        return UIStatusBarStyleLightContent;
    }
    else
        return UIStatusBarStyleDefault;
}

- (void)updateThemeWhenNotificationReceived{
    BOOL isNightOn = [[AINSettingManager sharedManager]isNightOn];
    if (isNightOn) {
        
        self.segmentBackgroundColor = [UIColor darkGrayColor];
    }
    else{
        self.segmentBackgroundColor = [UIColor whiteColor];
    }
    self.view.backgroundColor = [[[AINSettingManager sharedManager]themeManager]backgroundColor];
    [self setNeedsStatusBarAppearanceUpdate];
    
}


@end
