
//
//  AINTopdownTransition.m
//  AIN
//
//  Created by Lolo on 16/5/23.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "AINTopdownTransition.h"




static const NSInteger maskTag = 1001;
static const NSInteger dimmedTag = 1002;

#pragma mark - Presentation controller

@interface AINTopdownPresatationController ()<AINTopdownTransitionDelegate>
@property (nonatomic, strong)UIView* dimmingView;
@end

@implementation AINTopdownPresatationController

- (UIView*)dimmingView{
    if (_dimmingView == nil) {
        _dimmingView = [[UIView alloc]init];
        _dimmingView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.50f];
        _dimmingView.alpha = 0.0f;
        _dimmingView.tag = dimmedTag;
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


- (void)interactiveTransitionDelegateDidBinded:(UIGestureRecognizer *)gesture{
    [self.dimmingView addGestureRecognizer:gesture];
}

- (void)interactiveTransitionWillBegin{
     [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (CGRect)frameOfPresentedViewInContainerView{
    // Return a rect with the same size as -sizeForChildContentContainer:withParentContainerSize:, and right aligned
    CGRect presentedViewFrame = CGRectZero;
    CGSize preferredSize = [self.presentedViewController preferredContentSize];
    presentedViewFrame.size = preferredSize;
    return presentedViewFrame;
}


- (void)containerViewWillLayoutSubviews{
    // Before layout, make sure our dimmingView and presentedView have the correct frame
    [[self presentedView] setFrame:[self frameOfPresentedViewInContainerView]];
}

- (void)presentationTransitionWillBegin{
    // Here, we'll set ourselves up for the presentation
    
    UIView* containerView = [self containerView];
    UIViewController* presentedViewController = [self presentedViewController];
    UIViewController* presentingViewController = [self presentingViewController];
    
    UIView* maskView = [presentingViewController.view snapshotViewAfterScreenUpdates:NO];
    [maskView setTag:maskTag];
    // Make sure the dimming view is the size of the container's bounds, and fully transparent
    [[self dimmingView] setFrame:[containerView bounds]];
    [[self dimmingView] setAlpha:0.0];
    
    // Insert the dimming view below everything else
    [containerView addSubview:maskView];
    [containerView addSubview:_dimmingView];
    CGRect dimmingViewToFrame = [self frameOfPresentedViewInContainerView];
    dimmingViewToFrame.origin = CGPointMake(0, dimmingViewToFrame.size.height);
    dimmingViewToFrame.size = CGSizeMake(dimmingViewToFrame.size.width, self.containerView.height - dimmingViewToFrame.size.height);
    
    if([presentedViewController transitionCoordinator])
    {
        [[presentedViewController transitionCoordinator] animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
            
            // Fade the dimming view to be fully visible
            [[self dimmingView] setFrame:dimmingViewToFrame];
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
    
    UIViewController* presentingViewController = [self presentingViewController];
    UIView* maskView = [presentingViewController.view snapshotViewAfterScreenUpdates:NO];
    [maskView setTag:maskTag];
    
    UIView* oldMask = [[self containerView]viewWithTag:maskTag];
    [maskView setFrame:oldMask.frame];
    [oldMask removeFromSuperview];
    
    [self.containerView insertSubview:maskView belowSubview:_dimmingView];
    
    if([[self presentedViewController] transitionCoordinator]){
        
        [[[self presentedViewController] transitionCoordinator] animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
            [[self dimmingView] setFrame:self.containerView.bounds];
            [[self dimmingView] setAlpha:0.0];
        } completion:nil];
    }
    else{
        
        [[self dimmingView] setFrame:self.containerView.bounds];
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


#pragma mark - Transition In Animtor


@implementation AINTopdownTransitionInAnimator
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    return 0.4f;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    //UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    UIView *fromView = [fromVC view];
    //UIView *mask = [fromView snapshotViewAfterScreenUpdates:NO];
    //[mask setTag:maskTag];
    
    UIViewController *toVC   = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    
    UIView *containerView = [transitionContext containerView];

    CGRect toViewFinalFrame = [transitionContext finalFrameForViewController:toVC];
   // [toView setFrame: toViewFinalFrame];
    
    UIView *mask = [containerView viewWithTag:maskTag];

    [containerView addSubview:toView];
    //[containerView addSubview:mask];
    [containerView bringSubviewToFront:mask];
    
    UIView* dimm = [containerView viewWithTag:dimmedTag];
    [containerView bringSubviewToFront:dimm];

    
    CGRect finalFrame = CGRectMake(0, toViewFinalFrame.size.height, fromView.width, fromView.height);
    toView.transform = CGAffineTransformMakeScale(2, 2);
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                          delay:0
         usingSpringWithDamping:20
          initialSpringVelocity:4.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         //[toView setFrame: toViewFinalFrame];
                         toView.transform = CGAffineTransformMakeScale(1, 1);

                         [mask setFrame:finalFrame];
                    
                     }
                     completion:^(BOOL finished){
                         // If we're dismissing, remove the presented view from the hierarchy
                         // We need to notify the view controller system that the transition has finished
                         BOOL cancelled = [transitionContext transitionWasCancelled];
                         [transitionContext completeTransition:!cancelled];
                     }];

}

@end


#pragma mark - Transition Out Animtor
@implementation AINTopdownTransitionOutAnimator

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    return 0.4f;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    

    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
   
    UIViewController *toVC   = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    //UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIView *toView = [toVC view];

    UIView *containerView = [transitionContext containerView];
    
    UIView* mask = [containerView viewWithTag:maskTag];
    // Animate using the duration from -transitionDuration:

    CGRect initialFrame = CGRectMake(0, 0, toView.width, toView.height);
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                          delay:0
         usingSpringWithDamping:20
          initialSpringVelocity:4.0
                        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState
                                | UIViewAnimationOptionLayoutSubviews
                     animations:^{
                         fromView.transform = CGAffineTransformMakeScale(2.0f, 2.0f);
                         [mask setFrame:initialFrame];
    
                     }
                     completion:^(BOOL finished){
                         // If we're dismissing, remove the presented view from the hierarchy
                         
                         // We need to notify the view controller system that the transition has finished
                         BOOL cancelled = [transitionContext transitionWasCancelled];
                         if (!cancelled && finished) {
                             fromView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
                             [mask removeFromSuperview];
                             [fromView removeFromSuperview];
                         }
                         
                         [transitionContext completeTransition:!cancelled];

                     }];
    
}


@end


#pragma mark - Transition In Interactive
@interface AINTopdownTransitionInInteractivity ()<UIGestureRecognizerDelegate>
@property(nonatomic,strong)UIPanGestureRecognizer* panGesture;
@property(nonatomic,weak)id<UIViewControllerContextTransitioning> transitionContext;
@property(nonatomic,assign)CGSize toViewSize;
@end

@implementation AINTopdownTransitionInInteractivity

- (void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    // Always call super first.
    [super startInteractiveTransition:transitionContext];
    
    // Save the transition context for future reference.
    self.transitionContext = transitionContext;
    self.toViewSize = [transitionContext viewForKey:UITransitionContextToViewKey].size;

}


- (UIPanGestureRecognizer*)panGesture{
    if (_panGesture == nil) {
        _panGesture = [[UIPanGestureRecognizer alloc]init];
        _panGesture.delegate = self;
        [_panGesture addTarget:self action:@selector(handleGesture:)];
    }
    return _panGesture;
}

- (void)setDelegate:(id<AINTopdownTransitionDelegate>)delegate{
    _delegate = delegate;
    [_delegate interactiveTransitionDelegateDidBinded:self.panGesture];
}

- (void)handleGesture:(UIPanGestureRecognizer*)gestureRecognizer{
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        // Reset the translation value at the beginning of the gesture.
        //[self.panGesture setTranslation:CGPointMake(0, 0) inView:self.panGesture.view];
        _active = YES;
        [self.delegate interactiveTransitionWillBegin];
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        // Get the current translation value.
        CGPoint translation = [self.panGesture translationInView:self.panGesture.view];
        
        
        // Compute how far the gesture has travelled vertically,
        //  relative to the height of the container view.
        CGFloat percentage = fabs(translation.y / (_toViewSize.height));
        
        // Use the translation value to update the interactive animator.
        if (translation.y < 0) {
            [self updateInteractiveTransition:0];
            return;
        }
        [self updateInteractiveTransition:percentage/2];
        _active = YES;
    }
    else if (gestureRecognizer.state >= UIGestureRecognizerStateEnded) {
        // Finish the transition and remove the gesture recognizer.
        CGPoint translation = [self.panGesture translationInView:self.panGesture.view];
        // Compute how far the gesture has travelled vertically,
        //  relative to the height of the container view.
        if (translation.y < 0) {
            self.completionSpeed = 0.1;
            [self cancelInteractiveTransition];
        
            _active = NO;
            return;
        }
        
        CGFloat percentage = fabs(translation.y / _toViewSize.height);
        if (percentage >= 0.1) {
            self.completionSpeed = 0.3;
            [self finishInteractiveTransition];
        }
        else{
            self.completionSpeed = 0.1;
            [self cancelInteractiveTransition];
        }
        _active = NO;
        
    }

}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    CGPoint translation = [((UIPanGestureRecognizer*)gestureRecognizer)translationInView:gestureRecognizer.view];
    CGPoint location = [gestureRecognizer locationInView:gestureRecognizer.view];
    //only handle touches in navigationbar
    if (translation.y < 0 || location.y > 64) {
        return NO;
    }
    return YES;
}


