//
//  HITReadColumnEditorTransition.m
//  One
//
//  Created by Lolo on 16/5/14.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "HITReadColumnEditorTransition.h"

@implementation HITReadColumnEditorPresntationController

- (CGRect)frameOfPresentedViewInContainerView{
    // Return a rect with the same size as -sizeForChildContentContainer:withParentContainerSize:, and right aligned
    CGRect presentedViewFrame = CGRectZero;
    CGRect originRect = [self.fromView convertRect:self.fromView.bounds toView:[UIApplication sharedApplication].keyWindow];
    presentedViewFrame.origin = originRect.origin;
    CGFloat width = [[UIScreen mainScreen]bounds].size.width;
    CGFloat height = [[UIScreen mainScreen]bounds].size.height - originRect.origin.y;
    presentedViewFrame.size = CGSizeMake(width, height);
    
    return presentedViewFrame;
}

- (UIModalPresentationStyle)adaptivePresentationStyle
{
    // When we adapt to a compact width environment, we want to be over full screen
    return UIModalPresentationOverFullScreen;
}

- (BOOL)shouldPresentInFullscreen
{
    // This is a full screen presentation
    return YES;
}
@end



@implementation HITReadColumnEditorTransitionAnimator

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext{
    return 0.3f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext{
    // Here, we perform the animations necessary for the transition
    
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIView *fromView = [fromVC view];
    UIViewController *toVC   = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *toView = [toVC view];
    
    UIView *containerView = [transitionContext containerView];
    
    BOOL isPresentation = [self isPresentation];
    if(isPresentation){
        [containerView addSubview:toView];
    }
    
    UIViewController *animatingVC = isPresentation? toVC : fromVC;
    UIView *animatingView = [animatingVC view];
    
    CGRect appearedFrame = [transitionContext finalFrameForViewController:animatingVC];
    // Our dismissed frame is the same as our appeared frame, but off the right edge of the container
    CGRect dismissedFrame = appearedFrame;
    //dismissedFrame.origin.y += 44;
    dismissedFrame.size.height = 0;

    CGRect initialFrame = isPresentation ? dismissedFrame : appearedFrame;
    CGRect finalFrame = isPresentation ? appearedFrame : dismissedFrame;
    
    [animatingView setFrame:initialFrame];
    
    // Animate using the duration from -transitionDuration:
    //animatingView.translatesAutoresizingMaskIntoConstraints = YES;

    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                          delay:0
         usingSpringWithDamping:4.0
          initialSpringVelocity:5.0
                        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState |
                            UIViewAnimationOptionLayoutSubviews
                     animations:^{
                         [animatingView setFrame:finalFrame];
                         //[animatingView layoutIfNeeded];
                     }
                     completion:^(BOOL finished){
                         // If we're dismissing, remove the presented view from the hierarchy
                         //animatingView.translatesAutoresizingMaskIntoConstraints = NO;
                         if(![self isPresentation])
                         {
                             [fromView removeFromSuperview];
                         }
                         // We need to notify the view controller system that the transition has finished
                         [transitionContext completeTransition:YES];
                     }];
}


@end


@implementation HITReadColumnEditorTransition

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source{
    // Here, we'll provide the presentation controller to be used for the presentation
    return [[HITReadColumnEditorPresntationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
}



- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    HITReadColumnEditorTransitionAnimator *animationController = [[HITReadColumnEditorTransitionAnimator alloc]init];
    [animationController setIsPresentation:YES];
    
    return animationController;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    
    HITReadColumnEditorTransitionAnimator *animationController = [[HITReadColumnEditorTransitionAnimator alloc]init];
    [animationController setIsPresentation:NO];
    
    return animationController;
}

@end
