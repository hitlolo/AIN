//
//  AINCommandTransition.h
//  AIN
//
//  Created by Lolo on 16/5/23.
//  Copyright © 2016年 Lolo. All rights reserved.
//

@protocol AINTopdownTransitionDelegate <NSObject>
- (void)interactiveTransitionDelegateDidBinded:(UIGestureRecognizer*)gesture;
- (void)interactiveTransitionWillBegin;
@end

//presentation controller
@interface AINTopdownPresatationController : UIPresentationController
@end

//animator
@interface AINTopdownTransitionInAnimator : NSObject
<UIViewControllerAnimatedTransitioning>
@end

@interface AINTopdownTransitionOutAnimator : NSObject
<UIViewControllerAnimatedTransitioning>
@end

//interactive
@interface AINTopdownTransitionInInteractivity : UIPercentDrivenInteractiveTransition
@property(nonatomic,assign)BOOL active;
@property(nonatomic,weak)id<AINTopdownTransitionDelegate> delegate;
@end

@interface AINTopdownTransitionOutInteractivity : UIPercentDrivenInteractiveTransition
@property(nonatomic,assign)BOOL active;
@property(nonatomic,weak)id<AINTopdownTransitionDelegate> delegate;
@end

//transition delegate
@interface AINTopdownTransition : NSObject
<UIViewControllerTransitioningDelegate>
- (instancetype)initWithInitialViewController:(id<AINTopdownTransitionDelegate>)viewController;
@end


//@interface AINTopdownSegue : UIStoryboardSegue;
////@property(nonatomic,weak)AINTopdownTransition* transition;
//@end