@end

#pragma mark - Transition Out Interactive
@interface AINTopdownTransitionOutInteractivity ()<UIGestureRecognizerDelegate>
@property(nonatomic,strong)UIPanGestureRecognizer* panGesture;
@property(nonatomic,weak)id<UIViewControllerContextTransitioning> transitionContext;
@property(nonatomic,assign)CGSize fromViewSize;
@end

@implementation AINTopdownTransitionOutInteractivity

- (void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    // Always call super first.
    [super startInteractiveTransition:transitionContext];
    
    // Save the transition context for future reference.
    self.transitionContext = transitionContext;
    self.fromViewSize = [transitionContext viewForKey:UITransitionContextFromViewKey].size;

}


- (UIPanGestureRecognizer*)panGesture{
    if (_panGesture == nil) {
        _panGesture = [[UIPanGestureRecognizer alloc]init];
        _panGesture.delegate = self;
        [_panGesture addTarget:self action:@selector(handleGesture:)];
    }
    return _panGesture;
}

- (void)setDelegate:(id<AINTopdownTransitionDelegate>)delegate{
    _delegate = delegate;
    [self.delegate interactiveTransitionDelegateDidBinded:self.panGesture];
}

- (void)handleGesture:(UIPanGestureRecognizer*)gestureRecognizer{
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        // Reset the translation value at the beginning of the gesture.
        //[self.panGesture setTranslation:CGPointMake(0, 0) inView:self.panGesture.view];
        _active = YES;
        [self.delegate interactiveTransitionWillBegin];
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        // Get the current translation value.
        CGPoint translation = [self.panGesture translationInView:self.panGesture.view];

        // Compute how far the gesture has travelled vertically,
        //  relative to the height of the container view.
        CGFloat percentage = fabs(translation.y / (_fromViewSize.height));
        
        // Use the translation value to update the interactive animator.
        if (translation.y > 0) {
            [self updateInteractiveTransition:0];
            return;
        }
        [self updateInteractiveTransition:percentage/2];
        _active = YES;
    }
    else if (gestureRecognizer.state >= UIGestureRecognizerStateEnded) {
        // Finish the transition and remove the gesture recognizer.
        CGPoint translation = [self.panGesture translationInView:self.panGesture.view];
        // Compute how far the gesture has travelled vertically,
        //  relative to the height of the container view.
        if (translation.y > 0) {
            self.completionSpeed = 0.1;
            [self cancelInteractiveTransition];
            _active = NO;
            return;
        }
        
        CGFloat percentage = fabs(translation.y / _fromViewSize.height);
        if (percentage >= 0.1) {
            self.completionSpeed = 0.3;
            [self finishInteractiveTransition];
        }
        else{
            self.completionSpeed = 0.1;
            [self cancelInteractiveTransition];
        }
        _active = NO;
        
    }
    
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    CGPoint translation = [((UIPanGestureRecognizer*)gestureRecognizer)translationInView:gestureRecognizer.view];
    if (translation.y <= 0) {
        return YES;
    }
    return NO;
}


