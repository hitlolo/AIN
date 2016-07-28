//
//  AINBaseTableController.m
//  AIN
//
//  Created by Lolo on 16/5/26.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "AINBaseTableController.h"

@implementation AINBaseTableController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [self setBackgroundColor];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(updateThemeWhenNotificationReceived)
                                                name:mAINSettingManagerThemeChangeNotification
                                              object:nil];
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
    [self setBackgroundColor];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)setBackgroundColor{
    BOOL isNightOn = [[AINSettingManager sharedManager]isNightOn];
    if (isNightOn) {
        [self.tableView setBackgroundColor:tableBGColorNight];
    }
    else{
        [self.tableView setBackgroundColor:tableBGColorDay];
    }
}
@end
