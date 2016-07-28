//
//  HITTableRevealTransition.m
//  AIN
//
//  Created by Lolo on 16/5/27.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "HITTableRevealTransition.h"

#pragma mark - presentation controller

@interface HITTableRevealPresentationController ()
@property(nonatomic,strong)UIView* dimmingView;
@end

@implementation HITTableRevealPresentationController

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

- (void)dimmingViewTapped:(UIGestureRecognizer*)gesture{
    
    if([gesture state] == UIGestureRecognizerStateRecognized){
        [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
    }
    
}


- (CGRect)frameOfPresentedViewInContainerView{
    CGRect frame = CGRectZero;
    CGSize size = [self.presentedViewController preferredContentSize];
    CGPoint origin = CGPointMake(0, 0);
    origin.y = [UIScreen mainScreen].height - size.height;
    frame.origin = origin;
    frame.size = size;

    return frame;
}



- (void)containerViewWillLayoutSubviews{
    // Before layout, make sure our dimmingView and presentedView have the correct frame
    [[self presentedView] setFrame:[self frameOfPresentedViewInContainerView]];
}

- (void)presentationTransitionWillBegin{
    // Here, we'll set ourselves up for the presentation
    
    UIView* containerView = [self containerView];
    UIViewController* presentedViewController = [self presentedViewController];
    
    // Make sure the dimming view is the size of the container's bounds, and fully transparent
    [[self dimmingView] setFrame:[containerView bounds]];
    [[self dimmingView] setAlpha:0.0];
    
    // Insert the dimming view below everything else
    [containerView addSubview:_dimmingView];

    
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

//- (void)presentationTransitionDidEnd:(BOOL)completed{
//    if (completed) {
//
//    }
//}

- (void)dismissalTransitionWillBegin{
    // Here, we'll undo what we did in -presentationTransitionWillBegin. Fade the dimming view to be fully transparent
    
    
    if([[self presentedViewController] transitionCoordinator]){
        
        [[[self presentedViewController] transitionCoordinator] animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {

            [[self dimmingView] setAlpha:0.0];
        } completion:nil];
    }
    else{
        [[self dimmingView] setAlpha:0.0];
    }
}

- (void)dismissalTransitionDidEnd:(BOOL)completed{
    if (completed) {
        [[self dimmingView]removeFromSuperview];
    }
}

- (UIModalPresentationStyle)adaptivePresentationStyle{
    // When we adapt to a compact width environment, we want to be over full screen
    return UIModalPresentationOverFullScreen;
}

- (BOOL)shouldPresentInFullscreen{
    // This is a full screen presentation
    return YES;
}

@end


#pragma mark - animtor in & out

@implementation HITTableRevealTransitionAnimator

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    return 0.7f;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    
    UIViewController* toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView* toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    
    UIView* fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    
    UIView* animateView = nil;
    CGRect toFrame = [transitionContext finalFrameForViewController:toVC];
    CGRect fromFrame = CGRectMake(0, toVC.screenSize.height, toFrame.size.width, toFrame.size.height);
    
    CGRect initialFrame = CGRectZero;
    CGRect finalFrame = CGRectZero;
    CGFloat initialAlpha = 0.0f;
    CGFloat finalAlpha = 1.0f;
    
    if (self.isPresentation) {
        animateView = toView;
        [[transitionContext containerView]addSubview:toView];
        initialFrame = fromFrame;
        finalFrame = toFrame;
        initialAlpha = 0.0f;
        finalAlpha = 1.0f;
    }
    else{
        animateView = fromView;
        
        initialFrame = toFrame;
        finalFrame = fromFrame;
        
        initialAlpha = 1.0f;
        finalAlpha = 0.0f;
    }
    
    if (self.isPresentation) {
        animateView.frame = initialFrame;
    }
    animateView.alpha = initialAlpha;
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                          delay:0
         usingSpringWithDamping:20
          initialSpringVelocity:4.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                       
                         animateView.alpha = finalAlpha;
                         animateView.frame = finalFrame;
                         
                     }
                     completion:^(BOOL finished){
                         // If we're dismissing, remove the presented view from the hierarchy
                         // We need to notify the view controller system that the transition has finished
                         animateView.alpha = 1.0f;
                         BOOL cancelled = [transitionContext transitionWasCancelled];
                         //in but cancelled
                         if (self.isPresentation && cancelled) {
                             [animateView removeFromSuperview];
                         }
                         //out and finished
                         else if (!self.isPresentation && finished && !cancelled) {
                             [animateView removeFromSuperview];
                         }
                         [transitionContext completeTransition:!cancelled];
                     }];
    

    
}
@end


#pragma mark - interactive in

@interface HITTableRevealTransitionInteractive ()
@property(nonatomic,weak)id<UIViewControllerContextTransitioning> transitionContext;
@property(nonatomic,assign)CGSize fromViewSize;
@end

@implementation HITTableRevealTransitionInteractive

- (void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    // Always call super first.
    [super startInteractiveTransition:transitionContext];
    
    // Save the transition context for future reference.
    self.transitionContext = transitionContext;
    self.fromViewSize = [transitionContext viewForKey:UITransitionContextFromViewKey].size;
    
}

- (void)reavealTrasitionWillBegin{
    _active = YES;
    
}

- (void)reavealTransitionUpdateProgress:(CGFloat)progress{
    [self updateInteractiveTransition:progress/2];
    _active = YES;
}

- (void)reavealTrasitionDidEndAtProgress:(CGFloat)progress{
    
    if (_active == NO) {
        return;
    }

    if (progress < 0.5) {
        //self.completionSpeed = 0.3;
        //[self updateInteractiveTransition:0];
        
        [self cancelInteractiveTransition];
  
        
    }
    else{
        //self.completionSpeed = 0.6;

        [self finishInteractiveTransition];

    }
    
    _active = NO;
}

@end


#pragma mark - transition delegate object

@interface HITTableRevealTransition ()

@end

@implementation HITTableRevealTransition

- (instancetype)init{
    self = [super init];
    if (self) {
        _inInteractive = [[HITTableRevealTransitionInteractive alloc]init];
    }
    return self;
}

- (UIPresentationController*)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source{
    HITTableRevealPresentationController* presentation = [[HITTableRevealPresentationController alloc]initWithPresentedViewController:presented presentingViewController:presenting];
    return presentation;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    
    HITTableRevealTransitionAnimator* animtor = [[HITTableRevealTransitionAnimator alloc]init];
    animtor.isPresentation = YES;
    return animtor;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    HITTableRevealTransitionAnimator* animator = [[HITTableRevealTransitionAnimator alloc]init];
    animator.isPresentation = NO;
    return animator;
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id<UIViewControllerAnimatedTransitioning>)animator{
    return _inInteractive.active?_inInteractive:nil;
//    return nil;
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator{
    return nil;
}


@end