@end



#pragma mark - Transition delegate

@interface AINTopdownTransition ()
@property(nonatomic,strong)AINTopdownTransitionInInteractivity* inInteractivity;
@property(nonatomic,strong)AINTopdownTransitionOutInteractivity* outInteractivity;
@end

@implementation AINTopdownTransition

- (instancetype)initWithInitialViewController:(id<AINTopdownTransitionDelegate>)viewController{
    self = [super init];
    if (self) {
        _inInteractivity = [[AINTopdownTransitionInInteractivity alloc]init];
        _inInteractivity.delegate = viewController;
    }
    return self;
}

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source{
    // Here, we'll provide the presentation controller to be used for the presentation
    AINTopdownPresatationController* presentationController = [[AINTopdownPresatationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
    
    _outInteractivity = [[AINTopdownTransitionOutInteractivity alloc]init];
    _outInteractivity.delegate = presentationController;
    return presentationController;
}



- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    AINTopdownTransitionInAnimator *animationController = [[AINTopdownTransitionInAnimator alloc]init];
 
    return animationController;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    
    AINTopdownTransitionOutAnimator *animationController = [[AINTopdownTransitionOutAnimator alloc]init];
    
    return animationController;
}

- (nullable id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator{
    return _inInteractivity.active?_inInteractivity:nil;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator{
    return _outInteractivity.active?_outInteractivity:nil;
}

@end



#pragma mark - Segue
//
//@implementation AINTopdownSegue
//
//- (void)perform{
//    
//    UIViewController *destinationViewController = self.destinationViewController;
//    UIViewController *sourceViewController = self.sourceViewController;
////    destinationViewController.transitioningDelegate = self.transition;
//    [sourceViewController presentViewController:destinationViewController animated:YES completion:nil];
//}
//
//@end
