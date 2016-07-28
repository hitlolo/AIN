//
//  HITImageControllerTransition.m
//  AIN
//
//  Created by Lolo on 16/6/3.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "HITImageControllerTransition.h"
#import "HITImageController.h"

@implementation HITImageControllerTransition

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    return [[HITImageControllerAnimatorIn alloc]init];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    return [[HITImageControllerAnimatorOut alloc]init];
}
@end


@implementation HITImageControllerAnimatorIn

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    return 0.3f;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    
    UIViewController* toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView* toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIView *containerView = [transitionContext containerView];
    CGRect toViewFinalFrame = [transitionContext finalFrameForViewController:toVC];
    
    HITImageController* imageController = (HITImageController*)toVC;
    NSInteger index = [imageController currentIndex];
    CGRect toViewInitialFrame = [imageController.dataSource imageController:imageController originalFrameOfImageAtIndex:index];
    
    [containerView addSubview:toView];
    
    [toView setFrame:toViewInitialFrame];
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                          delay:0
         usingSpringWithDamping:20
          initialSpringVelocity:4.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [toView setFrame: toViewFinalFrame];

                     }
                     completion:^(BOOL finished){
                         // If we're dismissing, remove the presented view from the hierarchy
                         // We need to notify the view controller system that the transition has finished
                         [transitionContext completeTransition:YES];
    }];
    
}
@end

@implementation HITImageControllerAnimatorOut

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    return 0.3f;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    
    UIViewController* fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIView* fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    //UIView *containerView = [transitionContext containerView];
    CGRect fromViewinitialFrame = [transitionContext initialFrameForViewController:fromVC];
    
    HITImageController* imageController = (HITImageController*)fromVC;
    NSInteger index = [imageController currentIndex];
    CGRect fromViewfinalFrame = [imageController.dataSource imageController:imageController originalFrameOfImageAtIndex:index];
    [fromView setFrame:fromViewinitialFrame];
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                          delay:0
         usingSpringWithDamping:20
          initialSpringVelocity:4.0
                        options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionLayoutSubviews
                     animations:^{
                         [fromView setFrame: fromViewfinalFrame];
                         
                     }
                     completion:^(BOOL finished){
                         // If we're dismissing, remove the presented view from the hierarchy
                         // We need to notify the view controller system that the transition has finished
                         [fromView removeFromSuperview];
                         [transitionContext completeTransition:YES];

                     }];
}

@end