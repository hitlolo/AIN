//
//  AINSettingManager.h
//  AIN
//
//  Created by Lolo on 16/5/26.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AINThemeManager.h"

extern NSString*  const mAINSettingManagerAutoHideBarChangeNotification;
extern NSString*  const mAINSettingManagerReadModeChangeNotification;

typedef NS_ENUM(NSInteger,AINFontSize){
    AINFontSmall,
    AINFontNormal,
    AINFontBig
};

@interface AINSettingManager : NSObject

@property(nonatomic,strong)AINThemeManager* themeManager;
@property(nonatomic,assign,getter=isNightOn)BOOL nightMode;
@property(nonatomic,assign)BOOL nightAutoChange;
@property(nonatomic,assign)BOOL barAutoHide;
@property(nonatomic,assign)BOOL readInPageMode;
@property(nonatomic,assign)AINFontSize fontSize;
@property(nonatomic,assign,readonly)CGFloat cachedSize;


+ (instancetype)sharedManager;
- (void)themeLoadOn;
@end
