//
//  AINRootControllerViewController.h
//  AIN
//
//  Created by Lolo on 16/5/26.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AINBaseController.h"

typedef NS_ENUM(NSInteger,AINTapSection) {
    TapGallery = 0,
    TapReading,
    TapFM,
    TapMovie
};

@interface AINRootController : AINBaseController
@property (strong, nonatomic,readonly,nonnull)UIPanGestureRecognizer* toolbarHiddenGesture;
@property (assign, nonatomic)BOOL hideCustomBarOnSwipe;
@property (assign, nonatomic)BOOL customToolbarHidden;

- (void)switchToTap:(AINTapSection)section;
@end


@interface UIViewController(AINRootController)
- (nullable AINRootController*)rootController;
@end