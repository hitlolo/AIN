//
//  ONESerialContentListTransitionDelegate.m
//  One
//
//  Created by Lolo on 16/5/2.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "ONESerialContentListTransition.h"

// MARK: Presentation controller
@interface ONESerialContentListPresntationController ()
@property (nonatomic, strong)UIView* dimmingView;
@end

@implementation ONESerialContentListPresntationController

- (UIView*)dimmingView{
    if (_dimmingView == nil) {
        _dimmingView = [[UIView alloc]init];
        _dimmingView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.70f];
        _dimmingView.alpha = 0.0f;
        
        
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dimmingViewTapped:)];
        [_dimmingView addGestureRecognizer:tap];
    }
    return _dimmingView;
}

//- (UIVisualEffectView*)dimmingView{
//    if (_dimmingView == nil) {
//
//        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
//        _dimmingView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
//    
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dimmingViewTapped:)];
//        [_dimmingView addGestureRecognizer:tap];
//    }
//    return _dimmingView;
//}



- (void)dimmingViewTapped:(UIGestureRecognizer *)gesture{
    
    if([gesture state] == UIGestureRecognizerStateRecognized)
    {
        [[self presentingViewController] dismissViewControllerAnimated:YES completion:NULL];
    }

}

- (void)containerViewWillLayoutSubviews{
    // Before layout, make sure our dimmingView and presentedView have the correct frame
    [[self dimmingView] setFrame:[[self containerView] bounds]];
    [[self presentedView] setFrame:[self frameOfPresentedViewInContainerView]];
}

- (CGRect)frameOfPresentedViewInContainerView{
    // Return a rect with the same size as -sizeForChildContentContainer:withParentContainerSize:, and right aligned
    CGRect presentedViewFrame = CGRectZero;
    //CGRect containerBounds = [[self containerView] bounds];
    
    presentedViewFrame.size = [self.presentedViewController preferredContentSize];
    presentedViewFrame.origin.x = 0;
    presentedViewFrame.origin.y = 0;
    
    return presentedViewFrame;
}

- (void)presentationTransitionWillBegin{
    // Here, we'll set ourselves up for the presentation
    
    UIView* containerView = [self containerView];
    UIViewController* presentedViewController = [self presentedViewController];
    
    // Make sure the dimming view is the size of the container's bounds, and fully transparent
    
    [[self dimmingView] setFrame:[containerView bounds]];
    [[self dimmingView] setAlpha:0.0];
    
    // Insert the dimming view below everything else
    
    [containerView insertSubview:[self dimmingView] atIndex:0];
    
    if([presentedViewController transitionCoordinator])
    {
        [[presentedViewController transitionCoordinator] animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
            
            // Fade the dimming view to be fully visible
            
            [[self dimmingView] setAlpha:1.0];
        } completion:nil];
    }
    else
    {
        [[self dimmingView] setAlpha:1.0];
    }
}

- (void)dismissalTransitionWillBegin{
    // Here, we'll undo what we did in -presentationTransitionWillBegin. Fade the dimming view to be fully transparent
    
    if([[self presentedViewController] transitionCoordinator])
    {
        [[[self presentedViewController] transitionCoordinator] animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
            [[self dimmingView] setAlpha:0.0];
        } completion:nil];
    }
    else
    {
        [[self dimmingView] setAlpha:0.0];
    }
}

- (void)dismissalTransitionDidEnd:(BOOL)completed{
    if (completed) {
        [[self dimmingView]removeFromSuperview];
    }
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



// MARK: Transition Animated

@implementation ONESerialContentListAnimatedTransitionning

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
    dismissedFrame.origin.x -= dismissedFrame.size.width;
    
    CGRect initialFrame = isPresentation ? dismissedFrame : appearedFrame;
    CGRect finalFrame = isPresentation ? appearedFrame : dismissedFrame;
    
    [animatingView setFrame:initialFrame];
    
    // Animate using the duration from -transitionDuration:
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                          delay:0
         usingSpringWithDamping:300.0
          initialSpringVelocity:5.0
                        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [animatingView setFrame:finalFrame];
                     }
                     completion:^(BOOL finished){
                         // If we're dismissing, remove the presented view from the hierarchy
                         
                         if(![self isPresentation])
                         {
                             [fromView removeFromSuperview];
                         }
                         // We need to notify the view controller system that the transition has finished
                         [transitionContext completeTransition:YES];
                     }];
}



@end

// MARK: Transition Delegate

@implementation ONESerialContentListTransitionDelegate

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source{
    // Here, we'll provide the presentation controller to be used for the presentation
    return [[ONESerialContentListPresntationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
}



- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    ONESerialContentListAnimatedTransitionning *animationController = [[ONESerialContentListAnimatedTransitionning alloc]init];
    [animationController setIsPresentation:YES];
    
    return animationController;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    
    ONESerialContentListAnimatedTransitionning *animationController = [[ONESerialContentListAnimatedTransitionning alloc]init];
    [animationController setIsPresentation:NO];
    
    return animationController;
}

@end
