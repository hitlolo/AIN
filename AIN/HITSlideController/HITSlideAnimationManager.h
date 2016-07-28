//
//  HITSlideAnimationManager.h
//  UIViewTest
//
//  Created by Lolo on 16/4/5.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HITSlideController.h"

typedef void (^HITSlideAnimationBlock)(HITSlideController* slideController,HITSlide slideToAnimate, CGFloat percentVisible);

@interface HITSlideAnimationManager : NSObject

+ (instancetype)manager;

- (HITSlideAnimationBlock)getAnimationBlockWithType:(HITAnimationType)animationType;

@end
