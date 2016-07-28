//
//  AINSettingManager.m
//  AIN
//
//  Created by Lolo on 16/5/26.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "AINSettingManager.h"
#import "AINDBManager.h"
#import <SDImageCache.h>

static NSString* const kThemeKey = @"theme";
static NSString* const kAutoThemeChangeKey = @"autoChangeTheme";
static NSString* const kAutoHideBarsKey = @"autoHideBars";
static NSString* const kFontSizeKey = @"fontSize";
static NSString* const kReadInPageMode = @"readInPage";

NSString* const mAINSettingManagerAutoHideBarChangeNotification = @"mAINSettingManagerAutoHideBarChangeNotification";
NSString* const mAINSettingManagerReadModeChangeNotification = @"mAINSettingManagerReadModeChangeNotification";

@implementation AINSettingManager{
    NSUserDefaults* userDefaults;
}

@synthesize nightMode = _nightMode;
@synthesize nightAutoChange = _nightAutoChange;
@synthesize barAutoHide = _barAutoHide;
@synthesize fontSize = _fontSize;
@synthesize readInPageMode = _readInPageMode;

+ (instancetype)sharedManager{
    static AINSettingManager* _manager = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        _manager = [[AINSettingManager alloc]init];
    });
    return _manager;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        [self prepare];
    }
    return self;
}

- (void)prepare{
    userDefaults = [NSUserDefaults standardUserDefaults];
    _themeManager = [[AINThemeManager alloc]init];
    [self prepareDefaultsSetting];
    [self prepareUserSetting];
    
}

- (void)prepareDefaultsSetting{
    
    NSDictionary* defaults = @{kThemeKey:@NO,
                               kAutoThemeChangeKey:@NO,
                               kAutoHideBarsKey:@NO,
                               kReadInPageMode:@NO,
                               kFontSizeKey:@(AINFontNormal)};
    
    [userDefaults registerDefaults:defaults];
}

- (void)prepareUserSetting{
 
    _nightMode = [userDefaults boolForKey:kThemeKey];
    _nightAutoChange = [userDefaults boolForKey:kAutoThemeChangeKey];
    _barAutoHide = [userDefaults boolForKey:kAutoHideBarsKey];
    _readInPageMode = [userDefaults boolForKey:kReadInPageMode];
    _fontSize = [userDefaults integerForKey:kFontSizeKey];
}

- (void)themeLoadOn{
    [_themeManager loadOnTheme:_nightMode];
}

#pragma mark - Setter & Getter

- (BOOL)isNightOn{
    return _nightMode;
}

- (void)setNightMode:(BOOL)nightMode{
    if (_nightMode == nightMode) {
        return;
    }
    _nightMode = nightMode;
    [userDefaults setBool:nightMode forKey:kThemeKey];
    [_themeManager loadOnTheme:nightMode];

}

- (BOOL)nightAutoChange{
    return _nightAutoChange;
}

- (void)setNightAutoChange:(BOOL)nightAutoChange{
    if (_nightAutoChange == nightAutoChange) {
        return;
    }
    _nightAutoChange = nightAutoChange;
    [userDefaults setBool:nightAutoChange forKey:kAutoThemeChangeKey];
}

- (BOOL)barAutoHide{
    return _barAutoHide;
}

- (void)setBarAutoHide:(BOOL)barAutoHide{
    if (_barAutoHide == barAutoHide) {
        return;
    }
    _barAutoHide = barAutoHide;
    [userDefaults setBool:barAutoHide forKey:kAutoHideBarsKey];
    [[NSNotificationCenter defaultCenter]postNotificationName:mAINSettingManagerAutoHideBarChangeNotification
                                                       object:self];
}

- (BOOL)readInPageMode{
    return _readInPageMode;
}

- (void)setReadInPageMode:(BOOL)readInPageMode{
    if (_readInPageMode == readInPageMode) {
        return;
    }
    _readInPageMode = readInPageMode;
    [userDefaults setBool:readInPageMode forKey:kReadInPageMode];
    [[NSNotificationCenter defaultCenter]postNotificationName:mAINSettingManagerReadModeChangeNotification
                                                       object:self];
}

- (AINFontSize)fontSize{
    return _fontSize;
}

- (void)setFontSize:(AINFontSize)fontSize{
    if (_fontSize == fontSize) {
        return;
    }
    _fontSize = fontSize;
    [userDefaults setInteger:fontSize forKey:kFontSizeKey];
}

- (CGFloat)cachedSize{
    
    CGFloat databaseSize = [[AINDBManager sharedManager]databaseSize];
    NSUInteger imageSize = [[SDImageCache sharedImageCache]getSize];
    CGFloat cacchedSize = databaseSize + imageSize/1024/1024;
    return cacchedSize;
}

@end
