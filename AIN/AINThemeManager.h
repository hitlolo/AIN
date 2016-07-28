//
//  AINThemeManager.h
//  AIN
//
//  Created by Lolo on 16/5/26.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import <Foundation/Foundation.h>
extern NSString*  const mAINSettingManagerThemeChangeNotification;
@interface AINThemeManager : NSObject

@property(nonatomic,strong)UIColor* tableBGColor;
@property(nonatomic,strong)UIColor* backgroundColor;
@property(nonatomic,strong)UIColor* fontColor;
@property(nonatomic,strong)UIColor* tintColor;

- (void)loadOnTheme:(BOOL)night;
@end
