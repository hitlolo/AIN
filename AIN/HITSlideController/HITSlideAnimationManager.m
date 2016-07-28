//
//  HITSlideAnimationManager.m
//  UIViewTest
//
//  Created by Lolo on 16/4/5.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "HITSlideAnimationManager.h"

@implementation HITSlideAnimationManager

+ (instancetype)manager{
    
    static HITSlideAnimationManager* _sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[HITSlideAnimationManager alloc]init];
    });
    return _sharedManager;
}


- (HITSlideAnimationBlock)getAnimationBlockWithType:(HITAnimationType)animationType{
    HITSlideAnimationBlock animationBlock = nil;
    switch (animationType) {
        case HITAnimationDefault:
            animationBlock = nil;
            break;
        case HITAnimationSlide:
            animationBlock = [self slideAnimation];
            break;
        case HITAnimationParallax:
            animationBlock = [self parallaxAnimationWithParallaxFactor:2.0f];
            break;
        case HITAnimationSlideAndScale:
            animationBlock = [self slideAndScaleAnimation];
            break;
        case HITAnimationSwingDoor:
            animationBlock = [self swingDoorAnimation];
            break;
        default:
            break;
    }
    
    return animationBlock;
    
}


- (HITSlideAnimationBlock)parallaxAnimationWithParallaxFactor:(CGFloat)parallaxFactor{
    
    HITSlideAnimationBlock animationBlock =
    ^(HITSlideController* slideController,HITSlide slideToAnimate, CGFloat percentVisible){
        CATransform3D transform = CATransform3DIdentity;
        UIViewController* viewControllerToAnimate = [slideController getViewControllerWithSlide:slideToAnimate];
        if (slideToAnimate == HITSlideLeft) {
            CGFloat distance = MAX(slideController.maximumLeftSlideWidth,slideController.visibleLeftSlideWidth);
            
            CGFloat translation_x = (-distance)/parallaxFactor + (distance * percentVisible) / parallaxFactor;
            transform = CATransform3DMakeTranslation(translation_x, 0.0f, 0.0f);
            
        }
        else if ( slideToAnimate == HITSlideRight ){
            CGFloat distance = MAX(slideController.maximumRightSlideWidth,slideController.visibleRightSlideWidth);
            
            CGFloat translation_x = (distance)/parallaxFactor - (distance * percentVisible) / parallaxFactor;
            transform = CATransform3DMakeTranslation(translation_x, 0.0f, 0.0f);
        }
        
        [viewControllerToAnimate.view.layer setTransform:transform];
    };
    return animationBlock;
}

- (HITSlideAnimationBlock)slideAnimation{
    
    return [self parallaxAnimationWithParallaxFactor:1.0f];
}

- (HITSlideAnimationBlock)slideAndScaleAnimation{
    
    HITSlideAnimationBlock animationBlock =
    ^(HITSlideController* slideController,HITSlide slideToAnimate, CGFloat percentVisible){
        CGFloat minScale = .90;
        CGFloat scale = minScale + (percentVisible*(1.0-minScale));
        CATransform3D scaleTransform =  CATransform3DMakeScale(scale, scale, scale);
        
        CGFloat maxDistance = 50;
        CGFloat distance = maxDistance * percentVisible;
        CATransform3D translateTransform = CATransform3DIdentity;
        UIViewController * viewControllerToAnimate = [slideController getViewControllerWithSlide:slideToAnimate];;
        if(slideToAnimate == HITSlideLeft) {
            translateTransform = CATransform3DMakeTranslation((maxDistance-distance), 0.0, 0.0);
        }
        else if(slideToAnimate == HITSlideRight){
            translateTransform = CATransform3DMakeTranslation(-(maxDistance-distance), 0.0, 0.0);
        }
        
        [viewControllerToAnimate.view.layer setTransform:CATransform3DConcat(scaleTransform, translateTransform)];
        [viewControllerToAnimate.view setAlpha:percentVisible];
    };
    return animationBlock;
}

- (HITSlideAnimationBlock)swingDoorAnimation{
    HITSlideAnimationBlock animationBlock =
    ^(HITSlideController* slideController,HITSlide slideToAnimate, CGFloat percentVisible){
        
        UIViewController * viewControllerToAnimate = [slideController getViewControllerWithSlide:slideToAnimate];
        CGPoint anchorPoint;
        CGFloat maxSlideWidth = 0.0f;
        CGFloat xOffset = 0.0f;
        CGFloat angle = 0.0f;
        
        if( slideToAnimate == HITSlideLeft ){
        
            anchorPoint =  CGPointMake(1.0, .5);
            maxSlideWidth = MAX(slideController.maximumLeftSlideWidth,slideController.visibleLeftSlideWidth);
            xOffset = -(maxSlideWidth / 2.0) + (maxSlideWidth) * percentVisible;
            angle = -M_PI_2+(percentVisible*M_PI_2);
        }
        else if( slideToAnimate == HITSlideRight ){
            
            anchorPoint = CGPointMake(0.0, .5);
            maxSlideWidth = MAX(slideController.maximumRightSlideWidth,slideController.visibleRightSlideWidth);
            xOffset = (maxSlideWidth / 2.0) - (maxSlideWidth) * percentVisible;
            angle = M_PI_2-(percentVisible*M_PI_2);
        }
        
        [viewControllerToAnimate.view.layer setAnchorPoint:anchorPoint];
        [viewControllerToAnimate.view.layer setShouldRasterize:YES];
        [viewControllerToAnimate.view.layer setRasterizationScale:[[UIScreen mainScreen] scale]];
        
        CATransform3D swingingDoorTransform = CATransform3DIdentity;
        if (percentVisible <= 1.f) {
            
            CATransform3D identity = CATransform3DIdentity;
            identity.m34 = -1.0/1000.0;
            CATransform3D rotateTransform = CATransform3DRotate(identity, angle, 0.0, 1.0, 0.0);
            
            CATransform3D translateTransform = CATransform3DMakeTranslation(xOffset, 0.0, 0.0);
            
            CATransform3D concatTransform = CATransform3DConcat(rotateTransform, translateTransform);
            
            swingingDoorTransform = concatTransform;
        }
        else{
            CATransform3D overshootTransform = CATransform3DMakeScale(percentVisible, 1.f, 1.f);
            
            NSInteger scalingModifier = 1.f;
            if (slideToAnimate == HITSlideRight) {
                scalingModifier = -1.f;
            }
            
            overshootTransform = CATransform3DTranslate(overshootTransform, scalingModifier*maxSlideWidth/2, 0.f, 0.f);
            swingingDoorTransform = overshootTransform;
        }
        
        [viewControllerToAnimate.view.layer setTransform:swingingDoorTransform];
    
    };
    return animationBlock;
}

@end
